library(lme4)
library(report)
library(ggplot2)
library(dplyr)
library(flextable)
library(binom)

df <- read.csv('MIN_MAX_AL5.tsv', sep = '\t')

df$Speaker <- as.factor(df$Speaker)
df$SentType <- as.factor(df$SentType)
df$Sweep   <- as.factor(df$Sweep)
df$FocusType   <- factor(df$FocusType, levels = c("Narrow", "Broad", "NonNarrow"))  # define order
df$PosInSent   <- as.numeric(df$PosInSent)

# Hyp 2

# first analysis
# Subset only utterances that have a Narrow focus
narrow_utts <- df %>%
  group_by(Speaker, Sweep) %>%
  filter(any(FocusType == "Narrow")) %>%
  ungroup()

# For each utterance, mark which word has the lowest NormMin
narrow_utts <- narrow_utts %>%
  group_by(Speaker, Sweep) %>%
  mutate(is_lowest = as.numeric(NormMin == min(NormMin))) %>%
  ungroup()

# Keep only the Narrow-focus word
focused_words <- narrow_utts %>%
  filter(FocusType == "Narrow")

mean(focused_words$is_lowest)

binom.test(sum(focused_words$is_lowest),
           nrow(focused_words),
           p = 0.25,
           alternative = "greater")

model_h2 <- glmer(is_lowest ~ 1 + (1 | Speaker),
                  data = focused_words,
                  family = binomial)
summary(model_h2)

ggplot(focused_words, aes(x = Speaker, y = is_lowest)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  geom_hline(yintercept = 0.25, linetype = "dashed", color = "red") +
  ylab("Proportion of utterances where Narrow word is lowest") +
  theme_minimal()

report(model_h2)

# build H2 table

# Build H2 table (choose Min vs NormMin via value_col)
make_h2_table <- function(df, value_col = c("Min", "NormMin")) {
  value_col <- match.arg(value_col)
  
  df <- df %>%
    mutate(.value_used = if (value_col == "Min") Min else NormMin)
  
  # Keep only utterances that have a Narrow-focused word
  narrow_utts <- df %>%
    group_by(Speaker, Sweep) %>%
    filter(any(FocusType == "Narrow")) %>%
    ungroup()
  
  h2_table <- narrow_utts %>%
    group_by(Speaker, Sweep) %>%
    summarise(
      SentType   = first(SentType),
      # Position of the Narrow-focused word
      NarrowPos  = first(PosInSent[FocusType == "Narrow"]),
      # Values per position (1..4) for the chosen metric
      Min_W1 = first(.value_used[PosInSent == 1]),
      Min_W2 = first(.value_used[PosInSent == 2]),
      Min_W3 = first(.value_used[PosInSent == 3]),
      Min_W4 = first(.value_used[PosInSent == 4]),
      # Value at the Narrow position
      NarrowValue = first(.value_used[FocusType == "Narrow"]),
      .groups = "drop"
    ) %>%
    mutate(
      LowestMin      = pmin(Min_W1, Min_W2, Min_W3, Min_W4, na.rm = TRUE),
      # Count ties as TRUE; small tolerance for floating point quirks
      NarrowIsLowest = NarrowValue <= (LowestMin + 1e-9)
    ) %>%
    select(Speaker, Sweep, SentType,
           Min_W1, Min_W2, Min_W3, Min_W4,
           NarrowPos, NarrowIsLowest)
  
  h2_table
}

# Example usage:
# Use raw Min (as you requested for the 4 columns and the assessment)
h2_results_min <- make_h2_table(df, value_col = "Min")

# If you want the same table but based on clench-normalized values:
# h2_results_norm <- make_h2_table(df, value_col = "NormMin")

library(broom)   # for tidying test results (optional)
library(binom)   # for Wilson CIs

# Helper: add Wilson 95% CI and binomial test vs 0.25 (greater)
add_score_cols <- function(tbl) {
  # Wilson CI
  ci <- binom::binom.wilson(tbl$hits, tbl$n)
  tbl$ci_low  <- ci$lower
  tbl$ci_high <- ci$upper
  
  # Binomial test against chance 0.25 (focused word lowest out of 4)
  # Vectorized via mapply; returns NA if n == 0
  tbl$p_binom_gt_0_25 <- mapply(function(x, n) {
    if (is.na(n) || n == 0) return(NA_real_)
    binom.test(x, n, p = 0.25, alternative = "greater")$p.value
  }, tbl$hits, tbl$n)
  
  tbl
}

# Overall
scores_overall <- h2_results_min %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n
  ) %>%
  add_score_cols()

# Per Speaker
scores_by_speaker <- h2_results_min %>%
  group_by(Speaker) %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n,
    .groups = "drop"
  ) %>%
  add_score_cols()

# Per Sentence Type
scores_by_senttype <- h2_results_min %>%
  group_by(SentType) %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n,
    .groups = "drop"
  ) %>%
  add_score_cols()

# Per Position of the Narrow word (1–4)
scores_by_position <- h2_results_min %>%
  group_by(NarrowPos) %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n,
    .groups = "drop"
  ) %>%
  add_score_cols()

# (Optional) Speaker × Sentence Type
scores_speaker_senttype <- h2_results_min %>%
  group_by(Speaker, SentType) %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n,
    .groups = "drop"
  ) %>%
  add_score_cols()

# (Optional) Speaker × Position
scores_speaker_position <- h2_results_min %>%
  group_by(Speaker, NarrowPos) %>%
  summarise(
    n     = n(),
    hits  = sum(NarrowIsLowest, na.rm = TRUE),
    prop  = hits / n,
    .groups = "drop"
  ) %>%
  add_score_cols()

# Quick peeks
scores_overall
scores_by_speaker
scores_by_senttype
scores_by_position
# Optional combos:
# scores_speaker_senttype
# scores_speaker_position

# ?

ggplot(df_plot, aes(x = PosInSent, y = Min, group = interaction(Speaker, Sweep))) +
  geom_line(alpha = 0.25) +
  geom_point(aes(shape = isNarrow)) +
  scale_shape_manual(values = c(16, 17), labels = c("Other","Narrow")) +
  facet_wrap(~ Speaker, scales = "free_y") +
  labs(x = "Position in sentence (1–4)", y = "Min (more negative = more opening)",
       title = "Per-utterance jaw profile; Narrow highlighted") +
  theme_minimal()

# this is the nice plot!!!
# z normalise by speaker and senttype

df <- df %>%
  group_by(Speaker, SentType) %>%
  mutate(
    Min_z_spk_sent = (Min - mean(Min, na.rm = TRUE)) / sd(Min, na.rm = TRUE)
  ) %>%
  ungroup()

# ?
library(rlang)

plot_jaw_by_focuspos_colored <- function(df,
                                         value_col = c("Min", "NormMin", "Min_z_spk_sent"),
                                         yes_col = "forestgreen",
                                         no_col  = "red3",
                                         alpha_line = 0.35,
                                         alpha_point = 0.85) {
  value_col <- match.arg(value_col)
  val <- rlang::sym(value_col)
  
  # Keep only utterances that contain a Narrow token; compute focus position & lowest flag per utterance
  df_plot <- df %>%
    group_by(Speaker, Sweep) %>%
    filter(any(FocusType == "Narrow")) %>%
    mutate(
      NarrowPos   = first(PosInSent[FocusType == "Narrow"]),
      isNarrow    = (FocusType == "Narrow"),
      # Compute per-utterance "is lowest" based on chosen metric
      utter_min   = min(!!val, na.rm = TRUE),
      narrow_val  = first( (!!val)[isNarrow] ),
      NarrowIsLowest = narrow_val <= (utter_min + 1e-9)  # ties count as TRUE
    ) %>%
    ungroup()
  
  ggplot(
    df_plot,
    aes(x = PosInSent, y = !!val,
        group = interaction(Speaker, Sweep),
        color = NarrowIsLowest)
  ) +
    geom_line(alpha = alpha_line) +
    geom_point(aes(shape = isNarrow, size = isNarrow), alpha = alpha_point) +
    scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 17), guide = "none") +
    scale_size_manual(values = c(`FALSE` = 1.5, `TRUE` = 2.8), guide = "none") +
    scale_color_manual(
      values = c(`TRUE` = yes_col, `FALSE` = no_col),
      name = "Narrow is lowest?"
    ) +
    facet_wrap(
      ~ NarrowPos, nrow = 1,
      labeller = labeller(NarrowPos = function(p) paste("Focus at position", p))
    ) +
    labs(
      x = "Position in sentence (1–4)",
      #y = paste0(value_col, " (more negative = more opening)"),
      y = "Normalized jaw lowering (z-score)",
      title = "Per-utterance jaw profile, colored by whether Narrow is lowest",
      #subtitle = "Triangles mark the Narrow (focused) word"
    ) +
    theme_minimal()
}

# Examples:
plot_jaw_by_focuspos_colored(df, value_col = "Min_z_spk_sent")
# plot_jaw_by_focuspos_colored(df, value_col = "NormMin", yes_col = "#1b9e77", no_col = "#d95f02")

##################################
# gen the table with all results #
##################################

# Helper: add Wilson CI + one-sided binomial test vs baseline
.add_stats <- function(tbl, baseline = 0.25) {
  ci <- binom::binom.wilson(tbl$hits, tbl$n)
  tbl$ci_low  <- ci$lower
  tbl$ci_high <- ci$upper
  
  tbl$p_one_sided <- mapply(function(x, n) {
    if (is.na(n) || n == 0) return(NA_real_)
    binom.test(x, n, p = baseline, alternative = "greater")$p.value
  }, tbl$hits, tbl$n)
  
  # Map p-values to stars
  tbl$Sig <- dplyr::case_when(
    is.na(tbl$p_one_sided)       ~ NA_character_,
    tbl$p_one_sided < 0.001      ~ "***",
    tbl$p_one_sided < 0.01       ~ "**",
    tbl$p_one_sided < 0.05       ~ "*",
    TRUE                         ~ "ns"
  )
  
  tbl
}

# Generic scorer for any grouping
.score_by <- function(h2, ..., label, baseline = 0.25) {
  grp_vars <- rlang::enquos(...)
  out <- h2 %>%
    group_by(!!!grp_vars, .drop = FALSE) %>%
    summarise(
      n    = n(),
      hits = sum(NarrowIsLowest, na.rm = TRUE),
      prop = hits / n,
      .groups = "drop"
    ) %>%
    .add_stats(baseline = baseline) %>%
    mutate(Level = label) %>%
    mutate(Group = if (ncol(select(., !!!grp_vars)) == 0) "All"
           else purrr::pmap_chr(select(., !!!grp_vars), function(...) {
             vals <- c(...)
             paste(paste(names(vals), vals, sep = "="), collapse = " | ")
           })) %>%
    select(Level, Group, n, hits, prop, ci_low, ci_high, Sig)
  out
}

# Unified scores table with significance stars
make_scores_table <- function(h2_results_min,
                              include_overall      = TRUE,
                              include_speaker      = TRUE,
                              include_senttype     = TRUE,
                              include_position     = TRUE,
                              include_speaker_sent = FALSE,
                              include_speaker_pos  = FALSE,
                              baseline             = 0.25,
                              digits_prop = 3,
                              digits_ci   = 3) {
  
  pieces <- list()
  
  if (include_overall) {
    pieces$overall <- h2_results_min %>%
      summarise(
        n    = n(),
        hits = sum(NarrowIsLowest, na.rm = TRUE),
        prop = hits / n
      ) %>%
      .add_stats(baseline = baseline) %>%
      mutate(Level = "Overall", Group = "All") %>%
      select(Level, Group, n, hits, prop, ci_low, ci_high, Sig)
  }
  
  if (include_speaker) {
    pieces$speaker <- .score_by(h2_results_min, Speaker, label = "Speaker", baseline = baseline)
  }
  if (include_senttype) {
    pieces$senttype <- .score_by(h2_results_min, SentType, label = "SentenceType", baseline = baseline)
  }
  if (include_position) {
    pieces$position <- .score_by(h2_results_min, NarrowPos, label = "FocusPosition", baseline = baseline)
  }
  if (include_speaker_sent) {
    pieces$speaker_sent <- .score_by(h2_results_min, Speaker, SentType, label = "Speaker × SentenceType", baseline = baseline)
  }
  if (include_speaker_pos) {
    pieces$speaker_pos <- .score_by(h2_results_min, Speaker, NarrowPos, label = "Speaker × FocusPosition", baseline = baseline)
  }
  
  out <- bind_rows(pieces) %>%
    mutate(
      prop   = round(prop,   digits_prop),
      ci_low = round(ci_low, digits_ci),
      ci_high= round(ci_high,digits_ci)
    ) %>%
    arrange(factor(Level,
                   levels = c("Overall","Speaker","SentenceType","FocusPosition",
                              "Speaker × SentenceType","Speaker × FocusPosition")),
            Group) %>%
    mutate(CI_95 = paste0("[", ci_low, ", ", ci_high, "]")) %>%
    select(Level, Group, n, hits, prop, CI_95, Sig)
  
  out
}

# ---- Example usage ----
scores_table <- make_scores_table(h2_results_min)

# make a flextable and save as docx
# assuming you have: scores_table <- make_scores_table(h2_results_min)
ft <- flextable(scores_table)

# Make it pretty
ft <- ft %>%
  set_header_labels(
    Level = "Level",
    Group = "Group",
    n = "N",
    hits = "Hits",
    prop = "Proportion",
    CI_95 = "95% CI",
    Sig = "Significance"
  ) %>%
  autofit() %>%
  theme_vanilla() %>%
  align(align = "center", part = "all")

# Save directly to a Word file
save_as_docx(ft, path = "narrow_focus_scores.docx")
