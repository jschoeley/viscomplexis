###### Collect csv files in single data frame (long format)

# Init --------------------------------------------------------------------

library(reshape2)
setwd("./data/cod/source/")

# Input -------------------------------------------------------------------

# paths of all csv files in wd
path.counts <- list.files("./counts",
                          recursive = TRUE, full.names = TRUE,
                          pattern = "*.csv$")
path.rates <- list.files("./rates",
                         recursive = TRUE, full.names = TRUE,
                         pattern = "*.csv$")

# strip filenames from file path to use them as dataset names
names <- gsub("./counts/", "", path.counts)
names <- gsub(".csv", "*", names)
names <- gsub("-", "*-", names)

# read them all and store in list
cod.counts <- lapply(path.counts, read.csv)
cod.rates <- lapply(path.rates, read.csv)

# name list elements after corresponding icd9 code
names(cod.counts) <- names
names(cod.rates) <- names

# Reshape -----------------------------------------------------------------

# to long format
cod.counts.long <- melt(cod.counts, "Year")
cod.rates.long <- melt(cod.rates, "Year")

# split names into sex and icd variables
names <- matrix(unlist(strsplit(cod.counts.long$L1, "/")),
                ncol = 2, byrow = TRUE)
sex <- factor(names[,1])
icd <- factor(names[,2])
cod.counts.long$L1 <- sex
cod.rates.long$L1 <- sex
cod.counts.long$COD <- icd
cod.rates.long$COD <- icd

# better age labels
cod.counts.long$variable <-
  factor(cod.counts.long$variable,
         unique(cod.counts.long$variable),
         c("Total","<1","1-4","5-9","10-14","15-19","20-24","25-29","30-34",
           "35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74",
           "75-79","80-84","85-89","90-94","95-99","100+"))
cod.rates.long$variable <-
  factor(cod.rates.long$variable,
         unique(cod.rates.long$variable),
         c("Total","<1","1-4","5-9","10-14","15-19","20-24","25-29","30-34",
           "35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74",
           "75-79","80-84","85-89","90-94","95-99","100+"))

# correct names
names(cod.counts.long) <- c("Year", "Age", "Dx", "Sex", "COD")
names(cod.rates.long) <- c("Year", "Age", "mx", "Sex", "COD")

# reorder
cod.counts.long <- cod.counts.long[, c("Year", "Sex", "Age", "COD", "Dx")]
cod.rates.long <- cod.rates.long[, c("Year", "Sex", "Age", "COD", "mx")]

# Output ------------------------------------------------------------------

write.csv(cod.counts.long, "ined-cod-fra-1925-1999-counts.csv", row.names = FALSE)
write.csv(cod.rates.long, "ined-cod-fra-1925-1999-rates.csv", row.names = FALSE)