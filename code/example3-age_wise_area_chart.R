############################
# Plot Age-wise-Area Chart #
############################

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------

# proportions of 5 selected causes of death on
# all causes of death by year, age and sex
cod5 <- read_csv("./data/plots/cod5.csv")

# We want to make sure that the age groups are plotted in the correct order
# later on. So we transform the age variable into an ordered factor.

lev_age <- c("<1","1-4","5-9","10-14","15-19","20-24","25-29",
             "30-34","35-39","40-44","45-49","50-54","55-59",
             "60-64","65-69","70-74","75-79","80-84","85-89",
             "90-94","95-99","100+")
cod5 <- mutate(cod5, age = factor(age, lev_age, ordered = TRUE))

# Furthermore the order of the areas, each representing a single cause of death,
# is of relevance. ggplot draws the areas in order of occurence in the data
# frame. We reorder the data frame accordingly.

lev_cod <- c("Circulatory diseases",
             "Neoplasms", "Infections",
             "External", "Other")
cod5 %>%
  mutate(cod = factor(cod, lev_cod)) %>%
  group_by(year, sex, age) %>% arrange(cod) -> cod5

# Plot Age-wise Area Chart ------------------------------------------------

# We assign colours to each cause of death. For an area chart we want the
# neighbouring colours to contrast with each other. Therefore we vary hue &
# lightness, e.g. light green next to purple next to light blue.

cpal <- c(
  "Circulatory diseases" = "#FB8072",
  "Neoplasms"            = "#FFFFB3",
  "Infections"           = "#54D39E",
  "External"             = "#D086B5",
  "Other"                = "#80B1D3"
)

# We plot a single area chart for each age category.

plot_agewise_area <-
  ggplot(filter(cod5, sex == "total")) +
  # area charts
  geom_area(aes(x = year, y = px, fill = cod),
            show.legend = FALSE) +
  # period grid
  geom_vline(xintercept = seq(1930, 1999, 10),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  # scale
  scale_fill_manual("", values = cpal) +
  scale_x_continuous("Year", expand = c(0, 0),
                     breaks = seq(1930, 1990, 10)) +
  # coord
  coord_fixed(ratio = 5) +
  # facet
  facet_grid(age~., as.table = FALSE) +
  # theme
  theme_void() +
  theme(
    axis.text    = element_text(colour = "black"),
    axis.text.x  = element_text(),
    strip.text.y = element_text(angle = 0, hjust = 1),
    panel.margin = unit(0, "cm")
  )

ggsave("./fig/agewise_area/agewise_area_raw.pdf", plot_agewise_area,
       width = 5, height = 7)
