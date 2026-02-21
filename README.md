# Statistical Analysis of the "Gasoline Price Enigma" in Iran (1370-1402)

## Overview
This project investigates the relationship between gasoline prices and traffic congestion in Iranian metropolises over a 33-year period (1370-1402). Standard economic theory posits that increasing the marginal cost of driving should reduce vehicle-kilometers traveled (VKT). However, historical data from Tehran and other major cities shows that traffic congestion remains resilient despite dramatic state-enforced price hikes. This project utilizes R to analyze this "rebound effect," where traffic congestion inevitably returns to pre-hike levels.

## Key Findings

* **Simpson's Paradox**: A simple linear regression suggests a statistically significant positive relationship between real gasoline prices and traffic ($p=0.038$). However, when controlling for the time trend, the model reveals a statistically significant negative elasticity. 
* **Hidden Factors Dominate**: The upward time trend—acting as a proxy for vehicle stock growth and population increase—vastly overpowers the negative effect of price hikes (Trend coefficient of +0.87 vs. Price coefficient of -0.0030).
* **The Rebound Mechanism**: While major price shocks (such as the 2019 hike) cause significant temporary drops in traffic, the overarching time trend erases these reductions within a few years.
* **Inelastic Demand**: Demand for gasoline remains structurally inelastic due to a severe lack of public transport substitutes. A cross-sectional analysis of 1402 shows that cities like Tabriz and Isfahan severely lag behind in public transit trips per capita, forcing reliance on private vehicles regardless of fuel costs.
* **Future Prediction**: Even under a hypothetical scenario where real prices double, the model predicts a high Traffic Index of 39.39 for the year 1403.

## Methodology
The analysis was conducted entirely in R and structured around the following steps:

1. **Data Aggregation**: Reconstructed a 33-year dataset by combining nominal gasoline prices, Consumer Price Index (CPI) inflation rates, and a composite traffic index.
2. **Feature Engineering**: Engineered a Real Price Index (inflation-adjusted) and binary dummy variables for structural policy shocks (2007 Rationing, 2010 Subsidies, 2019 Aban Shock).
3. **Exploratory Data Analysis (EDA)**: Visualized data distributions and structural breaks using boxplots, histograms, and time-series trend lines.
4. **Multiple Regression Modeling**: Built a full multiple linear regression model to isolate the effect of price:
   $$Y=\beta_{0}+\beta_{1}X_{RealPrice}+\beta_{2}X_{Inflation}+\beta_{3}X_{Trend}+\cdot\cdot\cdot+\epsilon$$ 
5. **Model Selection & Diagnostics**: Utilized Stepwise AIC to refine the model into a "Parsimonious Model," successfully resolving severe multicollinearity issues. Validated the model using Shapiro-Wilk testing for residual normality and Breusch-Pagan testing for homoscedasticity.
6. **Cross-Sectional Analysis**: Analyzed public transport capacity constraints across five major Iranian metropolises to contextualize the inelastic demand.

## Technologies & Libraries Used
* **Language**: R
* **Libraries**: `ggplot2` (Visualization), `lmtest` (Diagnostic testing), `car` (VIF Multicollinearity checks).

## Author
* **Name**: Amir Malekhosseini
