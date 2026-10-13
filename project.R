
# packages ----------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(readr)
library(MASS)      
library(car)       
library(corrplot)

# style -------------------------------------------------------------------

theme_set(theme_minimal(base_size = 9)) 


# data wrangling ----------------------------------------------------------

lake <- read_csv("/home/mehrshad/Downloads/Urmia_Master_Dataset_1984_2025.csv")

lake <- lake %>%
  dplyr::select(where(~ !all(is.na(.))))

print(lake, n = Inf, width = Inf)

#missing values management 
lake %>% 
  summarise(across(everything(), ~ sum(is.na(.)))) %>% 
  pivot_longer(everything(), names_to = "variable", values_to = "NAs")

lake_agri <- lake %>% 
  filter(!is.na(Agri_Area))

print(lake_agri, n = Inf, width = Inf)

lake_water <- lake %>% 
  filter(!is.na(water_level))

print(lake_water, n = Inf, width = Inf)

lake_contribute <- lake_agri %>% 
  filter(!is.na(water_level))

print(lake_contribute, n = Inf, widht = Inf)

lake_contribute <- lake_contribute %>% 
  mutate(Period = if_else(Year <= 1999, "Early", "Late"))

print(lake_contribute, n = Inf, widht = Inf)

lake_contribute %>% 
  pivot_longer(-c(Year, Period), names_to = "var", values_to = "value") %>% 
  print(n = Inf)

#the quantile way to show the outliers

lake_contribute %>% 
  pivot_longer(-c(Year, Period), names_to = "var", values_to = "value") %>% 
  ggplot(aes(x = 0, y = value)) +
  geom_boxplot(outlier.colour = "red") +
  facet_wrap(~ var, scales = "free_y")

#the sd way to show the outliers 

lake_sd <- lake_contribute %>%
  pivot_longer(
    -c(Year, Period),
    names_to = "var",
    values_to = "value"
  )

stats <- lake_sd %>%
  group_by(var) %>%
  summarise(
    mean_val = mean(value, na.rm = TRUE),
    sd_val   = sd(value, na.rm = TRUE),
    lower_3sd = mean_val - 3 * sd_val,
    upper_3sd = mean_val + 3 * sd_val,
    .groups = "drop"
  )

lake_sd <- lake_sd %>%
  left_join(stats, by = "var") %>%
  mutate(
    is_outlier_3sd = value < lower_3sd | value > upper_3sd
  )

ggplot(lake_sd, aes(y = value)) +
  geom_boxplot(fill = "black", outlier.shape = NA) +           
  geom_point(
    data = . %>% filter(is_outlier_3sd),
    aes(x = 0, y = value),
    color = "red", size = 1, shape = 16, fill = "red"
  ) +
  facet_wrap(~ var, scales = "free_y") 

# eda ---------------------------------------------------------------------

summary_stats <- lake_contribute %>% 
  dplyr::select(water_level:Population) %>% 
  summarise(across(everything(),
                   list(mean   = ~mean(., na.rm=TRUE),
                        sd     = ~sd(., na.rm=TRUE),
                        min    = ~min(., na.rm=TRUE),
                        max    = ~max(., na.rm=TRUE),
                        median = ~median(., na.rm=TRUE))))

summary_stats %>% 
  pivot_longer(everything(), names_to = "stat", values_to = "value") %>% 
  print(n = Inf)

lake_contribute %>% 
  pivot_longer(-c(Year, Period), names_to = "var", values_to = "value") %>% 
  ggplot(aes(value)) +
  geom_histogram(bins = 30, fill = "blue", colour = "black") +
  facet_wrap(~ var, scales = "free") +
  labs(title = "Distribution of variables :")

lake_compare <- lake_contribute %>%
  pivot_longer(
    cols = c(Lake_Area, water_level),
    names_to = "Variable",
    values_to = "Value"
  ) %>%
  mutate(
    Variable = factor(Variable, levels = c("Lake_Area", "water_level"),
                      labels = c("Lake Area (m²)", "Water Level (m)"))
  )

ggplot(lake_compare, aes(x = Period, y = Value, fill = Period)) +
  geom_boxplot() +
  facet_wrap(~ Variable, scales = "free_y", ncol = 2) +
  labs(
    title = "Lake Area and Water Level - Early vs Late Period",
    x = NULL,
    y = NULL
  ) +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 12)
  )

lake_contribute %>%
  pivot_longer(
    cols = c(Agri_Area, Rainfall, Temperature, Soil_Moisture, Dam_Capacity, Population),
    names_to = "Predictor",
    values_to = "X"
  ) %>%
  pivot_longer(
    cols = c(Lake_Area, water_level),
    names_to = "Response",
    values_to = "Y"
  ) %>%
  mutate(
    Response = factor(Response, labels = c("Lake Area", "Water Level"))
  ) %>%
  ggplot(aes(x = X, y = Y, color = Response, shape = Response)) +
  geom_point(size = 2.6, alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.5) +
  facet_wrap(~ Predictor, scales = "free_x", ncol = 3) +
  scale_color_manual(values = c("Lake Area" = "blue", "Water Level" = "red")) +
  scale_shape_manual(values = c("Lake Area" = 16, "Water Level" = 16)) +  
  labs(
    title = "All Predictors vs Lake Area & Water Level",
    x = "Predictor value", y = "Lake response"
  ) +
  theme(legend.position = "bottom")

# inference ---------------------------------------------------------------

mean_lake_area <- mean(lake_contribute$Lake_Area)
se_area <- sd(lake_contribute$Lake_Area) / sqrt(nrow(lake_contribute))
t_crit_area <- qt(0.975, df = nrow(lake_contribute)-1)
ci_lower_area <- mean_lake_area - t_crit_area * se_area
ci_upper_area <- mean_lake_area + t_crit_area * se_area

cat("95% CI for mean Lake_Area:", round(ci_lower_area, 0), "–", round(ci_upper_area, 0), "m²\n")

#does not assume equal variance between groups 

t_test_result_area <- t.test(Lake_Area ~ Period, data = lake_contribute, var.equal = FALSE)
print(t_test_result_area)

mean_lake_level <- mean(lake_contribute$water_level)
se_level <- sd(lake_contribute$water_level) / sqrt(nrow(lake_contribute))
t_crit_level <- qt(0.975, df = nrow(lake_contribute)-1)
ci_lower_level <- mean_lake_level - t_crit_level * se_level
ci_upper_level <- mean_lake_level + t_crit_level * se_level

cat("95% CI for mean water_level:", round(ci_lower_level, 0), "–", round(ci_upper_level, 0), "m\n")

#does not assume equal variance between groups

t_test_result_level <- t.test(water_level ~ Period, data = lake_contribute, var.equal = FALSE)
print(t_test_result_level)

# simple regression -------------------------------------------------------

vars_to_correlate <- c("Lake_Area", "water_level", "Agri_Area", "Rainfall", "Temperature", "Soil_Moisture", "Dam_Capacity", "Population")

cor_matrix_both <- lake_contribute %>%
  dplyr::select(all_of(vars_to_correlate)) %>%
  cor(use = "complete.obs") %>%
  round(3)

print(cor_matrix_both[c("Lake_Area", "water_level"), ] %>% round(3))

strongest <- "Population"   # ← change according to your correlation result

m1 <- lm(reformulate(strongest, "Lake_Area"), data = lake_contribute)
summary(m1)

m2 <- lm(reformulate(strongest, "water_level"), data = lake_contribute)
summary(m2)

lake_long_cor <- lake_contribute %>%
  pivot_longer(
    cols = c(Lake_Area, water_level),
    names_to = "Target",
    values_to = "Value"
  ) %>%
  mutate(Target = factor(Target, labels = c("Lake Area (m²)", "Water Level (m)")))

ggplot(lake_long_cor, aes(x = Population, y = Value, color = Target)) +
  geom_point(alpha = 0.3, size = 2.8) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_color_manual(values = c("blue", "red")) +
  facet_wrap(~ Target, scales = "free_y", ncol = 2) +
  labs(
    title = paste("Relationship with", strongest),
    x = strongest,
    y = NULL
  ) + 
  theme(legend.position = "bottom")

# multiple regression -----------------------------------------------------

model_multi_area <- lm(
  Lake_Area ~ Agri_Area + Rainfall + Temperature + 
    Soil_Moisture + Dam_Capacity + Population,
  data = lake_contribute
)

summary(model_multi_area)


# (use df_water because water_level has NA in early years)
model_multi_level <- lm(
  water_level ~ Agri_Area + Rainfall + Temperature + 
    Soil_Moisture + Dam_Capacity + Population,
  data = lake_contribute
)

summary(model_multi_level)


# Compare adjusted R²
cat("Adj R² - Lake_Area (multiple):", 
    round(summary(model_multi_area)$adj.r.squared, 3), "\n")

cat("Adj R² - water_level (multiple):", 
    round(summary(model_multi_level)$adj.r.squared, 3), "\n")


# model selection and diagnostics -----------------------------------------

cat("=== Stepwise selection & Diagnostics for Lake_Area ===\n\n")

step_area <- stepAIC(model_multi_area, direction = "both", trace = 0)
summary(step_area)

final_area <- step_area

cat("\nDiagnostic plots for Lake_Area model:\n")
par(mfrow = c(2,2))
plot(final_area)   # 1. Residuals vs Fitted, 2. Q-Q, 3. Scale-Location, 4. Leverage

cat("\nNormality of residuals (Shapiro-Wilk):")
print(shapiro.test(residuals(final_area)))

cat("\nHomoscedasticity (Breusch-Pagan test):")
print(ncvTest(final_area))

cat("\nMulticollinearity (VIF):")
print(vif(final_area))


cat("\n\n=== Stepwise selection & Diagnostics for water_level ===\n\n")

# Stepwise AIC
step_level <- stepAIC(model_multi_level, direction = "both", trace = 0)
summary(step_level)

final_level <- step_level

cat("\nDiagnostic plots for water_level model:\n")
par(mfrow = c(2,2))
plot(final_level)

cat("\nNormality of residuals (Shapiro-Wilk):")
print(shapiro.test(residuals(final_level)))

cat("\nHomoscedasticity (Breusch-Pagan test):")
print(ncvTest(final_level))

cat("\nMulticollinearity (VIF):")
print(vif(final_level))

# final analysis ----------------------------------------------------------

df_std_area <- lake_contribute %>%
  mutate(across(c(Lake_Area, Agri_Area:Population), ~ as.numeric(scale(.))))

model_std_area <- lm(Lake_Area ~ Agri_Area + Rainfall + Temperature +
                       Soil_Moisture + Dam_Capacity + Population,
                     data = df_std_area)

std_coeffs_area <- coef(model_std_area)[-1] %>%
  sort(decreasing = TRUE)

cat("=== Standardized Coefficients – Lake_Area ===\n")
print(round(std_coeffs_area, 3))
cat("\nThe most negative value = strongest contributor to decrease in Lake Area.\n\n")


df_std_level <- lake_contribute %>%
  mutate(across(c(water_level, Agri_Area:Population), ~ as.numeric(scale(.))))

model_std_level <- lm(water_level ~ Agri_Area + Rainfall + Temperature +
                        Soil_Moisture + Dam_Capacity + Population,
                      data = df_std_level)

std_coeffs_level <- coef(model_std_level)[-1] %>%
  sort(decreasing = TRUE)

cat("=== Standardized Coefficients – water_level ===\n")
print(round(std_coeffs_level, 3))
cat("\nThe most negative value = strongest contributor to decrease in water_level.\n")

std_long <- bind_rows(
  enframe(std_coeffs_area, name = "Predictor", value = "Beta") %>% mutate(Target = "Lake_Area"),
  enframe(std_coeffs_level, name = "Predictor", value = "Beta") %>% mutate(Target = "water_level")
)

std_table <- std_long %>%
  pivot_wider(
    names_from  = Target,
    values_from = Beta,
    values_fill = NA_real_          
  ) %>%
  column_to_rownames("Predictor") %>% 
  round(3)

# Print nicely
print(std_table)




















