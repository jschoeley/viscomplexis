###############################
# Prepare Cause of Death Data #
###############################

# This script loads the French cause of death data set which contains death
# counts by period, age, sex and cause of death. Within each period-age-sex
# combination the cause of death proportions are calculated.
#
# Subsequently three data sets are derived, namely proportions among
# 2, 4, and 9 select causes of death (and all "other" causes of death).
#
# These data constitute the basis for the compositional Lexis surface plots
# in the paper.

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(tidyr)

# INED COD ----------------------------------------------------------------

# icd-9 codes and labels
cbook_cod <- read_csv("./data/ined_cod/cod_names.csv", skip = 13)

# age levels in correct order
lev_age <- c("<1","1-4","5-9","10-14","15-19","20-24","25-29",
             "30-34","35-39","40-44","45-49","50-54","55-59",
             "60-64","65-69","70-74","75-79","80-84","85-89",
             "90-94","95-99","100+")

# read data on deaths by year, sex, age & cause of death
read_csv("./data/ined_cod/ined-cod-fra-1925-1999-counts.csv", skip  = 19) %>%
  # apply factors
  mutate(
    age = factor(age, levels = lev_age, ordered = TRUE),
    cod = factor(cod, labels = cbook_cod$short)
  ) %>%
  # add numerical starting age and age group width
  filter(age != "total") %>%
  arrange(age) %>%
  group_by(year, sex, cod) %>%
  mutate(
    age_start = c(0, 1, seq(5, 100, 5)),
    age_width = c(diff(age_start), 5)
  ) %>% ungroup() %>%
  # convert counts to cause specific shares on total deaths
  group_by(year, age, sex) %>%
  select(year, age, age_start, age_width, sex, cod, dx) %>%
  mutate(px = dx / dx[cod == "Total"]) %>% ungroup() %>%
  # filter to relevant data:
  # a dataset of death proportions by cause of death over period, sex & age
  filter(cod != "Total") %>% droplevels() -> cod_prop

# The deaths by cause don't sum up to the number of deaths in the
# "Total" category. Therefore the proportions don't add up to unity.
# The "leftover" proportion gets assigned the cause of death "Other".
cod_prop %>%
  group_by(year, age, age_start, age_width, sex) %>%
  summarise(cod = "Other", px = 1 - sum(px)) %>%
  bind_rows(select(cod_prop, -dx), .) %>%
  ungroup() %>%
  arrange(year, age, sex) -> cod_prop

# 10 Causes of Death ------------------------------------------------------

# Calculate the death proportions of the 9 most common causes of death on all
# deaths. Aggregate the "leftovers" in category "Other".

# a vector of cods we are interested in
lab_cod_10 <- cbook_cod$short[c(2, 3, 9, 10, 11, 16, 17, 18, 19)]
cod_prop %>%
  # filter to the cods we are interested in
  filter(cod %in% lab_cod_10) %>%
  # convert to long format to make facilitate calculations
  spread(key = cod, value = px) %>%
  # calculate the proportion of deaths not due to our cods of interest
  mutate(Other = 1-rowSums(.[lab_cod_10])) %>%
  # convert back to long format
  gather_(key_col = "cod", value_col = "px",
          gather_cols = c(lab_cod_10, "Other")) %>%
  arrange(sex, year, age, cod) -> cod_prop10

write_csv(mutate(cod_prop10, px = sprintf("%1.5f", px)), path = "./data/plots/cod10.csv")

# 5 Causes of Death -------------------------------------------------------

# Calculate the death proportions of the 4 most common causes of death on all
# deaths. Aggregate the "leftovers" in category "Other".

lab_cod_5 <- cbook_cod$short[c(2, 3, 9, 19)]
cod_prop %>%
  filter(cod %in% lab_cod_5) %>%
  spread(key = cod, value = px) %>%
  mutate(Other = 1-rowSums(.[lab_cod_5])) %>%
  gather_(key_col = "cod", value_col = "px",
          gather_cols = c(lab_cod_5, "Other")) %>%
  arrange(sex, year, age, cod) -> cod_prop5

write_csv(mutate(cod_prop5, px = sprintf("%1.5f", px)), path = "./data/plots/cod5.csv")

# 3 Causes of Death -------------------------------------------------------

# Calculate the death proportions of the 2 most common causes of death on all
# deaths. Aggregate the "leftovers" in category "Other".

lab_cod_3 <- cbook_cod$short[c(3, 19)]
cod_prop %>%
  filter(cod %in% lab_cod_3) %>%
  spread(key = cod, value = px) %>%
  mutate(Other = 1-rowSums(.[lab_cod_3])) %>%
  gather_(key_col = "cod", value_col = "px",
          gather_cols = c(lab_cod_3, "Other")) %>%
  arrange(sex, year, age, cod) -> cod_prop3

write_csv(mutate(cod_prop3, px = sprintf("%1.5f", px)), path = "./data/plots/cod3.csv")
