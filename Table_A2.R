######################################################################
# Table A2: Energy prices (MWK), monthly
# Replication of Table A2 from: "Electricity price hikes raise firewood consumption and women's collection time in Malawi"

# Author:  Purnima Porwal
# Date:    January 2026
# Context: RA application assessment — Section A (Data Replication)
# GitHub:  github.com/purnimaporwal/malawi-energy-replication

# Panels:
#   A — Firewood price (MWK per heap)
#   B — Charcoal price (MWK per 50kg bag)
#   C — Electricity tariff (MWK per kWh)
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

########### TABLE A2 ##########

#installing packages (import stata files into R while preserving all information)
# install.packages(c("haven", "dplyr", "xtable"))
 
# Packages
library(haven)
library(dplyr)
library(xtable)

# ── LOAD DATA ─────────────────────────────────────────────────────
hh <- read_dta(file.path(RAW_DATA, "hh_unbalanced_panel.dta"))

# checking working directory
getwd()
# check the dataset size and first 30 variables (for household "hh")
dim(hh)
names(hh)[1:30] # checking the variables from Table 1 from paper

# check year in order
sort(unique(hh$year)) # it has 2019 data (2019-20)
 
# check electricity price variable exists
grep("elec|electric|kwh|tariff|escom|grid|power|price",
     names(hh), value = TRUE, ignore.case = TRUE)
# confirmed: elec_tariff_mwk_per_kWh is the electricity variable
 
names(hh)[grepl("elec|tariff|kwh", names(hh), ignore.case = TRUE)]


# ── HELPER FUNCTION: SUMMARY STATISTICS ───────────────────────────
sum4 <- function(x) {
  c(Mean = mean(x, na.rm = TRUE),
    SD   = sd(x,   na.rm = TRUE),
    Min  = min(x,  na.rm = TRUE),
    Max  = max(x,  na.rm = TRUE))
}
 
############### Table A2 (Energy prices)#############

# ── BUILD PRICE DATASET ───────────────────────────────────────────
# Map calendar years to survey rounds, select price variables,
# and deduplicate to month-year level
# (prices repeat across households — keep one row per month-year)

prices_mth <- hh %>% 
  mutate(
    Round = case_when(
      year %in% c(2010, 2011) ~ "2010--11",
      year == 2013            ~ "2013",
      year %in% c(2016, 2017) ~ "2016--17",
      year == 2019            ~ "2019--20",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(Round)) %>%
  select(
    year, month, Round,
    ln_p_nat_mth_yr_f,  # firewood price (log scale)
    ln_p_nat_mth_yr_c,  # charcoal price (log scale)
    elec_tariff_mwk_per_kWh    # electricity tariff (level)
  ) %>%
  distinct(year, month, .keep_all = TRUE) %>%  # one row per month-year
  mutate(
    firewood_price = exp(ln_p_nat_mth_yr_f),  # convert log to level
    charcoal_price = exp(ln_p_nat_mth_yr_c)  # convert log to level
  )
# check deduplicated dataset
dim(prices_mth)
names(prices_mth)

# ── PANEL A: FIREWOOD PRICES ──────────────────────────────────────

TableA2_firewood <- prices_mth %>%
  group_by(Round) %>%
  summarise(
    Mean = sum4(firewood_price)["Mean"],
    SD   = sum4(firewood_price)["SD"],
    Min  = sum4(firewood_price)["Min"],
    Max  = sum4(firewood_price)["Max"],
    .groups = "drop"
  ) %>%
  filter(!is.na(Mean))
 
TableA2_firewood

# ── PANEL B: CHARCOAL PRICES ──────────────────────────────────────

TableA2_charcoal <- prices_mth %>%
  group_by(Round) %>%
  summarise(
    Mean = sum4(charcoal_price)["Mean"],
    SD   = sum4(charcoal_price)["SD"],
    Min  = sum4(charcoal_price)["Min"],
    Max  = sum4(charcoal_price)["Max"],
    .groups = "drop"
  ) %>%
  filter(!is.na(Mean))
 
TableA2_charcoal

# ── PANEL C: ELECTRICITY TARIFF ───────────────────────────────────

TableA2_electricity <- prices_mth %>%
  group_by(Round) %>%
  summarise(
    Mean = mean(elec_tariff_mwk_per_kWh, na.rm = TRUE),
    SD   = sd(elec_tariff_mwk_per_kWh, na.rm = TRUE),
    Min  = min(elec_tariff_mwk_per_kWh, na.rm = TRUE),
    Max  = max(elec_tariff_mwk_per_kWh, na.rm = TRUE),
    .groups = "drop"
  )

TableA2_electricity
# here, confirmed: elec_tariff_mwk_per_kWh is the electricity variable
# price variables for firewood and charcoal are in logs — converting using exp()


# ── SAVE OUTPUT ───────────────────────────────────────────────────
# Saving CSVs

write.csv(TableA2_firewood, file.path(TABLES, "tableA2_firewood.csv"), row.names = FALSE)
write.csv(TableA2_charcoal, file.path(TABLES, "tableA2_charcoal.csv"), row.names = FALSE)
write.csv(TableA2_electricity, file.path(TABLES, "tableA2_electricity.csv"), row.names = FALSE)
# Saving Latex files for tables

print(xtable(TableA2_firewood, caption="Table A2: Firewood prices (MWK per heap), monthly.", label="tab:A2_firewood"),
 file = file.path(TABLES, "tableA2_firewood.tex"),
  include.rownames = FALSE,
  caption.placement = "top"
)

print(
  xtable(TableA2_charcoal, caption="Table A2: Charcoal prices (MWK per 50kg bag), monthly.", label="tab:A2_charcoal"),
  file = file.path(TABLES, "tableA2_charcoal.tex"),
  include.rownames = FALSE,
  caption.placement = "top"
)

print(
  xtable(TableA2_electricity, caption="Table A2: Electricity tariff (MWK per kWh), monthly.", label="tab:A2_electricity"),
  file = file.path(TABLES, "tableA2_electricity.tex"),
  include.rownames = FALSE,
  caption.placement = "top"
)

cat("Table A2 (all panels) saved to:", TABLES, "\n")
