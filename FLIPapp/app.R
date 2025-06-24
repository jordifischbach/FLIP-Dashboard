#####
#Packages
library(shiny)
library(bslib)
library(leaflet)
library(sf)
library(dplyr)
#####

# Define color palette for sectors
sector_colors <- list(
  "Land Use" = "green",
  "Energy" = "yellow", 
  "Food and Agriculture" = "red",
  "Buildings" = "brown",
  "Industry" = "purple"
)

# Create color function
get_sector_color <- function(sector) {
  return(sector_colors[[sector]] %||% "blue")
}

#####
# UI
#####
ui <- page_sidebar(
  title = "FLIP Dashboard",
  sidebar = sidebar(
    width = 300,
    open = TRUE,
    # Title with leaf icon
    div(
      style = "display: flex; align-items: center; margin-bottom: 15px;",
      icon("leaf", style = "color: green; margin-right: 10px; font-size: 20px;"),
      h3("FLIP", style = "margin: 0;")
    ),
    
    # Project description
    p("Short description of the project goes here."),
    
    # Dotted line separator
    hr(style = "border-top: 2px dotted #ccc; margin: 20px 0;"),
    
    # Tool description
    p("This interactive world map displays FLIP case study locations with color-coded markers representing different sectors. Click on any marker to view detailed information about each case study.")
  ),
  
  # Main panel with map
  card(
    full_screen = TRUE,
    card_header("FLIP Case Studies World Map"),
    card_body(
      leafletOutput("world_map", height = "600px")
    )
  )
)

# Server
server <- function(input, output, session) {
  
  output$world_map <- renderLeaflet({
    # Extract coordinates from sf geometry
    coords <- st_coordinates(flip_sf)
    flip_df <- flip_sf %>%
      st_drop_geometry() %>%
      mutate(
        longitude = coords[,1],
        latitude = coords[,2],
        color = sapply(Sector, get_sector_color)
      )
    
    # Create base map
    map <- leaflet(flip_df) %>%
      addTiles() %>%
      setView(lng = 0, lat = 20, zoom = 2)
    
    # Add markers for each case study
    for(i in 1:nrow(flip_df)) {
      map <- map %>%
        addCircleMarkers(
          lng = flip_df$longitude[i],
          lat = flip_df$latitude[i],
          popup = paste0(
            "<strong>", flip_df$Title[i], "</strong><br/>",
            "<em>", flip_df$Location[i], "</em><br/>",
            "<strong>Sector:</strong> ", flip_df$Sector[i], "<br/><br/>",
            flip_df$Summary[i]
          ),
          color = flip_df$color[i],
          fillColor = flip_df$color[i],
          radius = 8,
          weight = 2,
          opacity = 0.8,
          fillOpacity = 0.6
        )
    }
    
    # Add legend
    map %>%
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
