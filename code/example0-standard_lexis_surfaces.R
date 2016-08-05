##############################################
# Plot Lexis Surface of Mortality Sex Ratios #
##############################################

# We download mortality rates for England and Wales across period, age and sex,
# calculate the male-female-mortality-ratios and plot it as a Lexis surface.

# Init --------------------------------------------------------------------

library(hmdget) # devtools::install_github("jschoeley/hmdget")
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)

# Download mortality surface England & Wales ------------------------------

# HMD database credentials (sign up at "mortality.org")
username = "***"
password = "***"

enwamx <- HMDget(.country = "GBRTENW", .timeframe = "p", .measure = "mx",
                 .username = username, .password = password)
#write_csv(mutate(enwamx, mx = sprintf("%1.5f", mx)), path = "./out/data/enwamx.csv")

# calculate sex ratio
enwamx %>%
  spread(Sex, mx) %>%
  mutate(mx_sex_ratio = na_if(Male/Female, Inf)) %>%
  filter(Year >= 1905, Age <= 100) -> dat

# Lexis surface mortality sex ratio ---------------------------------------

# mortality rate sex ratio breaks for discrete colour scale
breaks <- c(0, 1/2 , 100/175, 100/150, 100/125, 100/101,
            101/100, 125/100, 150/100, 175/100, 2/1, Inf)
labels <- c(">100% excess\nfemale mortality",
            "75 to 100%",
            "50 to 75%",
            "25 to 50%",
            "1 to 25%",
            "Equal mortality",
            # these spaces at the end are significant
            # because I want the resulting factor levels to be unique
            "1 to 25% ",
            "25 to 50% ",
            "50 to 75% " ,
            "75 to 100% ",
            ">100% excess\nmale mortality")

# discretize sex ratio
dat %>%
  mutate(mx_sex_ratio_disc =
           cut(mx_sex_ratio,
               breaks, labels,
               include.lowest = TRUE)) -> dat

# plot mortality sex ratio Lexis surface
plot_lexis_surface <- ggplot(dat) +
  # heatmap
  geom_raster(aes(x = Year+0.5, y = Age+0.5,
                  fill = mx_sex_ratio_disc)) +
  # Lexis grid
  geom_hline(yintercept = seq(10, 100, 10),
             alpha = 0.2, lty = "dotted") +
  geom_vline(xintercept = seq(1910, 1990, 10),
             alpha = 0.2, lty = "dotted") +
  geom_abline(intercept = seq(-100, 100, 10)-1910,
              alpha = 0.2, lty = "dotted") +
  # scales
  scale_fill_brewer(name = NULL, type = "div", palette = 5, drop = FALSE) +
  scale_x_continuous("Year", expand = c(0.02, 0),
                     breaks = seq(1900, 2010, 10)) +
  scale_y_continuous("Age", expand = c(0, 0),
                     breaks = seq(0, 100, 10)) +
  guides(fill = guide_legend(reverse = TRUE)) +
  # coord
  coord_equal() +
  # theme
  theme_void() +
  theme(
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text()
  )

#ggsave("./out/fig/lexis_surface_raw.pdf", plot_lexis_surface,
#       width = 7, height = 7)
