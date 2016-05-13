######################################
# Plot Small Multiple Lexis Surfaces #
######################################

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------

# proportions of 10 selected causes of death on
# all causes of death by year, age and sex
cod10 <- read_csv("./data/plots/cod10.csv")

# Within each year, sex and age category, we look for the cause of death with
# the highest proportion on all deaths and subset to that cause. The result is
# a data set with the most prominent cause of death for each tile on the Lexis
# surface.

cod10 %>%
  group_by(year, sex, age) %>%
  filter(px == max(px)) %>%
  ungroup() -> cod10_mode

# Plot Small Multiple Lexis Surface ---------------------------------------

# plot small multiples of all COD
plot_small_multiples <-
  ggplot(filter(cod10, sex == "total"),
         # align tiles to Lexis grid
         aes(x = year+0.5, y = age_start+age_width/2,
             width = 1, height = age_width)) +
  # coloured Lexis surface
  geom_tile(aes(fill = cut_interval(px, length = 0.1))) +
  # outline tile if cause of death is most prominent
  geom_tile(data = filter(cod10_mode, sex == "total"),
            fill = "red") +
  # scale
  scale_fill_grey("px", guide = guide_legend(reverse = TRUE),
                  start = 0.8, end = 0.2) +
  scale_x_continuous("Year", expand = c(0.02, 0),
                     breaks = seq(1940, 2000, 20)) +
  scale_y_continuous("Age", expand = c(0, 0),
                     breaks = seq(0, 100, 20)) +
  # facet
  facet_wrap(~ cod, ncol = 5, as.table = TRUE) +
  # Lexis grid
  geom_hline(yintercept = seq(20, 100, 20),
             alpha = 0.2, lty = "dotted") +
  geom_vline(xintercept = seq(1940, 1980, 20),
             alpha = 0.2, lty = "dotted") +
  geom_abline(intercept = seq(-100, 100, 20)-1940,
              alpha = 0.2, lty = "dotted") +
  # coord
  coord_equal() +
  # theme
  theme_void() +
  theme(
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text()
  )
