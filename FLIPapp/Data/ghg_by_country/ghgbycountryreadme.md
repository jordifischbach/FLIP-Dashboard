# Greenhouse gas emissions - Data package

This data package contains the data that powers the chart ["Greenhouse gas emissions"](https://ourworldindata.org/grapher/total-ghg-emissions?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website. It was downloaded on June 24, 2025.

### Active Filters

A filtered subset of the full data was downloaded. The following filters were applied:

## CSV Structure

The high level structure of the CSV file is that each row is an observation for an entity (usually a country or region) and a timepoint (usually a year).

The first two columns in the CSV file are "Entity" and "Code". "Entity" is the name of the entity (e.g. "United States"). "Code" is the OWID internal entity code that we use if the entity is a country or region. For normal countries, this is the same as the [iso alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code of the entity (e.g. "USA") - for non-standard countries like historical countries these are custom codes.

The third column is either "Year" or "Day". If the data is annual, this is "Year" and contains only the year as an integer. If the column is "Day", the column contains a date string in the form "YYYY-MM-DD".

The final column is the data column, which is the time series that powers the chart. If the CSV data is downloaded using the "full data" option, then the column corresponds to the time series below. If the CSV data is downloaded using the "only selected data visible in the chart" option then the data column is transformed depending on the chart type and thus the association with the time series might not be as straightforward.

## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc.. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc..

## About the data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stich together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

## Detailed information about the data


## Annual greenhouse gas emissions including land use
[Greenhouse gas emissions](#dod:ghgemissions) are measured in tonnes of [carbon dioxide-equivalents](#dod:carbondioxideequivalents) over a 100-year timescale.
Last updated: November 21, 2024  
Next update: November 2025  
Date range: 1850–2023  
Unit: tonnes of CO₂ equivalents  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Jones et al. (2024) – with major processing by Our World in Data

#### Full citation
Jones et al. (2024) – with major processing by Our World in Data. “Annual greenhouse gas emissions including land use” [dataset]. Jones et al., “National contributions to climate change 2024.2” [original data].
Source: Jones et al. (2024) – with major processing by Our World In Data

### Source

#### Jones et al. – National contributions to climate change
Retrieved on: 2024-11-21  
Retrieved from: https://zenodo.org/records/7636699/latest  

#### Notes on our processing step for this indicator
Emissions given in tonnes have been converted to carbon-dioxide equivalents over a 100-year timescale using a conversion factor of 273 for nitrous oxide, 29.8 for methane from fossil sources, and 27.2 for methane from agricultural and land use sources. These factors are taken from the 6th Assessment Report (AR6) of the Intergovernmental Panel on Climate Change (IPCC).


    