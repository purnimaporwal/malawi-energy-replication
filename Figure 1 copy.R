######################################################################
# Figure 1: Cooking fuel choice (% of users), 2019-20
# Replication of Figure 1 from:
# "Electricity price hikes raise firewood consumption and
#  women's collection time in Malawi"
#
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
 
# Create output folder if it does not exist
if (!dir.exists(OUTPUT)) dir.create(OUTPUT, recursive = TRUE)
 
# ── PACKAGES ───

#installing packages (import stata files into R while preserving all information)
install.packages("haven")
install.packages("xtable")   # run once only

library(haven)
library(xtable)



######################## Making Figure 1 ##############################
# checking working directpry
getwd()

# ── LOAD DATA ─────────────────────────────────────────────────────
hh <- read_dta(file.path(RAW_DATA, "hh_unbalanced_panel.dta"))

# check the dataset size and first 30 variables (for household "hh")
dim(hh)
names(hh)[1:30] # checking the variables from Table 1 from paper

# check year in order
sort(unique(hh$year)) # it has 2019 data (2019-20)


# checking residence (rural vs urban)
table(hh$reside)
# binary form in labels (from stata)
table(as_factor(hh$reside))
#check the source of cooking fuel 
table(hh$source_cooking)
# binary coding in labels 
table(as_factor(hh$source_cooking))

# here, we got the variables required to make figure 1 from the paper for descriptive statistics
# checking the sample
table(hh$year)

# DIAGNOSTIC CHECK for PANEL SAMPLE 2019–20
grep("keep|balanced|panel|sample|wave|visit", names(hh), value=TRUE, ignore.case=TRUE)

# filtering the dataset to the latest  panel sample 2019–20
hh_2019 <- hh[hh$year == 2019 &
                !is.na(hh$panelweight_2019) &
                !is.na(hh$reside) &
                !is.na(hh$source_cooking),
]
# diagnostic: check how many dropped due to missing weight
table(hh$year == 2019, is.na(hh$panelweight_2019))

# ── PREPARE VARIABLES ─────────────────────────────────────────────
# making reside and source _cooking readable
residence <- as_factor(hh_2019$reside)
cooking_fuel <- as_factor(hh_2019$source_cooking)
# as we have weighed percentages for the panel 2019 here, we will use this
weight <- hh_2019$panelweight_2019

# check the length 
length(residence)
length(cooking_fuel)
length(weight)

# summarise
summary(weight)

# check raw tables before recoding
# making table of both variables required to plot the figure
table(residence, cooking_fuel)
table(residence)
table(cooking_fuel)

# ── RECODE FUEL CATEGORIES ────────────────────────────────────────
#Recode labels into characters for R to read and combined the fuel choices (grouped as one) under new variable fuel_grouped
cooking_fuel_grouped <- as.character(cooking_fuel)

# check before fixing — "Puchased firewood" typo visible here
table(residence, cooking_fuel_grouped)

# Fix typo in original label: "Puchased firewood" -> "Purchased firewood"
cooking_fuel_grouped[cooking_fuel_grouped == "Puchased firewood"] <- "Purchased firewood"


# Group small categories into "Other" (matching paper's five categories)
# Checking (using %in%), replacing and grouping small catergories into 'Other' variable
cooking_fuel_grouped[cooking_fuel_grouped %in% c("Paraffin", "Gas", "Crop residue",
                                                 "Saw dust", "Animal waste", "Other (specify)")] <- "Other"
# keeping only 5 categories (in reference to paper) used in figure
cooking_fuel_grouped[!(cooking_fuel_grouped %in% c("Collected firewood",
                                                       "Purchased firewood",
                                                       "Charcoal",
                                                       "Electricity",
                                                       "Other"))] <- NA
# check the recoded variable 
table(cooking_fuel_grouped, useNA = "ifany")

# check the table now
table(residence, cooking_fuel_grouped)

# ── COMPUTE WEIGHTED PERCENTAGES ──────────────────────────────────

# create the data frame
df_w <- data.frame(
  residence = residence,
  cooking_fuel_grouped = cooking_fuel_grouped,
  weight = weight
)

df_w <- df_w[
  !is.na(df_w$residence) &
    !is.na(df_w$cooking_fuel_grouped) &
    !is.na(df_w$weight),
]

xtabs(weight ~ residence + cooking_fuel_grouped, data = df_w)

# weighted counts and row percentages
# taking weighted percentages in two-way table 
weighted_counts <- xtabs(weight ~ residence + cooking_fuel_grouped, data = df_w)
weighted_percent <- prop.table(weighted_counts, 1) * 100
round(weighted_percent, 1) #rounding to 1 decimal place

# ── PLOT FIGURE 1 ─────────────────────────────────────────────────
# Reorder columns to match paper
order_cols <- c("Collected firewood","Charcoal","Purchased firewood","Other","Electricity")
weighted_percent_plot <- weighted_percent[, order_cols]
weighted_percent_plot

round(weighted_percent_plot, 1)

# Plotting function — defined separately so it can be called for both PDF and PNG

plot_figure1 <- function(weighted_percent_plot){
  
  par(mfrow = c(1, 2),
      mar = c(10,4,4,1),
      oma = c(0,0,3,0))

# Rural panel
  bp_rural <- barplot(
    weighted_percent_plot["rural", ],
    main = "Rural",
    ylab = "Cooking fuel choice (%)",
    col  = "#0c4c8a",
    ylim = c(0, 85),
    las  = 2
  )
  text(bp_rural,
       weighted_percent_plot["rural", ] + 2,
       labels = paste0(round(weighted_percent_plot["rural", ], 1), "%"),
       cex = 0.8)
  
# Urban panel
  bp_urban <- barplot(
    weighted_percent_plot["urban", ],
    main = "Urban",
    ylab = "Cooking fuel choice (%)",
    col  = "#0c4c8a",
    ylim = c(0, 85),
    las  = 2
  )
  text(bp_urban,
       weighted_percent_plot["urban", ] + 2,
       labels = paste0(round(weighted_percent_plot["urban", ], 1), "%"),
       cex = 0.8)
  
  mtext("Cooking fuel choice (% of users), 2019-20", outer = TRUE, cex = 1.2, font = 1)
  
  par(mfrow = c(1, 1))
}


# ── SAVE OUTPUT ───────────────────────────────────────────────────
# Save as PDF (for LaTeX)
pdf(file.path(OUTPUT, "figure1.pdf"), width=10.5, height=5.5)
plot_figure1(weighted_percent_plot)
dev.off()


# Save as PNG
png(file.path(OUTPUT, "figure1.png"), width = 1600, height = 900, res = 200)
plot_figure1(weighted_percent_plot)
# paste the same plotting code
dev.off()

cat("Figure 1 saved to:", OUTPUT, "\n")