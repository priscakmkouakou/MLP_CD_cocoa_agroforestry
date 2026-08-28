# ==============================================================================
# Cote d'Ivoire (CIV) policy instruments analysis
# Paper: Kouakou et al. (2026), Sustainable Development, https://doi.org/10.1002/sd.70266
# Produces: stacked bar chart of Cote d'Ivoire's cocoa agroforestry policy
#           instruments grouped by function of creative destruction (Figure 2)
#
# Expected input: data/tc_agroforestry_codebook_CIV.csv
#   (exported from Data S1, Supporting Information of the article)
#   Required columns: Intervention, System.of.influence, System.of.influence..code.,
#                      Creative.destruction.functions
# ==============================================================================

library(dplyr)
library(tidyr)
library(ggplot2)

# ---- 1. Load data ----
dat.ci <- read.csv("data/tc_agroforestry_codebook_CIV.csv")
head(dat.ci)

# ---- 2. Clean data ----
# Treat "None observed" interventions as missing before counting
tc.ci <- dat.ci %>%
  select(Intervention, System.of.influence, System.of.influence..code., Creative.destruction.functions) %>%
  mutate(Intervention = ifelse(Intervention == "None observed", NA, Intervention))

# Count policy instruments per system of influence / function
tc.ci2 <- tc.ci %>%
  count(System.of.influence, System.of.influence..code., Creative.destruction.functions, sort = TRUE) %>%
  mutate(n = ifelse(n == 1, 0, n))  # a count of 1 here only reflects the NA intervention row

summary(tc.ci2)

# ---- 3. Sort data and compute label positions for the stacked bar chart ----
df_sorted_ci <- tc.ci2 %>%
  arrange(Creative.destruction.functions, System.of.influence..code.)

df_cumsum_ci <- df_sorted_ci %>%
  group_by(Creative.destruction.functions) %>%
  arrange(desc(System.of.influence..code.)) %>%
  mutate(label_ypos = cumsum(n) - (0.5 * n))

# ---- 4. Plot: Cote d'Ivoire policy instruments by function of creative destruction ----
ggplot(data = df_cumsum_ci, aes(x = Creative.destruction.functions, y = n, fill = System.of.influence..code.)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(y = label_ypos,
                label = ifelse(n > 0, n, "")),
            vjust = 0.5, color = "white", size = 4, fontface = "bold") +
  scale_fill_viridis_d() +
  labs(title = "CIV",
       x = "Functions of creative destruction",
       y = "Number of policy instruments",
       fill = "SI code") +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, color = "black"),
    axis.title.y = element_text(size = 14, color = "black"),
    axis.text.x = element_text(size = 12, color = "black"),
    axis.text.y = element_text(size = 12, color = "black"),
    legend.position = "right",
    legend.title = element_text(size = 14, color = "black"),
    legend.key.size = unit(0.8, "cm"),
    legend.text = element_text(size = 12, color = "black")
  )
