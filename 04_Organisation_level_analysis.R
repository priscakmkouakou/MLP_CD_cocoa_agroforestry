# ==============================================================================
# Organisation-level descriptive statistics
# Paper: Kouakou et al. (2026), Sustainable Development, https://doi.org/10.1002/sd.70266
# Produces: descriptive statistics tables (via stargazer) of policy-instrument
#           counts by country, system of influence, and organisation category,
#           plus Kruskal-Wallis and Wilcoxon/t-test comparisons.
#
# Expected inputs (exported from Data S1, Supporting Information of the article):
#   data/org3.csv
#   data/org_cleaned2.csv  (cleaned version, see step 2 below)
# ==============================================================================

library(dplyr)
library(tidyr)
library(tidyverse)
library(stargazer)
library(rstatix)

# ---- 1. Load raw organisation-level data ----
org <- read.csv("data/org3.csv")
head(org)

# ---- 2. Clean data ----
# Remove rows corresponding to non-informative / duplicate entries
org_cleaned <- org[-c(20, 28, 36, 37, 40:43), ]

# Export the cleaned file for reuse
write.csv(org_cleaned, "data/org_cleaned.csv", row.names = FALSE)

# Load the manually reviewed, cleaned dataset used in the analyses below
org2 <- read.csv("data/org_cleaned2.csv")
head(org2)

# ---- 3. Descriptive statistics: systems of influence per country ----
summary_stats1 <- org_cleaned %>%
  group_by(Country, System.of.influence) %>%
  summarise(
    N = n(),
    Mean = mean(n, na.rm = TRUE),
    St.Dev. = sd(n, na.rm = TRUE),
    Min = min(n, na.rm = TRUE),
    Max = max(n, na.rm = TRUE),
    .groups = "drop"
  )

stargazer(summary_stats1, type = "text", digits = 1,
          title = "Descriptive statistics: systems of influence per country (org_cleaned)",
          summary = FALSE, out = "html")

summary_stats11 <- org2 %>%
  group_by(Country, System.of.influence) %>%
  summarise(
    N = n(),
    Mean = mean(n, na.rm = TRUE),
    St.Dev. = sd(n, na.rm = TRUE),
    Min = min(n, na.rm = TRUE),
    Max = max(n, na.rm = TRUE),
    .groups = "drop"
  )

stargazer(summary_stats11, type = "text", digits = 1,
          title = "Descriptive statistics: systems of influence per country (org2)",
          summary = FALSE, out = "html11")

# ---- 4. Descriptive statistics: creative-destruction functions per organisation category ----
summary_stats2 <- org_cleaned %>%
  group_by(Creative.destruction.functions, Org..cat.) %>%
  summarise(
    N = n(),
    Mean = mean(n, na.rm = TRUE),
    St.Dev. = sd(n, na.rm = TRUE),
    Min = min(n, na.rm = TRUE),
    Max = max(n, na.rm = TRUE),
    .groups = "drop"
  )

stargazer(summary_stats2, type = "text", digits = 1,
          title = "Descriptive statistics: creative-destruction functions per organisation category",
          summary = FALSE, out = "html2")

# ---- 5. Kruskal-Wallis tests: differences between organisation categories ----
conformist_data <- org2 %>%
  filter(Creative.destruction.functions == "Conformist")

kruskal_results <- org2 %>%
  group_by(Creative.destruction.functions) %>%
  summarise(
    p_value_kruskal = kruskal.test(n ~ Org..cat.)$p.value,
    .groups = "drop"
  )

kruskal_conformist <- kruskal.test(n ~ Org..cat., data = conformist_data)

print(kruskal_results)
print(kruskal_conformist)

# ---- 6. Descriptive statistics: creative-destruction functions per country ----
summary_stats3 <- org2 %>%
  group_by(Creative.destruction.functions, Country) %>%
  summarise(
    N = n(),
    Mean = mean(n, na.rm = TRUE),
    St.Dev. = sd(n, na.rm = TRUE),
    Min = min(n, na.rm = TRUE),
    Max = max(n, na.rm = TRUE),
    .groups = "drop"
  )

stargazer(summary_stats3, type = "text", digits = 1,
          title = "Descriptive statistics: creative-destruction functions per country",
          summary = FALSE, out = "html3")

# ---- 7. Wilcoxon and t-test comparisons between countries, per function ----
p_values <- org2 %>%
  group_by(Creative.destruction.functions) %>%
  summarise(
    p_value_wilcox = wilcox.test(n ~ Country, exact = FALSE)$p.value,
    p_value_ttest = t.test(n ~ Country, var.equal = FALSE)$p.value,
    .groups = "drop"
  )
print(p_values)

# ---- 8. Additional country-level summary tables (Ghana / CIV) ----
# Requires merged.data3, produced in 03_Ghana_CIV_comparison_analysis.R
if (exists("merged.data3")) {
  summary_stats4 <- merged.data3 %>%
    group_by(Creative.destruction.functions) %>%
    summarise(
      N = n(),
      Mean = mean(n.gh, na.rm = TRUE),
      St.Dev. = sd(n.gh, na.rm = TRUE),
      Min = min(n.gh, na.rm = TRUE),
      Median = median(n.gh, na.rm = TRUE),
      Max = max(n.gh, na.rm = TRUE),
      .groups = "drop"
    )
  stargazer(summary_stats4, type = "text", digits = 1,
            title = "Descriptive statistics: Ghana policy instrument counts by function",
            summary = FALSE, out = "html4")

  summary_stats5 <- merged.data3 %>%
    group_by(Creative.destruction.functions) %>%
    summarise(
      N = n(),
      Mean = mean(n.civ, na.rm = TRUE),
      St.Dev. = sd(n.civ, na.rm = TRUE),
      Min = min(n.civ, na.rm = TRUE),
      Median = median(n.civ, na.rm = TRUE),
      Max = max(n.civ, na.rm = TRUE),
      .groups = "drop"
    )
  stargazer(summary_stats5, type = "text", digits = 1,
            title = "Descriptive statistics: Cote d'Ivoire policy instrument counts by function",
            summary = FALSE, out = "html5")
} else {
  message("Run 03_Ghana_CIV_comparison_analysis.R first to generate 'merged.data3' for steps 4 and 5 country summaries.")
}
