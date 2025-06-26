rm(list=ls())

# Load required libraries
library(dplyr)
library(lubridate)
library(tidyr)
library(stringr)
library(purrr)
library(ggplot2)

set.seed(2025)  # For reproducibility

# Parameters
n_wells <- 500
start_date <- ymd("2025-01-01")
end_date <- ymd("2025-06-30")
date_range <- seq.Date(start_date, end_date, by = "day")
n_days <- length(date_range)

# PDO Field and Zones
fields <- c("Qarn Alam", "Marmul", "Yibal", "Lekhwair", "Amal")
zones <- c("North", "South", "East", "West", "Central")

# Generate well IDs and metadata
well_ids <- paste0("PDO-", str_pad(1:n_wells, 4, pad = "0"))

well_metadata <- tibble(
  Well_ID = well_ids,
  Field_Name = sample(fields, n_wells, replace = TRUE),
  Zone = sample(zones, n_wells, replace = TRUE),
  Lat = jitter(rep(21 + runif(1), n_wells), amount = 1.2),   # Typical Omani latitudes
  Long = jitter(rep(56 + runif(1), n_wells), amount = 1.5),  # Typical Omani longitudes
  Start_Date = sample(seq.Date(ymd("2024-06-01"), ymd("2025-01-01"), by = "day"), n_wells, replace = TRUE)
)

# Define the core data generation function
generate_well_data <- function(well_row) {
  with(well_row, {
    
    days <- seq.Date(start_date, end_date, by = "day")
    well_age <- as.integer(days - Start_Date)
    
    # Base production rate with milder decline and operational variances
    oil_base <- rnorm(1, mean = 1500, sd = 200)  # More modest than Ghawar
    daily_var <- rnorm(n_days, 0, 50)
    trend <- sin(seq(0, 2 * pi, length.out = n_days)) * 100  # seasonal/ops
    oil_rate <- pmax(oil_base + daily_var + trend - 0.1 * well_age, 0)
    
    # Choke size with operational control
    choke_options <- c(24, 28, 32, 36)
    choke_size <- sample(choke_options, n_days, replace = TRUE)
    
    # Pressure regimes
    thp <- pmax(1800 + rnorm(n_days, 0, 100) - 0.3 * well_age, 500)
    bhp <- thp + runif(n_days, 700, 1500)
    
    # Gas Rate: moderate gas-oil ratio
    gas_rate <- oil_rate * runif(1, 0.5, 1.0) + rnorm(n_days, 0, 80)
    
    # Water rate: gradually increasing
    water_rate <- 100 + well_age * runif(1, 0.4, 1.0) + rnorm(n_days, 0, 20)
    
    # Ratios
    gor <- ifelse(oil_rate > 0, gas_rate / oil_rate, 0)
    water_cut <- pmin(100, 100 * (water_rate / (oil_rate + water_rate)))
    
    # Uptime
    uptime <- pmax(85, 100 - rbinom(n_days, 1, 0.01) * runif(n_days, 0, 15))
    
    # NPT events
    npt_types <- c("None", "Pump Failure", "Sand Influx", "Tubing Leak", "Compressor Trip")
    npt_probs <- c(0.96, 0.01, 0.01, 0.01, 0.01)
    npt_event <- sample(npt_types, n_days, replace = TRUE, prob = npt_probs)
    
    # Status
    status <- ifelse(oil_rate < 50 | uptime < 85, "Intervention", "Producing")
    status[uptime < 60] <- "Shut-in"
    
    # New: Well Integrity Score and Risk Indicator
    pressure_diff <- bhp - thp
    vibration <- rnorm(n_days, mean = 1.5, sd = 0.5)  # Synthetic vibration sensor
    integrity_score <- pmin(100, 100 - 0.05 * pressure_diff + rnorm(n_days, 0, 5) - 2 * vibration)
    
    risk_level <- case_when(
      integrity_score > 85 ~ "Low",
      integrity_score > 60 ~ "Medium",
      TRUE ~ "High"
    )
    
    tibble(
      Date = days,
      Well_ID = Well_ID,
      Field_Name = Field_Name,
      Zone = Zone,
      Lat = Lat,
      Long = Long,
      Well_Age = well_age,
      Choke_Size = choke_size,
      THP = round(thp, 1),
      BHP = round(bhp, 1),
      Oil_Rate = round(oil_rate, 1),
      Gas_Rate = round(gas_rate, 1),
      Water_Rate = round(water_rate, 1),
      GOR = round(gor, 2),
      Water_Cut = round(water_cut, 2),
      Uptime = round(uptime, 1),
      NPT_Event = npt_event,
      Status = status,
      Drawdown = round(pressure_diff, 1),
      Efficiency_Index = ifelse(pressure_diff > 0, round(oil_rate / pressure_diff, 2), NA),
      Vibration = round(vibration, 2),
      Integrity_Score = round(integrity_score, 1),
      Risk_Level = risk_level
    )
  })
}

# Generate dataset
full_data <- well_metadata %>%
  split(.$Well_ID) %>%
  map_dfr(generate_well_data)

# Save to CSV
setwd("~/Desktop/GitHub/Petroleum_Analysis")
write.csv(full_data, "synthetic_pdo_data_2025.csv", row.names = FALSE)

