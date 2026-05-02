# NOAA Storm Database Analysis
# Data Source: NOAA Storm Events 2025
# Author: Kaden Dixon

# Load required libraries
library(dplyr)
library(lubridate)
library(readr)

# Folder path
folder_path <- "C:/Users/25kdi/Downloads/NOAA_Data"

# File paths
details <- read_csv(file.path(folder_path, "StormEvents_details-ftp_v1.0_d2025_c20260323.csv"))
fatalities <- read_csv(file.path(folder_path, "StormEvents_fatalities-ftp_v1.0_d2025_c20260323.csv"))
locations <- read_csv(file.path(folder_path, "StormEvents_locations-ftp_v1.0_d2025_c20260323.csv"))

# Get fatalities per event
fatality_counts <- fatalities %>%
  group_by(EVENT_ID) %>%
  summarise(FATALITY_COUNT = n())

# Merge data
merged_data <- details %>%
  left_join(locations, by = "EVENT_ID") %>%
  left_join(fatality_counts, by = "EVENT_ID")

merged_data$FATALITY_COUNT[is.na(merged_data$FATALITY_COUNT)] <- 0

# Get health impact
merged_data$TOTAL_HEALTH_IMPACT <- merged_data$DEATHS_DIRECT + merged_data$INJURIES_DIRECT

# Get date and month
merged_data$BEGIN_DATE <- as.Date(merged_data$BEGIN_DATE_TIME, "%d-%b-%y %H:%M:%S")
merged_data$MONTH <- month(merged_data$BEGIN_DATE)

# Damage conversion
convert_damage <- function(x) {
  # Remove everything except numbers and decimal points
  num <- as.numeric(gsub("[^0-9.]", "", x))
  
  # Replace na values with 0
  num[is.na(num)] <- 0
  
  # Find scale multiplier based on ending letter (e.g. K = thousands)
  multiplier <- ifelse(grepl("K", x), 1000,
                       ifelse(grepl("M", x), 1000000,
                              ifelse(grepl("B", x), 1000000000, 1)))
  
  # Final damage value
  num * multiplier
}

merged_data$DAMAGE_PROPERTY_NUM <- convert_damage(merged_data$DAMAGE_PROPERTY)
merged_data$DAMAGE_CROPS_NUM <- convert_damage(merged_data$DAMAGE_CROPS)

# Q1: Health impact
health_impact <- merged_data %>%
  group_by(EVENT_TYPE) %>%
  summarise(
    deaths = sum(DEATHS_DIRECT, na.rm = TRUE),
    injuries = sum(INJURIES_DIRECT, na.rm = TRUE),
    total = sum(TOTAL_HEALTH_IMPACT, na.rm = TRUE)
  )

health_impact <- health_impact[order(-health_impact$total), ][1:10, ]

print("TOP HARMFUL EVENTS")
print(health_impact)

# Q2: Event frequency
event_frequency <- merged_data %>%
  group_by(EVENT_TYPE) %>%
  summarise(count = n())

event_frequency <- event_frequency[order(-event_frequency$count), ][1:10, ]

print("TOP EVENT TYPES")
print(event_frequency)

# Q3: Monthly patterns (top 5 events)
top_events <- event_frequency$EVENT_TYPE[1:5]

monthly_patterns <- merged_data[merged_data$EVENT_TYPE %in% top_events, ]

monthly_patterns <- monthly_patterns %>%
  group_by(EVENT_TYPE, MONTH) %>%
  summarise(count = n())

# Q4: Damage by event
damage_by_event <- merged_data %>%
  group_by(EVENT_TYPE) %>%
  summarise(
    property = sum(DAMAGE_PROPERTY_NUM, na.rm = TRUE) / 1e6,
    crops = sum(DAMAGE_CROPS_NUM, na.rm = TRUE) / 1e6
  )

damage_by_event$total <- damage_by_event$property + damage_by_event$crops
damage_by_event <- damage_by_event[order(-damage_by_event$total), ][1:10, ]

print("TOP DAMAGE EVENTS")
print(damage_by_event)

# Damage by state
damage_by_state <- merged_data %>%
  group_by(STATE) %>%
  summarise(total_damage = sum(DAMAGE_PROPERTY_NUM + DAMAGE_CROPS_NUM, na.rm = TRUE) / 1e6)

damage_by_state <- damage_by_state[order(-damage_by_state$total_damage), ][1:10, ]

print("TOP STATES BY DAMAGE")
print(damage_by_state)

# Summary
cat("SUMMARY\n")
cat("Most harmful event:", health_impact$EVENT_TYPE[1], "\n")
cat("Most frequent event:", event_frequency$EVENT_TYPE[1], "\n")
cat("Top damage event:", damage_by_event$EVENT_TYPE[1], "\n")

# Check the raw damage values for Flash Flood events
flash_flood_damage <- merged_data %>%
  filter(EVENT_TYPE == "Flash Flood") %>%
  select(DAMAGE_PROPERTY, DAMAGE_PROPERTY_NUM)

# See the highest damage values
head(flash_flood_damage[order(-flash_flood_damage$DAMAGE_PROPERTY_NUM), ], 20)