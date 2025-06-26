# PDO Production Dashboard

This repository contains code that simulates realistic well-level production data for PDO (Petroleum Development Oman) and builds an interactive Shiny web dashboard for dynamic field and well monitoring. The app allows exploration of synthetic oilfield metrics such as oil, gas, water production, GOR, well integrity, and operational risk levels.

**The dashboard is hosted via ShinyApps.io and can be accessed at: [https://ibrahimjahwari.shinyapps.io/PDO_Dashboard/]**

This project is aimed to assist petroleum engineers in monitoring various production and safety metics in aid in field surveillance and predictive analytics.

## Description

This project simulates and visualizes synthetic well-level production data for onshore fields modeled after PDO assets in Oman. The dataset contains daily records from January to June 2025 for 500 wells across five fields. Each well is assigned a start date, zone, and location, and is monitored across a set of key technical and operational parameters.

Key Variables:

- Oil_Rate / Gas_Rate / Water_Rate: Daily production volumes in standard units. These form the core performance metrics and are used to monitor well productivity and fluid composition.
- THP / BHP / Drawdown: Surface and bottomhole pressures used to assess inflow performance and artificial lift requirements. Drawdown is calculated as the difference between BHP and THP.
- GOR (Gas-Oil Ratio): Indicates reservoir drive mechanism and separation challenges. Useful for flagging gas breakthrough or evolving reservoir conditions.
- Water_Cut: Percentage of produced fluids that is water. A key metric for late-life wells, water handling, and reservoir management.
- Choke_Size: Reflects surface control settings. Changes may relate to flow restrictions, optimization efforts, or interventions.
- Uptime: Percent of day the well is online. Decreases often point to equipment failure, deferred production, or scheduled maintenance.
- NPT_Event: Categorized non-productive time events such as pump failure or tubing leak. These are used to understand downtime causes and reliability issues.
- Efficiency_Index: Oil rate divided by drawdown. Provides a proxy for well inflow efficiency.
- Vibration: Synthetic vibration signal representing mechanical stress or instability in surface/subsurface equipment.
- Integrity_Score: Derived score reflecting well integrity based on pressure differential and vibration. Lower scores indicate greater operational risk.
- Risk_Level: Categorical variable ("Low", "Medium", "High") based on integrity score thresholds. Designed to support safety and monitoring workflows.

The Shiny app allows users to filter wells by field and zone, choose metrics to visualize, and explore trends interactively. KPIs summarize latest values across selected wells, and a table view supports inspection of raw time-series data. The full dataset can support further modeling and forecasting use cases.


## Repository Structure

```
PDO_Production_Dashboard/
├── app.R                        # Shiny dashboard application (ready to deploy)
├── data_simulation.R            # Full script to generate synthetic well data
├── synthetic_pdo_data_2025.csv  # Simulated dataset used by the dashboard
├── LICENSE                      # MIT License
└── README.md                    # Project overview and documentation
```


## How to Reproduce

1. Clone this repository  
2. Run `data_simulation.R` to (re)generate the synthetic dataset
3. Launch the `app.R` via RStudio
4. To deploy to ShinyApps.io:
    - Ensure `app.R` and `synthetic_pdo_data_2025.csv` are in the same folder
    - Publish using the "Publish App" button in RStudio


## Software Requirements

This project uses R (version 4.0 or later) and the following R packages: `shiny`,`shinyWidgets`, `plotly`, `DT`, `dplyr`,  `tidyr`, `lubridate`, `purrr`,  `ggplot2`, `stringr`


## Future Extensions

- Well location maps 
- Forecasting of production metrics
- Clustering of well profiles
- Risk prediction using ML models


## License

This project is released under the MIT License. See the `LICENSE` file for details.

## Author

Ibrahim Al Jahwari

Contact: ibrahim.aljahwari23.19@takatufscholars.om


