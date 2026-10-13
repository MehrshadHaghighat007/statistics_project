# Lake Urmia Statistical Analysis

An R-based statistical analysis of Lake Urmia's surface area and water level, examining their associations with agricultural, climatic, hydrological, and population variables.

Developed by **Mehrshad Haghighat** for the **Statistics and Applications** course at Sharif University of Technology.

## Overview

The project combines data preparation, exploratory data analysis, statistical inference, and regression modeling using **42 annual observations covering 1984–2025**. The main analysis subset contains **33 complete observations for 1992–2024**, after filtering for available agricultural-area and water-level measurements.

The analysis considers two response variables:

- **Lake_Area:** lake surface area.
- **water_level:** lake water level.

The explanatory variables are agricultural area, rainfall, temperature, soil moisture, dam capacity, and population.

## Analysis Workflow

| Stage | Implementation |
| --- | --- |
| Data preparation | Remove entirely missing columns, inspect missing values, and create subsets with available agricultural-area and water-level observations. |
| Period comparison | Define an early period (`Year <= 1999`) and a late period (`Year > 1999`). |
| Outlier inspection | Use boxplots and flag observations outside the mean plus or minus three standard deviations. |
| Exploratory analysis | Calculate descriptive statistics and visualize distributions, period differences, and predictor–response relationships. |
| Statistical inference | Calculate 95% t-based confidence intervals for mean lake area and water level; compare periods with Welch's two-sample t-tests. |
| Correlation analysis | Calculate Pearson correlations using complete observations. |
| Simple regression | Fit population-based linear models for lake area and water level. The predictor is explicitly selected in the script. |
| Multiple regression | Fit separate models using all six explanatory variables for each response. |
| Model selection | Apply bidirectional stepwise selection using AIC through `MASS::stepAIC()`. |
| Diagnostics | Inspect standard regression plots, Shapiro–Wilk residual normality tests, non-constant variance tests through `car::ncvTest()`, and variance inflation factors. |
| Coefficient comparison | Standardize variables and compare coefficients from the full six-predictor models in a combined table. |

## Repository Files

| File | Purpose |
| --- | --- |
| `project.R` | Main analysis script. |
| `Urmia_Master_Dataset_1984_2025.csv` | Input dataset: 42 annual observations covering 1984–2025. |
| `Untitled 1.pdf` | Persian course report describing the methodology and findings. |
| `README.md` | Project description and setup instructions. |
| `.gitignore` | Excludes local R session files and editor state. |

Read the [Persian report](<Untitled 1.pdf>) for the original discussion of the analysis.

## Requirements

- R, with an optional IDE such as RStudio.
- R packages: `tidyverse`, `ggplot2`, `readr`, `MASS`, `car`, and `corrplot`.
- The included input dataset, `Urmia_Master_Dataset_1984_2025.csv`.

Install the packages in R:

```r
install.packages(c("tidyverse", "ggplot2", "readr", "MASS", "car", "corrplot"))
```

`ggplot2` and `readr` are included in the tidyverse, but are also loaded explicitly by the script. `corrplot` is loaded; the current script prints the correlation matrix rather than calling its plotting function.

## Dataset

The input data is included as [Urmia_Master_Dataset_1984_2025.csv](Urmia_Master_Dataset_1984_2025.csv), alongside `project.R` in the repository root.

The CSV contains nine named analysis columns. Missing observations are encoded as `NA`. It also contains 13 unnamed, entirely empty trailing columns, which the script removes using `dplyr::select(where(~ !all(is.na(.))))`.

The script references these columns:

| Column | Description |
| --- | --- |
| `Year` | Observation year. |
| `Lake_Area` | Lake surface area, labeled in square meters in the script. |
| `water_level` | Lake water level, labeled in meters in the script. |
| `Agri_Area` | Agricultural area. |
| `Rainfall` | Rainfall measure. |
| `Temperature` | Temperature measure. |
| `Soil_Moisture` | Soil-moisture measure. |
| `Dam_Capacity` | Dam-capacity measure. |
| `Population` | Population measure. |

### Coverage and Missing Values

| Field / subset | Coverage |
| --- | --- |
| Full dataset | 42 annual observations, 1984–2025. |
| `water_level` | Missing for 1984–1991: eight observations. |
| `Agri_Area` | Missing for 2025: one observation. |
| Other named columns | No missing observations in the supplied CSV. |
| Main analysis subset (`lake_contribute`) | 33 observations, 1992–2024, with both `Agri_Area` and `water_level` available. |
| Early group in the main subset | Eight observations, 1992–1999. |
| Late group in the main subset | 25 observations, 2000–2024. |

Keep the numeric fields numeric and preserve `NA` for missing observations. Some selections in the script use contiguous column ranges (`water_level:Population` and `Agri_Area:Population`), so the input column order also matters.

The CSV does not contain source references or a units dictionary. The lake-area and water-level units above follow the labels in the analysis script; units for the other measures should be taken from the original data documentation.

## Running the Analysis

The original script uses an absolute path on the author's computer:

```r
lake <- read_csv("/home/mehrshad/Downloads/Urmia_Master_Dataset_1984_2025.csv")
```

For a portable checkout:

1. Keep `Urmia_Master_Dataset_1984_2025.csv` in the repository root, alongside `project.R`.
2. Replace the line above in `project.R` with:

   ```r
   lake <- read_csv("Urmia_Master_Dataset_1984_2025.csv")
   ```

3. Set the working directory to the repository root and run:

   ```r
   source("project.R")
   ```

Alternatively, after installing dependencies and updating the path, run from the repository root:

```bash
Rscript project.R
```

In an interactive R session, plots are shown through the active graphics device. In a typical non-interactive `Rscript` session, the default PDF device may create `Rplots.pdf`. The script does not explicitly export a named set of figures or a generated report.

## Interpretation and Scope

This is an exploratory statistical course project, rather than a forecasting or causal-inference system.

- Regression coefficients and correlations describe associations; they do not establish that a predictor causes lake decline.
- Annual observations may share trends and serial dependence. The script does not explicitly model or test temporal dependence.
- Stepwise AIC selection compares candidate models fitted to the available data; it does not establish performance on unseen observations. The script does not implement a held-out test set or cross-validation.
- Missing values, multicollinearity, and model assumptions affect interpretation. The script includes several regression diagnostics, but their inclusion alone does not guarantee that assumptions are satisfied.
- The final standardized-coefficient comparison uses the full models, rather than the models selected by stepwise AIC.

The dataset coverage and missing-value counts above were checked directly against the supplied CSV. The numerical model results discussed in the report have not been independently rerun as part of this documentation update.

## R Session Files

`.Rhistory`, `.RData`, and `.Rproj.user/` are not required to reproduce the project and should normally remain outside version control. Necessary analysis steps belong in `project.R`, with dependencies and input-data instructions documented here.
