# ICD-9 Codebook ----------------------------------------------------------

read.csv("./data/cod/cod_names.csv") %>%
  as_data_frame -> cbook_cod

# INED COD ----------------------------------------------------------------

# age levels in correct order
lev_age <- c("<1","1-4","5-9","10-14","15-19","20-24","25-29",
             "30-34","35-39","40-44","45-49","50-54","55-59",
             "60-64","65-69","70-74","75-79","80-84","85-89",
             "90-94","95-99","100+")

# cause of death data
read.csv("./data/cod/ined-cod-fra-1925-1999-counts.csv") %>%
  as_data_frame %>%
  # read in data on death counts and do basic tidying
  filter(Age != "Total") %>% droplevels %>%
  mutate(Age = factor(Age, levels = lev_age, ordered = TRUE)) %>%
  mutate(COD = factor(COD, labels = cbook_cod$Short)) %>%
  # convert counts to cause specific shares on total deaths
  group_by(Year, Age, Sex) %>%
  select(Year, Age, Sex, COD, Dx) %>%
  mutate(px = Dx / Dx[COD == "Total"]) %>%
  filter(COD != "Total") %>% droplevels-> counts

# aggregate missing shares in "Other" value
counts  %>%
  group_by(Year, Age, Sex) %>%
  summarise(COD = "Other", px = 1 - sum(px)) -> temp
# merge back into original data
rbind(select(counts, -Dx), temp) %>%
  as_data_frame %>%
  arrange(Year, Age, Sex) -> counts; rm(temp)

# Top 10 CODs -------------------------------------------------------------

# share by COD top 10 ICD codes
lab_cod_10 <- as.character(cbook_cod$Short[c(2, 3, 9, 10, 11, 16, 17, 18, 19)])
counts  %>%
  group_by(Year, Age, Sex) %>%
  filter(!(COD %in% lab_cod_10)) %>%
  summarise(COD = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(COD %in% lab_cod_10) -> counts_10
rbind(counts_10, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(Year, Age, Sex) -> counts_10; rm(temp)

# Top 5 CODs --------------------------------------------------------------

# percentage by COD top 5 ICD codes
lab_cod_5 <- as.character(cbook_cod$Short[c(2, 3, 9, 19)])
counts  %>%
  group_by(Year, Age, Sex) %>%
  filter(!(COD %in% lab_cod_5)) %>%
  summarise(COD = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(COD %in% lab_cod_5) -> counts_5
rbind(counts_5, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(Year, Age, Sex) -> counts_5; rm(temp)

# Top 3 CODs --------------------------------------------------------------

# percentage by COD top 3 ICD codes
lab_cod_3 <- as.character(cbook_cod$Short[c(3, 19)])
counts  %>%
  group_by(Year, Age, Sex) %>%
  filter(!(COD %in% lab_cod_3)) %>%
  summarise(COD = "Other", px = sum(px)) -> temp
# merge back into filtered data
counts %>%
  filter(COD %in% lab_cod_3) -> counts_3
rbind(counts_3, temp) %>%
  as_data_frame %>%
  droplevels %>%
  arrange(Year, Age, Sex) -> counts_3; rm(temp)