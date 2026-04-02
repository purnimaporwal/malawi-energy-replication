######################################################################
# Section B: Data Scraping — PM2.5 Air Quality, India (Jan 1, 2025)
# Scraping and processing of PM2.5 concentration data for 10 Indian
# cities from the Central Pollution Control Board (CPCB) portal.
#
# Author:  Purnima Porwal
# Date:    January 2026
# Task:    RA Assessment — Section B (Data Scraping)
# GitHub:  github.com/purnimaporwal/malawi-energy-replication
######################################################################

# ── CHANGE THIS ONE PATH TO MATCH YOUR COMPUTER ──────────────────
# Mac / Linux users:
BASE_FOLDER <- "/Users/purnimaporwal/Downloads/malawi-energy-replication"
 
# Windows users — uncomment this line instead:
# BASE_FOLDER <- "C:/Users/yourname/Downloads/malawi-energy-replication"
# ─────────────────────────────────────────────────────────────────

# All paths build automatically from BASE_FOLDER — no other changes needed
DATA_SCRAPPING <- file.path(BASE_FOLDER, "Data_Scrapping")
OUTPUT        <- file.path(BASE_FOLDER, "output")
 
# Create output folder if it does not exist
if (!dir.exists(OUTPUT)) dir.create(OUTPUT, recursive = TRUE)

######################## Section B ##############################
# checking working directory
getwd() 

# SECTION B: DATA SCRAPPING AND PROCESSING


# ── PACKAGES ──────────────────────────────────────────────────────
# Run install.packages() once if not already installed:
# install.packages(c("dplyr", "readr"))

# Load necessary libraries
library(dplyr)
library(readr)

 
# ── METHODOLOGY NOTE ──────────────────────────────────────────────
# The CPCB Central Control Room portal (app.cpcbccr.com) uses dynamic
# JavaScript layers and session-based tokens that resist standard
# rvest/read_html automated scraping approaches.
#
# For this assessment I performed a targeted manual scrape:
# 1. Queried the 24-hour daily average PM2.5 for 10 geographically
#    diverse Indian cities on 1 January 2025
# 2. Extracted the verified daily mean (µg/m³) for each city
# 3. Formatted the data into a research-ready CSV for reproducibility
#
# The R code below cleans the manually collected CSV and computes
# a 10-city national average PM2.5 concentration.


# ── LOAD RAW DATA ─────────────────────────────────────────────────
# Loading the scrapped dataset 
# Ensure the CSV file is in the same working directory as this script.
# To make sure the loaded data is correct (skipping the title row)

# skip = 1 because the CSV has a title 'row before the column headers'
# Note: Ensuring the file path matches the folder structure
CPCB2025_raw <- read_csv(file.path(DATA_SCRAPPING, "CPCB_data_Sheet.csv"), skip = 1)

# check the loaded data
dim(CPCB2025_raw)
names(CPCB2025_raw)
head(CPCB2025_raw)
 
# Now clean the data using the CORRECT name
# ── CLEAN DATA ────────────────────────────────────────────────────
# In the CSV, the column is named "PM2.5", not "Value"
CPCB2025_cleaned <- CPCB2025_raw %>%
  filter(!is.na(PM2.5)) %>% 
  mutate(
    Parameter = "PM2.5", Unit = "ug/m3")

# check cleaned data
# View the result
View(CPCB2025_cleaned)

# View the data to confirm headers are now correct
CPCB2025_cleaned 

###### ANALYTICAL SUMMARY #########
# ── COMPUTE 10-CITY NATIONAL AVERAGE ─────────────────────────────
# na.rm = TRUE handles any remaining missing values 

# Calculating the average of PM2.5 column for 10-cities for Jan 1, 2025
national_avg <- mean(CPCB2025_cleaned$PM2.5, na.rm = TRUE) # As the data has two empty cells, using NA Remove option to avoid errors in calculation

# Print the result with a nice description and 2 decimal places
print(paste("10-city Daily Average PM2.5 for Jan 1, 2025:", round(national_avg, 2), "ug/m3"))

# ── SAVE OUTPUT ───────────────────────────────────────────────────
# EXPORT FINAL DATASET
write_csv(CPCB2025_cleaned,
          file.path(OUTPUT, "Final_Scrapped_Data_Purnima.csv"))

cat("Scraped data saved to:", OUTPUT, "\n")