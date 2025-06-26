# Load required libraries
library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(dplyr)
library(readxl)
library(readr)
library(tidygeocoder)
library(ggplot2)
library(tidyr)

# Define color palette for sectors
sector_colors <- list(
  "Land Use" = "green",
  "Energy" = "gold", 
  "Food and Agriculture" = "red",
  "Buildings" = "grey",
  "Industry" = "purple",
  "Transportation" = "blue"
)
#####
# UI
#####
ui <- dashboardPage(
  # Dashboard header
  dashboardHeader(
    title = "FLIP"
  ),
  
  # Dashboard sidebar
  dashboardSidebar(
    width = 300,
    # Title with leaf icon
    div(
      style = "padding: 15px; text-align: center;",
      div(
        style = "display: flex; align-items: center; justify-content: center; margin-bottom: 15px;",
        icon("leaf", style = "color: green; margin-right: 10px; font-size: 20px;"),
        h3("FLIP: Co-Benefits of Climate Action", style = "margin: 0; color: white;")
      ),
      
      #subheader FLIP description
      h5("Free, Local, Immediate, and Persuasive (FLIP) Co-Benefits of Climate Action", style = "color: #ecf0f1; margin-top: 0; margin-bottom: 15px;"),
      
      # Project description
      div(
        style = "color: #ecf0f1; text-align: left; margin-bottom: 15px;",
        p("Successful climate change, while a global challenge, will require local solutions to be successful. Historically, climate action has been framed as an expensive distraction from more immediate local goals such as economic development and social prosperity. FLIP seeks to reframe this faulty narrative by demonstrating the economic, environmental, social, and health co-benefits climate action accrues to the local population, while simultaniously decreasing GHG emissions")
      ),
      
      # Dotted line separator
      hr(style = "border-top: 2px dotted #7f8c8d; margin: 20px 0;"),
      
      # Map description
      div(
        style = "color: #ecf0f1; text-align: left;",
        p("This interactive world map displays FLIP case study locations with color-coded markers representing different sectors. Click on any marker to view detailed information about each case study. Read the full report here [url]")
      ),
      
      # Dotted line separator
      hr(style = "border-top: 2px dotted #7f8c8d; margin: 20px 0;"),
      
      # Stacked area description
      div(
        style = "color: #ecf0f1; text-align: left;",
        p("Select countries and sectors to compare emissions data from 1990-2021.")
      ),
      # Dotted line separator
      hr(style = "border-top: 2px dotted #7f8c8d; margin: 20px 0;"),
      
      # Data and AI disclaimer description
      div(
        style = "color: #ecf0f1; text-align: left;",
        p("Emissions data retrieved from Climate Watch (2024) – with major processing by Our World in Data. Learn more about the data at https://ourworldindata.org/co2-and-greenhouse-gas-emissions#explore-data-on-co2-and-greenhouse-gas-emissions. Code was produced with assitance from generative AI, namely ChatGPT and Shiny Assistant.")
      )
    )
  ),
  
  # Dashboard body
  dashboardBody(
    # Custom CSS for better styling
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
        }
      "))
    ),
    
    # Main content with map and chart
    fluidRow(
      # Map column
      column(width = 6,
             box(
               title = "FLIP Case Studies",
               status = "primary",
               solidHeader = TRUE,
               width = 12,
               height = "500px",
               leafletOutput("world_map", height = "450px")
             )
      ),
      
      # Controls and chart column
      column(width = 6,
             # Controls box
             box(
               title = "GHG Emissions Analysis Controls",
               status = "info",
               solidHeader = TRUE,
               width = 12,
               
               
               selectizeInput("countries",
                              "Select Countries:",
                              choices = unique_country_names,
                              multiple = TRUE,
                              options = list(placeholder = 'Select countries...')
               ),
               
               # Sector selection
               
               selectizeInput("sectors",
                              "Select Sectors:",
                              choices = ghg_sectors,
                              multiple = TRUE,
                              options = list(placeholder = 'Select sectors...')
               ),
               
               # Year selection
               
               selectInput("year",
                           "Select Year:",
                           choices = 1990:2021,
                           selected = 2021
               )
             ),
             
             # Chart box
             box(
               title = "GHG Emissions by Sector",
               status = "success",
               solidHeader = TRUE,
               width = 12,
               height = "400px",
               plotOutput("ghg_chart", height = "350px")
             )
      )
    )
  )
)
#####
# Server
#####
server <- function(input, output, session) {
  
  # Initialize selectize inputs
  observe({
    # Prepare country choices with World first, then alphabetical
    country_choices <- sort(unique(ghg_sector$Entity))
    world_index <- which(country_choices == "World")
    if(length(world_index) > 0) {
      country_choices <- c("World", country_choices[-world_index])
    }
    
    updateSelectizeInput(session, "countries",
                         choices = country_choices,
                         selected = "World"
    )
    
    # Prepare sector choices with Total first
    sector_columns <- names(ghg_sector)[4:13]  # columns 4-13
    sector_choices <- c("Total", sector_columns[sector_columns != "Total"])
    
    updateSelectizeInput(session, "sectors",
                         choices = sector_choices,
                         selected = "Total"
    )
    
    # Prepare year choices
    year_choices <- sort(unique(ghg_sector$Year))
    updateSelectInput(session, "year",
                      choices = year_choices,
                      selected = max(year_choices)
    )
  })
  
  output$world_map <- renderLeaflet({
    # Extract coordinates from sf geometry
    coords <- st_coordinates(flip_sf)
    
    # Create dataframe with coordinates
    flip_df <- flip_sf %>%
      st_drop_geometry() %>%
      mutate(
        longitude = coords[,1],
        latitude = coords[,2]
      )
    
    # Create base map
    leaflet(flip_df) %>%
      addTiles() %>%
      setView(lng = 0, lat = 20, zoom = 2) %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        popup = ~paste0(
          "<strong>", Title, "</strong><br/>",
          "<em>", Location, "</em><br/>",
          "<strong>Sector:</strong> ", Sector, "<br/><br/>",
          Summary
        ),
        color = ~Color,
        fillColor = ~Color,
        radius = 8,
        weight = 2,
        opacity = 0.8,
        fillOpacity = 0.6
      ) %>%
      addLegend(
        position = "bottomright",
        colors = unlist(sector_colors),
        labels = names(sector_colors),
        title = "Sector",
        opacity = 0.8
      )
  })
  
  # Reactive data for chart
  chart_data <- reactive({
    req(input$countries, input$sectors, input$year)
    
    # Filter data based on selections
    filtered_data <- ghg_sector %>%
      filter(Entity %in% input$countries) %>%
      select(Entity, Year, all_of(input$sectors))
    
    # Convert to long format for stacking
    long_data <- filtered_data %>%
      pivot_longer(cols = -c(Entity, Year), 
                   names_to = "Sector", 
                   values_to = "Emissions")
    
    return(long_data)
  })
  
  output$ghg_chart <- renderPlot({
    req(chart_data())
    
    data <- chart_data()
    
    if(nrow(data) == 0) {
      return(ggplot() + 
               annotate("text", x = 0.5, y = 0.5, label = "No data available for selected criteria") +
               theme_void())
    }
    
    # Create stacked area chart
    ggplot(data, aes(x = Year, y = Emissions, fill = Sector)) +
      geom_area() +
      facet_wrap(~Entity, scales = "free_y") +
      scale_y_continuous(labels = scales::comma) +
      labs(
        x = "Year",
        y = "Tonnes CO2e",
        title = "GHG Emissions by Sector Over Time"
      ) +
      theme_minimal() +
      theme(
        legend.position = "bottom",
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)
      ) +
      guides(fill = guide_legend(nrow = 2))
  })
}
#####
# Run the application
shinyApp(ui = ui, server = server)
