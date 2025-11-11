library(lme4)
library(report)

df <- read.csv('MIN_MAX_AL5.tsv', sep = '\t')

df$Speaker <- as.factor(df$Speaker)
df$SentType <- as.factor(df$SentType)
df$Sweep   <- as.factor(df$Sweep)
df$FocusType   <- factor(df$FocusType, levels = c("Narrow", "Broad", "NonNarrow"))  # define order
df$PosInSent   <- as.numeric(df$PosInSent)


model1 <- lmer(NormMin ~ NormQ + NormW + (1 | Speaker) + (1 | Sweep), data = df)
summary(model1)

model_word <- lmer(NormMin ~ FocusType * SentType + PosInSent + (1 | Speaker) + (1 | Sweep),
                   data = df)
summary(model_word)


library(ggplot2)


# 1. Overall pattern by focus condition (NormQ)
ggplot(df, aes(x = NormQ, y = NormMin)) +
  geom_violin(fill = "gray85", color = "gray40") +
  geom_boxplot(width = 0.2, fill = "white") +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, color = "red") +
  theme_minimal() +
  labs(title = "Jaw lowering by focus type",
       x = "Focus condition (NormQ)",
       y = "Normalized jaw displacement (NormMin)") +
  theme(text = element_text(size = 14))

# 2. Add speaker-level variability
ggplot(df, aes(x = NormQ, y = NormMin, color = Speaker, group = Speaker)) +
  stat_summary(fun = mean, geom = "line", size = 1, alpha = 0.7) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  theme_minimal() +
  labs(title = "Speaker-wise mean jaw displacement by focus type",
       y = "NormMin (more negative = greater jaw opening)",
       x = "Focus condition") +
  theme(text = element_text(size = 14))

# 4. Add word-position trend
ggplot(df, aes(x = NormW, y = NormMin, color = NormQ)) +
  stat_summary(fun = mean, geom = "line", size = 1.2) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  theme_minimal() +
  labs(title = "Jaw displacement by word position and focus type",
       x = "Word position in sentence (NormW)",
       y = "Normalized minimum (NormMin)") +
  theme(text = element_text(size = 14))


# 5. Speaker-by-focus faceted plot
ggplot(df, aes(x = NormQ, y = NormMin, color = NormQ)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.6) +
  geom_jitter(width = 0.1, alpha = 0.4) +
  facet_wrap(~ Speaker, ncol = 3) +
  theme_minimal() +
  labs(title = "Focus effect by speaker",
       y = "Normalized jaw displacement (NormMin)",
       x = "Focus condition") +
  theme(text = element_text(size = 13),
        legend.position = "none")





library(dplyr)

# Subset only utterances that have a Narrow focus
narrow_utts <- df %>%
  group_by(Speaker, Sweep) %>%
  filter(any(NormQ == "Narrow")) %>%
  ungroup()

# For each utterance, mark which word has the lowest NormMin
narrow_utts <- narrow_utts %>%
  group_by(Speaker, Sweep) %>%
  mutate(is_lowest = as.numeric(NormMin == min(NormMin))) %>%
  ungroup()

# Keep only the Narrow-focus word
focused_words <- narrow_utts %>%
  filter(NormQ == "Narrow")

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
