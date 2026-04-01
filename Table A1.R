######################################################################
# Table A1: Annual household expenditure (MWK), panel sample 2010-20
# Replication of Table A1 from: "Electricity price hikes raise firewood consumption and women's collection time in Malawi"

# Author:  Purnima Porwal
# Date:    January 2026
# Context: RA application assessment — Section A (Data Replication)
# GitHub:  github.com/purnimaporwal/malawi-energy-replication

# REPLICATION NOTE: The replication files include nominal annual household expenditure (hh_annual_expenses) 
# but do not include a CPI deflator or a pre-constructed real expenditure variable. Observation counts match
# the paper (9,292 total) but expenditure moments differ from the published real statistics. This limitation is documented explicitly.
######################################################################


# ── CHANGE THIS ONE PATH TO MATCH YOUR COMPUTER ──────────────────
# Mac / Linux users:
BASE_FOLDER <- "/Users/purnimaporwal/Downloads/malawi-energy-replication"
 
# Windows users — uncomment this line instead:
# BASE_FOLDER <- "C:/Users/yourname/Downloads/malawi-energy-replication"
# ─────────────────────────────────────────────────────────────────

# All paths build automatically from BASE_FOLDER — no other changes needed
RAW_DATA <- file.path(BASE_FOLDER, "Raw_Data")
OUTPUT   <- file.path(BASE_FOLDER, "output")
TABLES   <- file.path(BASE_FOLDER, "output", "tables")
 
 
# Create output folders if they do not exist
if (!dir.exists(OUTPUT)) dir.create(OUTPUT, recursive = TRUE)
if (!dir.exists(TABLES)) dir.create(TABLES, recursive = TRUE)

# ── PACKAGES ──────────────────────────────────────────────────────
# Run install.packages() once if not already installed
#installing packages (import stata files into R while preserving all information)

# install.packages("rlang")
# install.packages(c("haven", "dplyr", "xtable"))

library(haven)
library(dplyr)
library(xtable)

# checking working directory
getwd()

# ── LOAD DATA ─────────────────────────────────────────────────────
hh   <- read_dta(file.path(RAW_DATA, "hh_unbalanced_panel.dta"))

# check the dataset size and first 30 variables (for household "hh")
dim(hh)
names(hh)[1:30] # checking the variables from Table 1 from paper

# check year in order
sort(unique(hh$year)) # it has 2019 data (2019-20)

######################## Making Table A1 ##############################

# Table A1 is about Annual household expenditure (MWK), panel sample 2010-20

# check the dataset size and first 30 variables (for household "hh")
dim(hh)
names(hh)[1:30] # checking the variables from Table 1 from paper

# check year in order
sort(unique(hh$year)) # so we have 2010-2019 in HH datasets

# ── IDENTIFY EXPENDITURE VARIABLE ─────────────────────────────────
# Search for the expenditure variable for the table A1
grep("expend|expendit|consump|consumption|real|total|annual",
     names(hh),
     value = TRUE,
     ignore.case = TRUE)

# it's hh_annual_expenses = Table A1 variable 
# Result: hh_annual_expenses is the relevant variable  

# ── DIAGNOSTIC: NOMINAL VS REAL EXPENDITURE ───────────────────────
# The paper reports real annual expenditure. Check whether a deflator exists.
grep("deflat|cpi|price|index|pf|pc|pk",
     names(hh), value = TRUE, ignore.case = TRUE)
# Result: pc exists but is not a general CPI deflator.
# Confirmed: no ready-made real expenditure variable in the replication files.
# Table A1 is therefore built using nominal hh_annual_expenses.
# Observation counts match; expenditure moments differ from published figures.


# ── BUILD TABLE A1 ────────────────────────────────────────────────
# Map calendar years to survey rounds as defined in the paper
# as paper provides the description by survey round, we are making survey rounds from years

# compute descriptive stats by survey rounds

# ---------- Table A1 dataset ----------
TableA1_data <- hh %>%
  transmute(
    year,
    Expenditure = hh_annual_expenses,
    Round = case_when(
      year %in% c(2010, 2011) ~ "2010--11",
      year == 2013 ~ "2013",
      year %in% c(2016, 2017) ~ "2016--17",
      year == 2019 ~ "2019--20",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(Round), !is.na(Expenditure))  # keep zeros

# sanity checks
table(TableA1_data$Round)
nrow(TableA1_data)                 # should be 9292 (matching the paper)
sum(is.na(TableA1_data$Expenditure)) # should be 0

# ── SUMMARY STATISTICS BY ROUND ───────────────────────────────────
TableA1_summary <- TableA1_data %>%
  group_by(Round) %>%
  summarise(
    Observations = n(),
    Mean = mean(Expenditure),
    SD   = sd(Expenditure),
    Min  = min(Expenditure),
    Max  = max(Expenditure),
    .groups = "drop"
  )

# Total row across all rounds
TableA1_total <- TableA1_data %>%
  summarise(
    Round = "Total",
    Observations = n(),
    Mean = mean(Expenditure),
    SD   = sd(Expenditure),
    Min  = min(Expenditure),
    Max  = max(Expenditure)
  )

# Combine and order rounds correctly

TableA1_final <- bind_rows(TableA1_summary, TableA1_total) %>%
  mutate(Round = factor(Round, levels = c("2010--11","2013","2016--17","2019--20","Total"))) %>%
  arrange(Round)

TableA1_final

# there is still a mismatch in this table A1 from the paper
#### The replication files include nominal annual household expenditure (hh_annual_expenses) but 
### do not include a CPI/deflator or a pre-constructed ‘real expenditure’ variable. As a result, the observation counts match the paper, 
## but expenditure moments differ from the published ‘real’ statistics.

# ── SAVE OUTPUT ───────────────────────────────────────────────────
# Save as CSV
write.csv(TableA1_final,
          file.path(TABLES, "tableA1_Annual_household_expenditure_MWK.csv"),
          row.names = FALSE)


# Save as LaTeX
tabA1_tex <- xtable(
  TableA1_final,
  caption = "Annual household expenditure (MWK), panel sample 2010--20.",
  label   = "tab:A1",
  align   = c("l", "l", "r", "r", "r", "r", "r")
)

 
print(tabA1_tex,
      file                   = file.path(TABLES, "tableA1.tex"),
      include.rownames       = FALSE,
      caption.placement      = "top",
      sanitize.text.function = identity)
 
cat("Table A1 saved to:", TABLES, "\n")
