# ==============================================================================
# Ghana vs Cote d'Ivoire comparison analysis
# Paper: Kouakou et al. (2026), Sustainable Development, https://doi.org/10.1002/sd.70266
# Produces: merged Ghana/CIV policy-instrument counts, normality tests, Wilcoxon
#           comparisons (overall and per creative-destruction function), density
#           plots, and boxplots with annotated p-values.
# Related to Figure 4 and Table 4 in the article.
#
# Expected inputs (exported from Data S1, Supporting Information of the article):
#   data/tc_agoroforestry_codebook_GH2.csv
#   data/tc_agroforestry_codebook_CIV.csv
# ==============================================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)  # for stat_compare_means()

# ---- 1. Load and prepare Ghana data ----
dat.gh <- read.csv("data/tc_agoroforestry_codebook_GH2.csv")

# ---- 2. Load and prepare Cote d'Ivoire data ----
dat.ci <- read.csv("data/tc_agroforestry_codebook_CIV.csv")

tc.ci <- dat.ci %>%
  select(Intervention, System.of.influence, System.of.influence..code., Creative.destruction.functions) %>%
  mutate(Intervention = ifelse(Intervention == "None observed", NA, Intervention))

tc.ci2 <- tc.ci %>%
  count(System.of.influence, System.of.influence..code., Creative.destruction.functions, sort = TRUE) %>%
  mutate(n = ifelse(n == 1, 0, n))

# ---- 3. Merge Ghana and Cote d'Ivoire counts by system of influence ----
merged_data <- merge(dat.gh, tc.ci2, by = "System.of.influence", all = TRUE)

merged_data2 <- merged_data %>%
  select(System.of.influence, code, Creative.destruction.functions.x, Number.of.policy.instruments, n)

merged.data3 <- merged_data2 %>%
  rename(Creative.destruction.functions = Creative.destruction.functions.x,
         n.gh = Number.of.policy.instruments,
         n.civ = n)

head(merged.data3)
summary(merged.data3)

# ---- 4. Normality checks ----
shapiro.test(merged.data3$n.gh)
shapiro.test(merged.data3$n.civ)
# Not normally distributed -> use non-parametric (Wilcoxon) tests

# ---- 5. Overall paired Wilcoxon test (Ghana vs CIV) ----
wilcox_test_result <- wilcox.test(merged.data3$n.gh, merged.data3$n.civ, paired = TRUE)
print(wilcox_test_result)

# ---- 6. Paired Wilcoxon test per system of influence ----
results <- merged.data3 %>%
  group_by(System.of.influence) %>%
  summarise(
    p_value = wilcox.test(n.gh, n.civ, paired = TRUE, exact = FALSE)$p.value
  )
print(results)
# If most p-values are close to 1, policy presence is similar across both countries

# ---- 7. Density plot of policy counts (Ghana vs CIV, overall) ----
density_data <- merged.data3 %>%
  select(System.of.influence, n.gh, n.civ) %>%
  pivot_longer(cols = c(n.gh, n.civ), names_to = "Country", values_to = "Policy_Count") %>%
  mutate(Country = ifelse(Country == "n.gh", "Ghana", "Cote d'Ivoire"))

ggplot(density_data, aes(x = Policy_Count, fill = Country, color = Country)) +
  geom_density(alpha = 0.4, adjust = 1.2) +
  scale_fill_manual(values = c("blue", "orange")) +
  scale_color_manual(values = c("blue", "orange")) +
  theme_minimal() +
  labs(title = "Density plot of policy counts in Ghana vs. Cote d'Ivoire",
       x = "Policy instrument count", y = "Density", fill = "Country", color = "Country") +
  theme(legend.position = "top")

# ---- 8. Density plot faceted by creative-destruction function ----
density_data2 <- merged.data3 %>%
  select(Creative.destruction.functions, n.gh, n.civ) %>%
  pivot_longer(cols = c(n.gh, n.civ), names_to = "Country", values_to = "Policy_Count") %>%
  mutate(Country = ifelse(Country == "n.gh", "Ghana", "Cote d'Ivoire"))

ggplot(density_data2, aes(x = Policy_Count, fill = Country, color = Country)) +
  geom_density(alpha = 0.4, position = "identity", adjust = 1.2) +
  scale_fill_manual(values = c("blue", "orange")) +
  scale_color_manual(values = c("blue", "orange")) +
  theme_minimal() +
  labs(title = "Density plot of policy counts by creative-destruction function",
       x = "Policy instrument count", y = "Density", fill = "Country", color = "Country") +
  facet_wrap(~Creative.destruction.functions, scales = "free") +
  theme(legend.position = "top")

# ---- 9. Boxplot: policy counts by function and country ----
boxplot_data2 <- merged.data3 %>%
  select(Creative.destruction.functions, n.gh, n.civ) %>%
  pivot_longer(cols = c(n.gh, n.civ), names_to = "Country", values_to = "Policy_Count") %>%
  mutate(Country = ifelse(Country == "n.gh", "Ghana", "Cote d'Ivoire"))

ggplot(boxplot_data2, aes(x = Creative.destruction.functions, y = Policy_Count, fill = Country)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA, position = position_dodge(0.8)) +
  geom_jitter(shape = 16, position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8), alpha = 0.6) +
  scale_fill_manual(values = c("blue", "orange")) +
  theme_minimal() +
  labs(title = "Policy instruments by creative-destruction function (Ghana vs. Cote d'Ivoire)",
       x = "Creative destruction function", y = "Number of policy instruments", fill = "Country")

# ---- 10. Wilcoxon rank-sum test per creative-destruction function ----
wilcox_data <- boxplot_data2

wilcox_results <- wilcox_data %>%
  group_by(Creative.destruction.functions) %>%
  summarise(
    p_value = wilcox.test(Policy_Count ~ Country, exact = FALSE)$p.value,
    .groups = "drop"
  )
print(wilcox_results)

# ---- 11. Boxplot with annotated Wilcoxon p-values (final aesthetic version) ----
ggplot(wilcox_data, aes(x = Creative.destruction.functions, y = Policy_Count, fill = Country)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA, position = position_dodge(0.8)) +
  geom_jitter(shape = 16, position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8), alpha = 0.6) +
  stat_compare_means(aes(group = Country), method = "wilcox.test", label = "p.format",
                      size = 6, vjust = -0.5, fontface = "bold") +
  scale_fill_manual(values = c("blue", "orange")) +
  theme_minimal() +
  labs(title = "Number of policy instruments by creative-destruction function, with p-values",
       x = "Functions of creative destruction", y = "Number of policy instruments", fill = "Country") +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5, size = 12, face = "bold"),
        axis.text.y = element_text(size = 14),
        legend.position = "top",
        plot.title = element_text(size = 14, face = "bold"))
