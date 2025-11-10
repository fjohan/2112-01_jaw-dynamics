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

# Hyp 1

ggplot(df, aes(FocusType, Min_z_spk_sent, fill = FocusType)) +
  geom_violin(trim = FALSE, alpha = 0.5) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.6) +
  stat_summary(fun = mean, geom = "point", shape = 21, size = 3, fill = "white") +
  theme_minimal() +
  labs(
    #title = "Normalized jaw lowering by focus type",
    y = "Normalized jaw lowering (z-score)",
    x = "Focus type"   # <- you can leave this here; it's removed by theme()
  ) +
  theme(
    legend.position = "none",
    axis.text = element_text(size = 14, color="black"),
    axis.title.x = element_blank(),  # removes "Focus type" label
    axis.title.y = element_text(size = 16),
    plot.title = element_text(size = 18, face = "bold")
  )
ggsave("Fig_2._jaw_focus_plot.png", width = 6, height = 4, dpi = 600)

ggplot(df, aes(PosInSent, Min_z_spk_sent, color = FocusType, group = FocusType)) +
  stat_summary(fun = mean, geom = "line", linewidth = 1) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.1) +
  #scale_x_continuous(expand = c(0, 0)) +   # <-- removes extra horizontal space
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.02))) +
  scale_y_continuous(limits = c(-2.2, NA)) +
  theme_minimal() +
  labs(
    y = "Normalized jaw lowering (z-score)",
    x = "Word position in sentence"
  ) +
  theme(
    #legend.position = "bottom",
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.position = c(0.1, 0.05),
    legend.justification = c("left", "bottom"),
    legend.background = element_rect(fill = "white", color = "grey80"),
    axis.text = element_text(size = 14, color = "black"),
    axis.title = element_text(size = 16),
    axis.title.x = element_text(size = 16, margin = margin(t = 16)),
    plot.title = element_text(size = 18, face = "bold")
  )
ggsave("Fig_3._position_effects.png", width = 6, height = 5, dpi = 600)

df_summary <- df %>%
  group_by(Speaker, FocusType) %>%
  summarise(mean_z = mean(Min_z_spk_sent), .groups = "drop")

ggplot(df_summary, aes(FocusType, mean_z, group = Speaker, color = Speaker)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_discrete(expand = c(0.05, 0.12)) +   # reduce horizontal padding
  theme_minimal() +
  labs(
    #title = "Each speaker’s focus pattern (z-normalized)",
    y = "Normalized jaw lowering (z-score)",
    x = "Focus type"
  ) +
  theme(
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.position = c(0.88, 0.05),           # inside, bottom-right corner
    legend.justification = c("right", "bottom"),
    legend.background = element_rect(fill = "white", color = "grey80"),
    axis.text = element_text(size = 14, color = "black"),
    axis.title.x = element_blank(),
    axis.title = element_text(size = 16),
    plot.title = element_text(size = 18, face = "bold")
  )
ggsave("Fig_4._per_speaker.png", width = 6, height = 4, dpi = 600)

ggplot(df, aes(PosInSent, Min_z_spk_sent, color = FocusType, group = FocusType)) +
  stat_summary(fun = mean, geom = "line", linewidth = 1) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.1) +
  facet_wrap(
    ~ SentType,
    nrow = 1,
    labeller = as_labeller(c(`1` = "Type 1", `2` = "Type 2"))
  ) +
  scale_y_continuous(limits = c(-2.2, NA)) +
  theme_minimal() +
  labs(
    y = "Normalized jaw lowering (z-score)",
    x = "Word position in sentence"
  ) +
  theme(
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.position = c(0.70, 0.16),
    legend.background = element_rect(fill = "white", color = "grey80"),
    axis.text = element_text(size = 14, color = "black"),
    axis.title = element_text(size = 16),
    axis.title.x = element_text(size = 16, margin = margin(t = 16)),
    strip.text = element_text(size = 16, face = "bold")  # make facet labels bigger
  )
ggsave("Fig_5._per_sentence_type.png", width = 6, height = 5, dpi = 600)

