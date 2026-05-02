# NOAA Storm Data Analysis (2025)

## Overview
This project analyzes 2025 storm data from the NOAA. The goal is to understand which weather events are most harmful to people, which events happen most often, and which events cause the most economic damage.

## Data Source
The data comes from NOAA Storm Events Database and includes 3 files:
- Storm event details
- Fatality records
- Location data

The datasets are combined using the EVENT_ID variable.

## Questions Answered
1. Which events are most harmful to the population?
2. Which events happen most often?
3. When do the most common events happen?
4. Which events cause the most damage?
5. Which states have the most total damage?

## Tools Used
- R
- dplyr
- ggplot2
- lubridate
- readr

## Findings
- Flash floods caused the most deaths and injuries.
- Thunderstorm winds were the most frequent.
- Weather events are more common in warmer months.
- Flash floods and tornadoes caused the most economic damage.
- Some states experience much higher total storm damage than others.

## How to Run
1. Download the three NOAA CSV files from https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/
2. Update the file path in the R script and R Markdown file
3. Run the R Markdown file in RStudio
4. Knit the file to generate the final report

## Author
Kaden Dixon
