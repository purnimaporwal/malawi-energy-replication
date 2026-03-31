# Malawi Energy Replication ⚡

**RA Application Task | January 2026**
**Language: R**

Full replication of a published economics paper using Malawi household panel data, completed independently in R after my Stata licence expired mid-task.

---

## What this is

In January 2026 I was given a replication task as part of an RA application. The paper was:

> *"Electricity price hikes raise firewood consumption and women's collection time in Malawi"*

I had planned to use Stata but my licence expired before I could start. So I replicated everything in R instead, learning the workflow as I went.

I replicated all four requested outputs. The code is documented throughout with notes explaining the decisions I made, where I hit problems, and how I resolved them.

---

## What I replicated

**Figure 1 — Cooking fuel choice by urban/rural residence (2019-20)**

Weighted bar chart showing the distribution of household cooking fuel choices across rural and urban areas, using panel survey weights from the Malawi IHPS. The main challenge here was handling the mismatch between printed page numbers and actual survey round labels in the dataset, and fixing a typo in the original fuel label ("Puchased firewood" → "Purchased firewood").

**Table A1 — Annual household expenditure (MWK), panel sample 2010-20**

Summary statistics (observations, mean, SD, min, max) by survey round. I ran into a real problem here: the replication files include nominal annual expenditure but no CPI deflator or pre-constructed real expenditure variable. The observation counts match the paper but the expenditure moments differ from the published real statistics. I documented this explicitly in the code rather than trying to hide the discrepancy.

**Table A2 — Energy prices by fuel type**

Mean prices (MWK) by survey round for firewood, charcoal, and electricity. Required handling log-transformed price variables (converting back from ln_p using exp()) and deduplicating monthly price observations within panel rounds.

**Table A7 — Women's intra-household decision-making (DHS 2015-16 Malawi)**

Percentage of households where women make decisions jointly or independently across four decision types. The main challenge was mapping DHS numeric response codes to readable categories — the factor labels do not map intuitively and required careful checking.

---

## Extra work: India air quality data

I also collected and processed PM2.5 daily average air quality data for 10 Indian cities from India's Central Pollution Control Board (CPCB) portal. I cleaned and processed this in R and computed a national average across cities. The clean CSV is in the output folder.

---

## Files

```
malawi-energy-replication/
│
├── Figure_1.R          # Weighted cooking fuel chart (Malawi IHPS 2019-20)
├── Table_A1.R          # Annual household expenditure by survey round
├── Table_A2.R          # Energy prices by fuel type
├── Table_A7.R          # Women's decision-making (DHS 2015-16)
│
├── output/
│   ├── figure1.pdf                                    # Figure 1
│   ├── tableA1_Annual_household_expenditure_MWK.csv   # Table A1
│   ├── tableA2_charcoal.csv                           # Table A2 (charcoal)
│   ├── tableA2_electricity.csv                        # Table A2 (electricity)
│   ├── tableA2_firewood.csv                           # Table A2 (firewood)
│   └── tableA7_Measures_of_womens_decision_making_DHS_2015_16.csv
│
└── README.md
```

---

## How to run it

### Set the working directory

At the top of each R file, set your working directory:

```r
# Mac/Linux:
setwd("/Users/yourname/Documents/malawi-energy-replication")

# Windows:
# setwd("C:/Users/yourname/Documents/malawi-energy-replication")
```

### Install required packages

```r
install.packages(c("haven", "dplyr", "xtable"))
```

### Get the data

The raw data is not included in this repository. It comes from:

- **Malawi IHPS:** [World Bank Microdata Library](https://microdata.worldbank.org/index.php/catalog/2248) — download `hh_unbalanced_panel.dta` and place in `Data_Raw/`
- **DHS 2015-16 Malawi:** [DHS Program](https://dhsprogram.com/data/dataset/Malawi_Standard-DHS_2015.cfm) — requires free registration
- **India CPCB air quality:** [CPCB National Air Quality Index](https://app.cpcbccr.com/AQI_India/) — manually collected

### Run each script

Run the four R files in any order. Outputs save automatically to `output/`.

---

## Packages used

```r
library(haven)    # import Stata .dta files
library(dplyr)    # data cleaning and grouping
library(xtable)   # export LaTeX tables
```

---

## A note on transparency

This was the first time I ran a full replication workflow in R. I documented every decision, every assumption, and every place where I could not exactly match the published output. Where numbers differed from the paper, I stated the reason explicitly rather than adjusting the code to force a match.

I think that is the right approach to replication work.

---

## Data sources

- Malawi Integrated Household Panel Survey (IHPS) 2010-2019
- DHS 2015-16 Malawi
- India CPCB Air Quality Data (10 cities, manually collected)

---

Part of my research portfolio: [github.com/purnimaporwal](https://github.com/purnimaporwal)

*Author: Purnima Porwal | porwal.purnima18@gmail.com*
