#####
#install packages
#####
  #data readers
library(readxl)
library(readr)
  #geodata
library(sf) #spatial data functions
library(tidygeocoder) #address to coordinates
library(dplyr) #data wrangling
#####
##FLIP case studies
#####
flip <- read_csv("Data/FLIP_case_studies/FLIP_case_studies_map_data.csv")
head(flip)
  #Geocode location data
flip_geo <- flip %>%
  geocode(address = Location, method = "osm", lat = latitude, long = longitude) %>%
  mutate(latitude = if_else(Title == "Maya Biosphere Reserve", 17.479444, latitude),
         longitude = if_else(Title == "Maya Biosphere Reserve", -89.969444, longitude))
  

  #convert to sf object
flip_sf <- st_as_sf(flip_geo, coords = c("longitude", "latitude"), crs = 4326)



#####
#ghg by sector
#####
ghg_sector <- read_csv("Data/ghg_by_sector/ghg_sector.csv")
head(ghg_sector)


#####
#ghg by country
#####
ghg_country <- read_csv("Data/ghg_by_country/ghg_country.csv")
head(ghg_country)

