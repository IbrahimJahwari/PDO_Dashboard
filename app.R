# -------------------------------------------
# Shiny App: Petroleum Production Dashboard
# Author: Ibrahim Al Jahwari
# -------------------------------------------

# ---- Load Libraries ----


# app.R

library(shiny)
library(dplyr)
library(tidyr)
library(plotly)
library(DT)
library(shinyWidgets)
library(lubridate)

# Load the dataset
data <- read.csv("synthetic_pdo_data_2025.csv", stringsAsFactors = FALSE) %>%
  mutate(Date = as.Date(Date))


# UI
ui <- fluidPage(
  titlePanel("PDO Well Performance Dashboard (2025)"),
  
  sidebarLayout(
    sidebarPanel(
      pickerInput("field", "Select Field(s):", 
                  choices = unique(data$Field_Name),
                  selected = unique(data$Field_Name),
                  multiple = TRUE,
                  options = list(`actions-box` = TRUE, `live-search` = TRUE)),
      
      uiOutput("zone_ui"),
      
      uiOutput("well_ui"),
      
      selectInput("metric", "Select Metric:",
                  choices = c("Oil_Rate", "Gas_Rate", "Water_Rate", "GOR", 
                              "Water_Cut", "Uptime", "Efficiency_Index", 
                              "Integrity_Score"),
                  selected = "Oil_Rate"),
      
      dateRangeInput("date", "Select Date Range:",
                     start = min(data$Date), end = max(data$Date),
                     min = min(data$Date), max = max(data$Date)),
      
      checkboxInput("show_table", "Show Raw Table Below", value = FALSE)
    ),
    
    mainPanel(
      plotlyOutput("time_series_plot", height = "400px"),
      plotlyOutput("kpi_summary"),
      conditionalPanel("input.show_table == true",
                       DTOutput("filtered_table"))
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Filter Zones based on Fields
  output$zone_ui <- renderUI({
    req(input$field)
    filtered_zones <- data %>%
      filter(Field_Name %in% input$field) %>%
      pull(Zone) %>%
      unique()
    
    pickerInput("zone", "Select Zone(s):",
                choices = filtered_zones,
                selected = filtered_zones,
                multiple = TRUE,
                options = list(`actions-box` = TRUE, `live-search` = TRUE))
  })
  
  # Filter Wells based on Zones
  output$well_ui <- renderUI({
    req(input$field, input$zone)
    filtered_wells <- data %>%
      filter(Field_Name %in% input$field, Zone %in% input$zone) %>%
      pull(Well_ID) %>%
      unique()
    
    pickerInput("well", "Select Well(s):",
                choices = filtered_wells,
                selected = filtered_wells,
                multiple = TRUE,
                options = list(`actions-box` = TRUE, `live-search` = TRUE))
  })
  
  # Reactive filtered dataset
  filtered_data <- reactive({
    req(input$field, input$zone, input$well)
    
    data %>%
      filter(
        Field_Name %in% input$field,
        Zone %in% input$zone,
        Well_ID %in% input$well,
        Date >= input$date[1],
        Date <= input$date[2]
      )
  })
  
  # Plot
  output$time_series_plot <- renderPlotly({
    df <- filtered_data()
    metric <- input$metric
    
    plot_ly(df, x = ~Date, y = as.formula(paste0("~", metric)), color = ~Well_ID, type = "scatter", mode = "lines") %>%
      layout(title = paste("Time Series of", metric),
             xaxis = list(title = "Date"),
             yaxis = list(title = metric))
  })
  
  # KPI Summary
  output$kpi_summary <- renderPlotly({
    df <- filtered_data()
    latest_data <- df %>%
      filter(Date == max(Date)) %>%
      summarise(
        Avg_Oil = round(mean(Oil_Rate, na.rm = TRUE), 1),
        Avg_WC = round(mean(Water_Cut, na.rm = TRUE), 1),
        Avg_GOR = round(mean(GOR, na.rm = TRUE), 1),
        High_Risk = sum(Risk_Level == "High", na.rm = TRUE)
      )
    
    plot_ly(
      type = 'indicator',
      mode = 'number+delta',
      value = latest_data$Avg_Oil,
      delta = list(reference = 1500),
      title = list(text = "Avg Oil Rate (BOPD)"),
      domain = list(row = 0, column = 0)
    ) %>%
      add_trace(
        type = 'indicator',
        mode = 'number',
        value = latest_data$Avg_WC,
        title = list(text = "Avg Water Cut (%)"),
        domain = list(row = 0, column = 1)
      ) %>%
      add_trace(
        type = 'indicator',
        mode = 'number',
        value = latest_data$Avg_GOR,
        title = list(text = "Avg GOR (scf/bbl)"),
        domain = list(row = 0, column = 2)
      ) %>%
      add_trace(
        type = 'indicator',
        mode = 'number',
        value = latest_data$High_Risk,
        title = list(text = "# High Risk Wells"),
        domain = list(row = 0, column = 3)
      ) %>%
      layout(grid = list(rows = 1, columns = 4), margin = list(t = 20, b = 20))
  })
  
  # Table
  output$filtered_table <- renderDT({
    datatable(filtered_data(), options = list(pageLength = 10))
  })
}

# Run the app
shinyApp(ui, server)
