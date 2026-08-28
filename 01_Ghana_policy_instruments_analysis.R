# ==============================================================================
# Ghana policy instruments analysis
# Paper: Kouakou et al. (2026), Sustainable Development, https://doi.org/10.1002/sd.70266
# Produces: stacked bar chart of Ghana's cocoa agroforestry policy instruments
#           grouped by function of creative destruction (Figure 3)
#
# Expected input: data/tc_agoroforestry_codebook_GH2.csv
#   (exported from Data S1, Supporting Information of the article)
#   Required columns: Creative.destruction.functions, Number.of.policy.instruments, code
# ==============================================================================

library(dplyr)
library(ggplot2)

# ---- 1. Load data ----
dat.gh <- read.csv("data/tc_agoroforestry_codebook_GH2.csv")
head(dat.gh)
summary(dat.gh)

# ---- 2. Sort data and compute label positions for the stacked bar chart ----
df_sorted <- dat.gh %>%
  arrange(Creative.destruction.functions, code)

df_cumsum <- df_sorted %>%
  group_by(Creative.destruction.functions) %>%
  arrange(desc(code)) %>%  # ensure stacking order matches label order
  mutate(label_ypos = cumsum(Number.of.policy.instruments) - (0.5 * Number.of.policy.instruments))

# ---- 3. Plot: Ghana policy instruments by function of creative destruction ----
ggplot(data = df_cumsum, aes(x = Creative.destruction.functions, y = Number.of.policy.instruments, fill = code)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(y = label_ypos,
                label = ifelse(Number.of.policy.instruments > 0, Number.of.policy.instruments, "")),
            vjust = 0.5, color = "white", size = 4, fontface = "bold") +
  scale_fill_viridis_d() +
  labs(title = "Ghana",
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
