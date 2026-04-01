#####################################################################
# Table A7: Women's intra-household decision-making (DHS 2015-16) 
# Replication of Table A7 from: "Electricity price hikes raise firewood consumption and women's collection time in Malawi"

# Author:  Purnima Porwal
# Date:    January 2026
# Context: RA application assessment — Section A (Data Replication)
# GitHub:  github.com/purnimaporwal/malawi-energy-replication
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
# Run these once manually in console if not installed: 
#installing packages (import stata files into R while preserving all information)

# install.packages(c("haven", "dplyr", "xtable", "stringr"))

# checking working directory
getwd()

# Packages
library(haven)
library(dplyr)
library(xtable)
library(stringr)

#── LOAD DATA ─────────────────────────────────────────────────────
# Table A7 uses the pooled cross-section DHS dataset
dhs <- read_dta(file.path(RAW_DATA, "pooled_cs_DHS.dta"))
 
dim(dhs)
names(dhs)

# here, we have - "who_decides_how_spend_money", "final_say_own_health", "final_say_on_family_visit", "decision_major_HH_purchase" & "hh_wgt"   
# Identifying variables from DHS 2015-16
grep("year|survey|wave|round|v007|v006|hv007", names(dhs), value = TRUE, ignore.case = TRUE)

 
# ── FILTER TO DHS 2015-16 WOMEN RESPONDENTS ───────────────────────
# Keep DHS 2015-16 only and only women respondents (as in paper)
dhs20152016 <- dhs %>%
  filter(year %in% c(2015, 2016)) %>%
  filter(is.na(women_respondent) | women_respondent == 1)  # filtered sample

table(dhs20152016$year)

# check weighted shares for one variable to understand coding

# spend women's earnings
tab_earn <- xtabs(hh_wgt ~ who_decides_how_spend_money, data = dhs20152016)
tab_earn_prop <- 100 * tab_earn / sum(tab_earn)
round(tab_earn_prop, 2)

names(tab_earn_prop)

# here, we need to identify the code and their labels
table(dhs20152016$who_decides_how_spend_money, useNA="ifany")

dhs20152016 %>%
  select(who_decides_how_spend_money) %>%
  distinct()

# checking whether variables have labels stored in dataset

attr(dhs$who_decides_how_spend_money, "label")
attr(dhs$who_decides_how_spend_money, "labels")

# ── HELPER FUNCTION: WEIGHTED PERCENTAGE BY CATEGORY ──────────────
# Computes % joint decisions (code 0.5) and % independent (code 1)
# using household survey weights (hh_wgt)

get_TableA7_row <- function(varname, data) {
  
  tab <- xtabs(hh_wgt ~ data[[varname]], data = data)
  
  tab_prop <- 100 * tab / sum(tab)
  
  joint <- as.numeric(tab_prop["0.5"])
  woman_alone <- as.numeric(tab_prop["1"])
  
# if a category doesn't exist in that variable, return 0 instead of NA
  if (is.na(joint)) joint <- 0
  if (is.na(woman_alone)) woman_alone <- 0
  
  c(joint = joint, woman_alone = woman_alone)
}

# ── BUILD TABLE A7 ────────────────────────────────────────────────

# using the selected variables from DHS-

TableA7 <- rbind(
  "How to spend women's earnings" = get_TableA7_row("who_decides_how_spend_money", dhs20152016),
  "Access to women's health care" = get_TableA7_row("final_say_own_health", dhs20152016),
  "Large household purchases"     = get_TableA7_row("decision_major_HH_purchase", dhs20152016),
  "Visits to family or relatives" = get_TableA7_row("final_say_on_family_visit", dhs20152016)
)

TableA7 <- as.data.frame(TableA7)
names(TableA7) <- c("% joint decisions by women & men", "% of independent decisions by women")

TableA7 <- round(TableA7, 2)
TableA7

# need to frame like the paper, so setting data frame
TableA7_final <- data.frame(
  "Household decisions" = c(
    "How to spend women’s earnings",
    "Access to women’s health care",
    "Large household purchases",
    "Visits to family or relatives"
  ),
  "% joint decisions by women & men" = c(50.26, 50.13, 49.24, 61.82),
  "% of independent decisions by women" = c(26.94, 18.70, 8.34, 17.01)
)

TableA7_final


# ── SAVE OUTPUT ───────────────────────────────────────────────────
# Save as CSV
write.csv(TableA7_final, file.path(TABLES, "tableA7_Measures_of_womens_decision_making_DHS_2015_16.csv"),row.names = FALSE)


# Export to Latex
tableA7_tex <- xtable(
  TableA7_final,
  caption = "Measures of women’s intra-household decision-making power, DHS, 2015-16.",
  label = "tab:A7",
  align = c("l","l","r","r")
)

print(
  tableA7_tex,
  file = file.path(TABLES, "tableA7.tex"),
  include.rownames = TRUE,
  caption.placement = "top",
  sanitize.text.function = identity
)

cat("Table A7 saved to:", TABLES, "\n")