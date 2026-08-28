# Existing Sustainability Interventions are Insufficient to Scale Up Cocoa Agroforestry in West Africa

This repository contains the analysis code supporting the paper: ["Existing Sustainability Interventions are Insufficient to Scale Up Cocoa Agroforestry in West Africa"](https://doi.org/10.1002/sd.70266).

## Citation

Kouakou, K. M.-P., J. Lyons-White, W. J. Thompson, T. Addoah, F. Cammelli, W. J. Blaser-Hart, V. Maguire-Rajpaul, E. Dawoe, and R. D. Garrett. 2026. "Existing Sustainability Interventions are Insufficient to Scale Up Cocoa Agroforestry in West Africa." *Sustainable Development* 34, no. 1: 1167–1184. [https://doi.org/10.1002/sd.70266](https://doi.org/10.1002/sd.70266)

## Author

Keessy Maria-Prisca Kouakou (prisca.kouakou@outlook.com)

## Data download

The data underlying this analysis (the policy-instrument codebooks for Côte d'Ivoire and Ghana, and the organisation-level coding) are provided as Supporting Information with the published article: **Data S1** (`sd70266-sup-0001-DataS1.xlsx`, Excel workbook, 173.5 KB), available on the [journal's article page](https://doi.org/10.1002/sd.70266).

Data S1 is a single Excel workbook containing multiple sheets (one per codebook: Ghana policy instruments, Côte d'Ivoire policy instruments, and organisation-level coding). To reproduce the analysis: open the workbook, export each relevant sheet as its own CSV file, and place these in a local `data/` folder (not tracked in this repository). Each script below states the exact filename it expects — rename your exported CSVs to match, or adjust the `read.csv()` paths at the top of each script. Full descriptions of variables, coding categories, and analytical procedures are provided in the article's Methods section and Supporting Information.

## Repository description

This repository contains the R scripts used to analyse the policy-mapping data and produce the paper's descriptive figures and statistical comparisons.

### Code files

- **`R/01_Ghana_policy_instruments_analysis.R`**
  Loads the Ghana policy-instrument codebook, summarises the number of instruments by "system of influence" (SI) code, and produces the stacked bar chart of Ghana's policy instruments grouped by function of creative destruction (conformist/niche-supporting C-functions vs. disruptive/regime-destabilizing D-functions) — corresponds to **Figure 3** in the article.

- **`R/02_CIV_policy_instruments_analysis.R`**
  Loads the Côte d'Ivoire policy-instrument codebook, cleans non-observed interventions, counts instruments by SI code and function, and produces the equivalent stacked bar chart for Côte d'Ivoire — corresponds to **Figure 2** in the article.

- **`R/03_Ghana_CIV_comparison_analysis.R`**
  Merges the Ghana and Côte d'Ivoire counts by system of influence, tests normality (Shapiro–Wilk), and compares the two countries using Wilcoxon tests (paired, and per creative-destruction function). Produces density plots and boxplots (with Wilcoxon p-values annotated) comparing the distribution of policy-instrument counts between the two countries — supports the cross-country comparison discussed in the article (related to **Figure 4** and **Table 4**).

- **`R/04_Organisation_level_analysis.R`**
  Loads the organisation-level coding data, cleans it, and produces descriptive statistics tables (via `stargazer`) summarising systems of influence and creative-destruction functions by country and by organisation category. Includes Kruskal–Wallis and Wilcoxon/t-tests comparing organisation categories and countries. Supports supplementary descriptive statistics referenced in the article.

## Requirements

The scripts use the following R packages: `ggplot2`, `dplyr`, `tidyr`, `plyr`, `viridis` (via `scale_fill_viridis_d()`), `ggpubr`, `rstatix`, `tidyverse`, `stargazer`, and `readr`. Install any missing packages with `install.packages()` before running.

## License

MIT
