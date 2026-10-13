# Lake Urmia Statistical Analysis

**Exploratory analysis, statistical inference, and regression modeling of annual lake and environmental data using R.**

This project examines how Lake Urmia's surface area and water level vary alongside agricultural activity, climate, water infrastructure, and population. It brings together a structured data-analysis workflow, interpretable linear models, and regression diagnostics to investigate relationships within an annual dataset spanning **1984–2025**.

Developed by **Mehrshad Haghighat** for the **Statistics and Applications** course at **Sharif University of Technology**.

## Analytical Objectives

The analysis addresses three questions:

- How do the distributions of lake area and water level differ between earlier and later observation periods?
- How are these lake indicators associated with agricultural, climatic, hydrological, and population variables?
- How do predictor selection, standardized coefficients, and diagnostic tests inform the interpretation of regression models?

## Methods

### Data Preparation and Exploratory Analysis

The workflow removes entirely missing columns, summarizes missing observations, and constructs analysis subsets based on measurement availability. Descriptive statistics include the mean, median, standard deviation, minimum, and maximum.

Visual exploration combines histograms, boxplots, predictor–response scatterplots, and fitted linear trends. Potential outliers are examined using boxplot criteria and a separate mean ± three-standard-deviations rule.

### Statistical Inference

The script estimates **95% t-based confidence intervals** for mean lake area and mean water level. **Welch's two-sample t-test** compares an early period (`Year <= 1999`) with a late period (`Year > 1999`) without imposing equal group variances.

### Regression Modeling

Two responses are modeled separately: **lake surface area** and **water level**.

| Component | Approach |
| --- | --- |
| Correlation analysis | Pearson correlation matrix calculated from complete observations. |
| Simple regression | Population-based linear models for each lake indicator. |
| Multiple regression | Six-predictor models combining agricultural area, rainfall, temperature, soil moisture, dam capacity, and population. |
| Model selection | Bidirectional stepwise selection using Akaike Information Criterion (AIC). |
| Model comparison | Adjusted R² summaries and standardized coefficient comparisons. |

Stepwise selection is implemented with `MASS::stepAIC()`. The standardized-coefficient comparison is based on the **full six-predictor models**, allowing the relative associations of predictors to be examined on a common scale.

### Regression Diagnostics

Model assessment includes:

- Residual-versus-fitted, normal Q–Q, scale–location, and residual-versus-leverage plots.
- **Shapiro–Wilk tests** for residual normality.
- **Non-constant variance score tests** using `car::ncvTest()`.
- **Variance inflation factors (VIF)** to examine multicollinearity.

## Dataset

The repository includes [Urmia_Master_Dataset_1984_2025.csv](Urmia_Master_Dataset_1984_2025.csv), containing **42 annual observations** and nine named variables.

| Variable | Analytical role | Description |
| --- | --- | --- |
| `Year` | Time index | Observation year. |
| `water_level` | Response | Lake water level, labeled in meters in the analysis. |
| `Lake_Area` | Response | Lake surface area, labeled in square meters in the analysis. |
| `Agri_Area` | Predictor | Agricultural area. |
| `Rainfall` | Predictor | Rainfall measure. |
| `Temperature` | Predictor | Temperature measure. |
| `Soil_Moisture` | Predictor | Soil-moisture measure. |
| `Dam_Capacity` | Predictor | Dam-capacity measure. |
| `Population` | Predictor | Population measure. |

### Observation Coverage

Missing values are represented as `NA`.

| Coverage | Observations |
| --- | --- |
| Full dataset: 1984–2025 | 42 |
| Main analysis subset: 1992–2024 | 33 |
| Early group within the main subset: 1992–1999 | 8 |
| Late group within the main subset: 2000–2024 | 25 |

Water-level measurements are unavailable for **1984–1991**, and agricultural-area data are unavailable for **2025**. The main analysis subset retains years with both measurements present. The remaining named variables have no missing values in the included CSV.

The script removes entirely empty trailing columns during preparation. Preserve the original named-column order: some transformations use contiguous column selections. Units and source attribution for the predictor variables should be interpreted using the underlying dataset documentation.

## Project Files

| File | Description |
| --- | --- |
| [project.R](project.R) | Data preparation, visualizations, inference, regression models, and diagnostics. |
| [Urmia_Master_Dataset_1984_2025.csv](Urmia_Master_Dataset_1984_2025.csv) | Annual input dataset. |
| [Persian project report](<report.pdf>) | Written discussion of the methodology and findings. |
| `README.md` | Project overview and execution instructions. |
| `.gitignore` | Exclusions for local R session and editor files. |

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/MehrshadHaghighat007/statistics_project.git
cd statistics_project
```

### 2. Install Dependencies

Install R and, optionally, RStudio. In an R session, install the packages loaded by the script:

```r
install.packages(c("tidyverse", "ggplot2", "readr", "MASS", "car", "corrplot"))
```

The workflow uses `dplyr` and `tidyr` for transformations, `ggplot2` for visualization, `readr` for CSV ingestion, `MASS` for AIC selection, and `car` for regression diagnostics. Base R provides the inference and linear-model functions. `corrplot` is loaded by the script but is not called in the current analysis.

### 3. Configure Data Loading

Keep the CSV beside `project.R` and ensure the script's data-loading statement uses this repository-relative path:

```r
lake <- read_csv("Urmia_Master_Dataset_1984_2025.csv")
```

Run the analysis with the repository root as the working directory.

### 4. Execute the Analysis

For interactive exploration in R or RStudio:

```r
source("project.R")
```

Alternatively, from a terminal:

```bash
Rscript project.R
```

## Analysis Outputs

Execution produces descriptive summaries, confidence intervals, hypothesis-test results, correlation matrices, regression summaries, AIC-selected models, diagnostic-test results, and a combined standardized-coefficient table.

In an interactive session, visualizations appear through the active graphics device. A non-interactive run may write graphics to the default `Rplots.pdf` device. The Persian report provides the accompanying narrative; it is a separate document rather than an automatically generated output of the script.

## Statistical Interpretation

The project investigates **associations in observational data**. Correlations, regression coefficients, and standardized effects should not be interpreted as evidence of causation.

Shared temporal trends, serial dependence, multicollinearity, and missing-data selection can affect interpretation. The implementation includes regression diagnostics but does not explicitly model temporal dependence. AIC selection compares fitted candidate models; it does not measure forecasting accuracy or performance on a held-out dataset.

## Author

**Mehrshad Haghighat**  
Computer Science, Sharif University of Technology  
[GitHub](https://github.com/MehrshadHaghighat007)
