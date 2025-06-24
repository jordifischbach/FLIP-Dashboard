# Load required libraries
library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(dplyr)
library(readxl)
library(readr)
library(tidygeocoder)



# Define color palette for sectors
sector_colors <- list(
  "Land Use" = "green",
  "Energy" = "gold", 
  "Food and Agriculture" = "red",
  "Buildings" = "grey",
  "Industry" = "purple",
  "Transportation" = "blue"
)

# UI
ui <- dashboardPage(
  # Dashboard header
  dashboardHeader(
    title = "FLIP: Co-Benefits of Climate Action"
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
        h3("FLIP", style = "margin: 0; color: white;")
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
      
      # Tool description
      div(
        style = "color: #ecf0f1; text-align: left;",
        p("This interactive world map displays FLIP case study locations with color-coded markers representing different sectors. Click on any marker to view detailed information about each case study. Read the full report here [url]")
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
    
    # Main content with map
    fluidRow(
      box(
        title = "FLIP Case Studies",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        height = "700px",
        leafletOutput("world_map", height = "600px")
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
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
}

# Run the application
shinyApp(ui = ui, server = server)
