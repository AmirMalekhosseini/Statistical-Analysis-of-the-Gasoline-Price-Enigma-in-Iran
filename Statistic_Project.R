# FINAL PROJECT: GASOLINE PRICE & TRAFFIC ANALYSIS

# Amir Malekhosseini

# Topic: The Gasoline Price & Traffic Puzzle in Iran (1370-1402)
# Objective: Analyze if price hikes effectively reduce traffic using R.
#
# INCLUDES:
# 1. Full 33-year Data Generation.
# 2. Data Wrangling & Outlier Detection.
# 3. EDA: Boxplot, Histogram, Scatter Plot, Time Series Trend.
# 4. Inference: Confidence Intervals & Hypothesis Testing.
# 5. Simple Regression (Correlation & Simple LM).
# 6. Multiple Regression (Full Model & VIF).
# 7. Model Selection (Stepwise AIC).
# 8. Diagnostics (Normality, Homoscedasticity, 4-Plot Grid).
# 9. Prediction (Scenario: Double Price in 1403).

# 1) SETUP & LIBRARIES
pkgs <- c("ggplot2", "lmtest", "car")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages(to_install)

library(ggplot2)
library(lmtest)
library(car)

# 2) DATA ENTRY (Actual Data from Appendix A)
years <- 1370:1402

# Hard-coded values 
nominal_price <- c(5, 5, 5, 5, 10, 10, 10, 10, 10, 10, 10, 10, 10, 
                   80, 80, 80, 400, 400, 400, 700, 700, 700, 700, 
                   1000, 1000, 1000, 1000, 1000, 3000, 3000, 3000, 3000, 3000)

inflation <- c(17.1, 24.4, 22.9, 35.2, 49.4, 23.2, 17.3, 18.1, 20.1, 12.6, 
               11.4, 15.8, 15.6, 15.2, 10.4, 11.9, 18.4, 25.4, 10.8, 12.4, 
               21.5, 30.5, 34.7, 15.6, 11.9, 9.0, 9.6, 31.2, 41.2, 36.4, 
               43.4, 45.8, 44.6)

# ACTUAL Traffic Index 
traffic_index <- c(19.2, 20.4, 23.9, 22.4, 23.3, 26.5, 25.3, 23.6, 25.1, 
                   26.4, 29.7, 29.1, 30.0, 30.3, 30.1, 34.5, 28.4, 30.3, 
                   35.1, 30.0, 34.1, 36.1, 35.6, 37.0, 37.8, 37.0, 41.6, 
                   41.2, 29.8, 26.9, 28.6, 37.5, 43.3)

# Create DataFrame
project_data <- data.frame(
  Year = years,
  Nominal_Price = nominal_price,
  Inflation = inflation,
  Traffic_Index = traffic_index
)

# 3) FEATURE ENGINEERING

# Structural Breaks (Policy Shocks)
project_data$Shock_2007 <- ifelse(project_data$Year >= 1386, 1, 0) # Smart Card
project_data$Shock_2010 <- ifelse(project_data$Year >= 1389, 1, 0) # Subsidies
project_data$Shock_2019 <- ifelse(project_data$Year >= 1398, 1, 0) # Aban 98

# Covid Dummy (Specific years 1399-1400)
project_data$Covid_Period <- ifelse(project_data$Year %in% c(1399, 1400), 1, 0)

# Time Trend (Proxy for Vehicle Stock Growth)
project_data$Time_Trend <- project_data$Year - min(project_data$Year)

# Real Price Index (Inflation Adjusted)
# Formula: Nominal / Cumulative Inflation
project_data$CPI_Cumulative <- cumprod(1 + project_data$Inflation/100)
project_data$Real_Price_Index <- (project_data$Nominal_Price / project_data$CPI_Cumulative) * 100

# 4) WRANGLING & EDA 
print(" 1. WRANGLING & EDA ")
print(summary(project_data))

# Plot 1: Boxplot (Distribution & Outliers)
png("1_Boxplot_Traffic.png")
boxplot(project_data$Traffic_Index, main="Traffic Index Distribution", col="lightblue")
dev.off()

# Plot 2: Histogram (Normality Check)
png("2_Histogram_Traffic.png")
hist(project_data$Traffic_Index, 
     main="Histogram of Traffic Index", 
     xlab="Traffic Index", 
     col="lightgreen", 
     breaks=8)
dev.off()

# Plot 3: Scatter Plot (Traffic vs Real Price)
png("3_Scatter_Price_vs_Traffic.png")
plot(project_data$Real_Price_Index, project_data$Traffic_Index,
     main="Scatter Plot: Traffic vs. Real Price",
     xlab="Real Price Index (Inflation Adjusted)",
     ylab="Traffic Index",
     pch=19, col="blue")
abline(lm(Traffic_Index ~ Real_Price_Index, data=project_data), col="red", lwd=2)
dev.off()

# Plot 4: Time Series Trend (Traffic vs Shocks)
p_trend <- ggplot(project_data, aes(x=Year, y=Traffic_Index)) +
  geom_line(size=1.2, color="darkblue") +
  geom_vline(xintercept=c(1386, 1389, 1398), linetype="dashed", color="red") +
  annotate("text", x=1386, y=45, label="2007 Shock", angle=90, vjust=-0.5) +
  annotate("text", x=1398, y=45, label="2019 Shock", angle=90, vjust=-0.5) +
  labs(title="Traffic Index Trends & Price Shocks (1370-1402)", 
       subtitle="Red lines indicate major gasoline price hikes",
       y="Traffic Index") +
  theme_minimal()
ggsave("4_Traffic_Trend.png", p_trend, width=8, height=5)

# 5) SIMPLE REGRESSION
print(" 2. SIMPLE REGRESSION & CORRELATION ")

# Correlation Matrix
num_cols <- project_data[, c("Traffic_Index", "Real_Price_Index", "Inflation", "Time_Trend")]
print("Correlation Matrix:")
print(round(cor(num_cols), 2))

# Simple Linear Model: Traffic ~ Real Price
simple_model <- lm(Traffic_Index ~ Real_Price_Index, data = project_data)
print("Simple Regression Summary:")
print(summary(simple_model))

# 6) MULTIPLE REGRESSION 
print(" 3. MULTIPLE REGRESSION ")

full_model <- lm(Traffic_Index ~ Real_Price_Index + Inflation + Time_Trend + 
                   Shock_2007 + Shock_2019 + Covid_Period, 
                 data = project_data)

print(summary(full_model))

# Check for Multicollinearity (VIF)
print("VIF Values:")
if(length(coef(full_model)) < nrow(project_data)){
  print(vif(full_model))
} else {
  print("Warning: Sample size too small for VIF.")
}

# 7) MODEL SELECTION (Stepwise AIC)
print(" 4. MODEL SELECTION ")

# Backward/Forward Stepwise Selection
final_model <- step(full_model, direction="both", trace=0)
print("Final Selected Model Summary:")
print(summary(final_model))
# Check VIF for the final Stepwise model to confirm multicollinearity is solved
vif(final_model)

# 8) DIAGNOSTICS
print(" 5. MODEL DIAGNOSTICS ")

# Normality of Residuals
shapiro_test <- shapiro.test(residuals(final_model))
print(paste("Shapiro-Wilk P-Value:", round(shapiro_test$p.value, 4)))

# Homoscedasticity (Breusch-Pagan)
bp_test <- bptest(final_model)
print(paste("Breusch-Pagan P-Value:", round(bp_test$p.value, 4)))

# Plot 5: Diagnostic Grid (4 Plots in 1)
png("5_Diagnostics_Grid.png", width=800, height=600)
par(mfrow=c(2,2))
plot(final_model)
dev.off()

# 9) PREDICTION & CONCLUSION
print(" 6. PREDICTION ANALYSIS")

# Scenario: Predict Traffic if Real Price doubles next year (1403)
# Assumptions: Inflation=40%, Trend continues, No new shock, No Covid
last_row <- tail(project_data, 1)

# Create new data frame for prediction
# We use the selected model's variables. If step() removed some, predict() handles it.
new_data <- data.frame(
  Real_Price_Index = last_row$Real_Price_Index * 2, # Doubling Real Price
  Inflation = 40,
  Time_Trend = last_row$Time_Trend + 1,
  Shock_2007 = 1,
  Shock_2010 = 1,
  Shock_2019 = 1,
  Covid_Period = 0
)

# Confidence Interval for Mean Response
predicted_traffic <- predict(final_model, newdata = new_data, interval="confidence")

print(" Predicted Traffic Index for 1403 (Double Real Price):")
print(predicted_traffic)

print("PROJECT COMPLETE: All files saved to working directory.")


# 10) CROSS-SECTIONAL ANALYSIS (Cities Comparison 1402)
print(" 7. CITY COMPARISON (CROSS-SECTIONAL) ")

# Data from Appendix B (Table 3)
cities_data <- data.frame(
  City = c("Tehran", "Mashhad", "Isfahan", "Shiraz", "Tabriz"),
  Population_Millions = c(9.0, 3.0, 2.0, 1.6, 1.6),
  Metro_Ridership_M = c(820, 47, 18, 18, 11)
)

# Calculate Ridership per Capita (Riders / Population)
cities_data$Ridership_Per_Capita <- cities_data$Metro_Ridership_M / cities_data$Population_Millions

# Comparative Public Transport Efficiency
p_cities <- ggplot(cities_data, aes(x=reorder(City, -Ridership_Per_Capita), y=Ridership_Per_Capita, fill=City)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(Ridership_Per_Capita, 1)), vjust=-0.5) +
  labs(title="Public Transport Efficiency (1402)", 
       subtitle="Annual Metro Trips per Capita (Indicator of Substitutes)",
       y="Trips per Person per Year",
       x="Metropolis") +
  theme_minimal() +
  scale_fill_brewer(palette="Set3")

ggsave("6_City_Comparison.png", p_cities, width=8, height=5)
print("Saved 6_City_Comparison.png")