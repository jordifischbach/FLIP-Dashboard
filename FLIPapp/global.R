#####
#install packages
#####
  #data readers
library(readxl)
library(readr)
library(jsonlite)
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
#ghg by sector by country
#####
ghg_sector <- read.csv("https://ourworldindata.org/grapher/co-emissions-by-sector.csv?v=1&csvType=full&useColumnShortNames=true")
#add zeros for all missing data
ghg_sector[is.na(ghg_sector)] <- 0
ghg_sector <- ghg_sector %>%
  rename_with(~ c(
    "Buildings",
    "Industry",
    "Land use change and forestry",
    "Other fuel combustion",
    "Transportation",
    "Manufacturing and construction",
    "Fugitive emissions",
    "Electricity and heat",
    "Aviation and shipping"
  ), .cols = 4:12) %>%
  mutate("Total" = rowSums(across(c(
    "Buildings",
    "Industry",
    "Land use change and forestry",
    "Other fuel combustion",
    "Transportation",
    "Manufacturing and construction",
    "Fugitive emissions",
    "Electricity and heat",
    "Aviation and shipping"
  ))))

#####
#unique lists
#####
#sectors
ghg_sectors <- c( "Buildings",
                  "Industry",
                  "Land use change and forestry",
                  "Other fuel combustion",
                  "Transportation",
                  "Manufacturing and construction",
                  "Fugitive emissions",
                  "Electricity and heat",
                  "Aviation and shipping",
                  "Total")
#countries 
unique_country_names <- c(
  "Afghanistan", "Africa", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Asia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Democratic Republic of Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Europe", "European Union (27)", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "High-income countries", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Low-income countries", "Lower-middle-income countries", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia (country)", "Moldova", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "North America", "North Korea", "North Macedonia", "Norway", "Oceania", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South America", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Upper-middle-income countries", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "World", "Yemen", "Zambia", "Zimbabwe"
)


#####
#OLD: ghg by country
#####
ghg_country <- read_csv("Data/ghg_by_country/ghg_country.csv")
head(ghg_country)

