# Install required packages if not already installed
required_packages <- c("shiny", "shinydashboard", "leaflet", "sf", "dplyr", "readxl", "readr", "tidygeocoder")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

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
  "Buildings" = "brown",
  "Industry" = "blue"
)

# Create color function
get_sector_color <- function(sector) {
  if (!is.null(sector_colors[[sector]])) {
    sector_colors[[sector]]
  } else {
    "black"  # fallback color if sector not found
  }
}


# UI
ui <- dashboardPage(
  # Dashboard header
  dashboardHeader(
    title = "FLIP Dashboard"
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
      
      # Project description
      div(
        style = "color: #ecf0f1; text-align: left; margin-bottom: 15px;",
        p("Short description of the project goes here.")
      ),
      
      # Dotted line separator
      hr(style = "border-top: 2px dotted #7f8c8d; margin: 20px 0;"),
      
      # Tool description
      div(
        style = "color: #ecf0f1; text-align: left;",
        p("This interactive world map displays FLIP case study locations with color-coded markers representing different sectors. Click on any marker to view detailed information about each case study.")
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
        title = "FLIP Case Studies World Map",
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
    
    # Debug: Print flip_sf structure
    print(paste("flip_sf has", nrow(flip_sf), "rows"))
    print(head(flip_sf))
    
    # Extract coordinates from sf geometry
    coords <- st_coordinates(flip_sf)
    
    # Create dataframe with coordinates
    flip_df <- flip_sf %>%
      st_drop_geometry() %>%
      mutate(
        longitude = coords[,1],
        latitude = coords[,2],
        color = sapply(Sector, get_sector_color)
      )
    
    # Debug: Print processed data
    print("Processed flip_df:")
    print(head(flip_df))
    
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
        color = ~color,
        fillColor = ~color,
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