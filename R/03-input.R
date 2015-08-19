# ICD-9 Codebook ----------------------------------------------------------

read.csv("./data/ined_cod/cod_names.csv", skip = 13) %>%
  as_data_frame -> cbook_cod

# INED COD ----------------------------------------------------------------

# age levels in correct order
lev_age <- c("<1","1-4","5-9","10-14","15-19","20-24","25-29",
             "30-34","35-39","40-44","45-49","50-54","55-59",
             "60-64","65-69","70-74","75-79","80-84","85-89",
             "90-94","95-99","100+")

# cause of death data
read.csv("./data/ined_cod/ined-cod-fra-1925-1999-counts.csv", skip  = 19) %>%
  as_data_frame %>%
  # read in data on death counts and do basic tidying
  filter(age != "total") %>% droplevels %>%
  mutate(age = factor(age, levels = lev_age, ordered = TRUE)) %>%
  mutate(cod = factor(cod, labels = cbook_cod$short)) %>%
  # convert counts to cause specific shares on total deaths
  group_by(year, age, sex) %>%
  select(year, age, sex, cod, dx) %>%
  mutate(px = dx / dx[cod == "Total"]) %>%
  filter(cod != "Total") %>% droplevels -> counts

# aggregate missing shares in "Other" value
counts %>%
  group_by(year, age, sex) %>%
  summarise(cod = "Other", px = 1 - sum(px)) -> temp
# merge back into original data
rbind(select(counts, -dx), temp) %>%
  as_data_frame %>%
  arrange(year, age, sex) -> counts; rm(temp)

# Top 10 CODs -------------------------------------------------------------

# share by COD top 10 ICD codes
lab_cod_10 <- as.character(cbook_cod$short[c(2, 3, 9, 10, 11, 16, 17, 18, 19)])
counts %>%
  group_by(year, age, sex) %>%
  filter(!(cod %in% lab_cod_10)) %>%
  summarise(cod = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(cod %in% lab_cod_10) -> counts_10
rbind(counts_10, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(year, age, sex) -> counts_10; rm(temp)

# Top 5 CODs --------------------------------------------------------------

# percentage by COD top 5 ICD codes
lab_cod_5 <- as.character(cbook_cod$short[c(2, 3, 9, 19)])
counts %>%
  group_by(year, age, sex) %>%
  filter(!(cod %in% lab_cod_5)) %>%
  summarise(cod = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(cod %in% lab_cod_5) -> counts_5
rbind(counts_5, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(year, age, sex) -> counts_5; rm(temp)

# Top 3 CODs --------------------------------------------------------------

# percentage by COD top 3 ICD codes
lab_cod_3 <- as.character(cbook_cod$short[c(3, 19)])
counts %>%
  group_by(year, age, sex) %>%
  filter(!(cod %in% lab_cod_3)) %>%
  summarise(cod = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(cod %in% lab_cod_3) -> counts_3
rbind(counts_3, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(year, age, sex) -> counts_3; rm(temp)