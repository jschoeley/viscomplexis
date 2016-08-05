####################################################
# Plot Qualitative Sequential Scheme Lexis Surface #
####################################################

# We plot a Lexis surface of the most common cause of death and its proportion
# on all deaths across period and age using a qualitative-sequential-scheme
# colour scale.

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(colorspace)

# Data --------------------------------------------------------------------

# proportions of 5 selected causes of death on
# all causes of death by year, age and sex
cod5 <- read_csv("./out/data/cod5.csv")

# Within each year, sex and age category, we look for the cause of death with
# the highest proportion on all deaths and subset to that cause. The result is
# a data set with the most prominent cause of death for each tile on the Lexis
# surface.

cod5 %>%
  group_by(year, sex, age) %>%
  filter(px == max(px)) %>%
  ungroup() -> cod5_mode

# Qualitative Sequential Colour Mixing ------------------------------------

# We assign a base colour to each of our causes of death.

cpal <- c(
  "Circulatory diseases" = "#CB040C",
  "Neoplasms"            = "#B05D00",
  "Infections"           = "#1E6617",
  "External"             = "#A5147B",
  "Other"                = "#18657A"
)

# These base colours are mixed with white in a ratio determined by the px value
# -- the proportion of the leading cause of death on all other causes of death
# at each period-age intersection by sex. For a discretized result we have to
# decide on how to cut the px vector and on the amount of alpha blending for
# each of the px intervals.

breaks <- c(0.2, 0.4, 0.6, 0.8, 1)
alphas <- seq(0.2, 1, length.out = length(breaks)-1)

# In the next step we mix the base colours with different amounts of white,
# according to the discretized px value and the specified alpha levels. The
# higher the proportion of the leading cause of death on all causes of death
# the darker the colour will be. Leading causes of death with a relatively low
# proportion will be very pale and bright. The `colorspace` library does the
# colour mixing. We write a convenience function to do the mixing.

#' Mix a Colour With White
#'
#' @details This is alpha blending with a white background. The alpha blending
#'   takes place in the LAB color-space, ensuring perceptually balanced results.
#'
#' @param .rgb   vector of RGB hex values
#' @param .alpha alpha value within [0,1]
#'
#' @return A vector of alpha blended RGB hex values.
MixWithWhite <- function (.rgb, .alpha) {
  # mix .rgb base colours with white according to .alpha
  result <- mixcolor(.alpha, sRGB(1, 1, 1), hex2RGB(.rgb), where = "LAB")
  return(hex(result)) # convert result to rgb hex string
}

# get the mixed colours
cod5_mode %>%
  mutate(
    # add the corresponding base colour to each row
    base_col = cpal[cod],
    # discretize the px values into intervals of width 1/5
    # output is integer giving the position of the interval (1,2,3,4)
    px_disc = cut(px, breaks,
                  labels = FALSE, include.lowest = TRUE),
    # mix each base colour with white
    mix_col = MixWithWhite(.rgb = base_col, .alpha = alphas[px_disc])
  ) -> cod5_mode_mix

# Plot Lexis Surface of Most Prominent Cause of Death ---------------------

# Now we are ready to plot the result. A Lexis surface plot showing for each
# intersection of period and age the most prominent cause of death and its
# share on the total deaths.

plot_qual_seq <-
  cod5_mode_mix %>%
  filter(sex == "total") %>%
  # align tiles with grid
  mutate(
    year = year + 0.5,
    age_start = age_start+age_width/2
  ) %>%
  ggplot() +
  # coloured Lexis surface
  geom_tile(aes(x = year, width = 1,
                y = age_start, height = age_width,
                fill = mix_col)) +
  # Lexis grid
  geom_hline(yintercept = seq(10, 100, 10),
             alpha = 0.2, lty = "dotted") +
  geom_vline(xintercept = seq(1930, 1990, 10),
             alpha = 0.2, lty = "dotted") +
  geom_abline(intercept = seq(-100, 100, 10)-1930,
              alpha = 0.2, lty = "dotted") +
  # scale
  scale_fill_identity() +
  scale_x_continuous("Year", expand = c(0.02, 0),
                     breaks = seq(1930, 1990, 10)) +
  scale_y_continuous("Age", expand = c(0, 0),
                     breaks = seq(0, 100, 10)) +
  # coord
  coord_equal() +
  # theme
  theme_void() +
  theme(
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text()
  )

#ggsave("./out/fig/qual_seq_raw.pdf", plot_qual_seq,
#       width = 5, height = 7)

# Plot Qualitative Sequential Legend --------------------------------------

# Based on our definition of base colours, breaks and alpha levels we plot
# the legend for the plot.

# mix each base colour with each alpha level
lgnd_mixed <- t(sapply(cpal, function (x) MixWithWhite(x, alphas)))
# transform into long format with positions for ggplotting
lgnd_data <- expand.grid(x = 1:nrow(lgnd_mixed),
                        y = 1:ncol(lgnd_mixed))
lgnd_data$col <- as.vector(lgnd_mixed)

# plot qualitative sequential legend
plot_qual_seq_lgnd <-
  ggplot(lgnd_data) +
  geom_tile(aes(x = x, y = y, fill = col),
            colour = "white", lwd = 1) +
  scale_fill_identity() +
  scale_x_continuous(breaks = 1:length(cpal),
                     labels = names(cpal),
                     expand = c(0,0)) +
  scale_y_continuous(breaks = 1:(length(alphas)+1)-0.5,
                     labels = breaks*100,
                     expand = c(0,0)) +
  coord_fixed(4) +
  theme_void() +
  theme(
    plot.margin = unit(rep(10, 4), "pt"),
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text(vjust = 0.5, hjust = 1, angle = 90)
  )

#ggsave("./out/fig/qual_seq_lgnd_raw.pdf", plot_qual_seq_lgnd,
#       width = 2, height = 4)