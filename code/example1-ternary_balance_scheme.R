#############################################
# Plot Ternary Balance Scheme Lexis Surface #
#############################################

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------

# proportions of 3 selected causes of death on
# all causes of death by year, age and sex
cod3 <- read_csv("./data/plots/cod3.csv")

# Functions ---------------------------------------------------------------

#' Convert Polar Coordinates to Cartesian Coordinates
#'
#' @param .r     radius in radians
#' @param .theta angle in radians
#'
#' @return Cartesian coordinates xy.
Pol2Cart <- function (.r, .theta) {
  x <- .r*cos(.theta)
  y <- .r*sin(.theta)

  return(cbind(x = x, y = y))
}

#' Convert Cartesian Coordinates to Polar Coordinates
#'
#' @param .x Cartesian x position
#' @param .y Cartesian y position
#'
#' @return Radius \code{r} and angle \code{theta} in radians.
Cart2Pol <- function (.x, .y) {

  r     <- sqrt(.x^2 + .y^2)
  theta <- atan2(.y, .x)

  return(cbind(r = r, theta = theta))
}

#' Add Vectors in Polar Coordinates
#'
#' @param .h hue as theta, polar angle in radians
#' @param .c chroma as r, polar radius
#'
#' @details The origin of the vectors is assumed to be (0, 0). The
#'   vectors are added in Cartesian coordinates with the results being
#'   converted back to polar.
#'
#' @return Sum of vectors in polar coordinates (r, theta).
AddPolVec <- function (.h, .c) {

  cart     <- Pol2Cart(.r = .c, .theta = .h)
  cart_sum <- apply(cart, 2, sum)
  pol_sum  <- Cart2Pol(.x = cart_sum[1], .y = cart_sum[2])

  return(pol_sum)
}

#' Return Ternary Balance Scheme Colours for 2-Simplex
#'
#' The 3 elements of the input vector are mapped to 3 primary colours. These
#' colours are mixed with each other according to the proportions of the
#' elements in the input vector.
#'
#' @param .simplex2 3 element vector of proportions in [0,1]
#' @param .L        lightness of mixed colour
#' @param .C        maximum possible chroma
#' @param .H        hue of the first primary in angular degrees
#' @param .rev      reverse vector of primaries

#'
#' @details The colour mixing takes place in the CIE-LCH colour space. The
#'   lightness is held constant according to the specification in \code{.L}
#'   where higher values correspond to lighter colours. The chroma depends on
#'   the proportions of the vector elements. The more equal the proportions, the
#'   lower the chroma, vice versa. The maximum chroma value specified in
#'   \code{.C} can only be reached if a single element of the vector is equal to
#'   the sum of the vector, that is, if that element completely dominates the
#'   vector. Each vector element is assigned a primary colour. The hue of the
#'   first primary colour (the primary of the first vector element) is
#'   determined by the value of \code{.H}, an angular degree value. The other
#'   two primarys are derived by finding equally spaced positions along the
#'   circumference of a circle (the "colour wheel"). Changing the value of
#'   \code{.H} changes the primarys assigned to each element of the vector.
#'
#' @result A Hex-code string representing the mixed colour.
MixTernBalance <- function (.simplex2, .l = 80, .c = 140, .h = 90, .rev = FALSE) {

  # generate primary colours starting with a value H in [0, 360) and then
  # picking two equidistant points on the circumference of the colour wheel
  primaries <- (.h + c(0, 120, 240)) %% 360
  if (.rev == TRUE) primaries <- rev(primaries)

  # scale chroma according to the group proportions: [0, .C]
  chroma <- .simplex2*.c

  # mix group colours using vector addition in polar LCH coordinates
  mixed_coord <- AddPolVec(.h = primaries*pi/180, # convert degrees to radians
                           .c = chroma)

  # convert to hex-rgb
  mixed_hex_rgb <-
    colorspace::hex(colorspace::polarLAB(L = .l, C = mixed_coord[1],
                                         # convert radians to degrees
                                         H = mixed_coord[2]*180/pi),
                    fixup = TRUE)

  return(mixed_hex_rgb)

}

#' Generate a 2-Simplex for Use in Ternary Balance Legend
#'
#' @usage Simp2()
#'
#' @return A Data frame containing all combinations of 3 numbers from set {0,
#'   0.1, 0.2, ... 0.9, 1} summing up to 1.
Simp2 <- function () {
  # all combinations of 3 numbers from set:
  # {0, 0.1, 0.2, ..., 0.9, 1}
  S <- seq(0, 1, 0.1)
  comb <- expand.grid(x = S, y = S, z = S)

  # filter to those whose sum is equal to 1
  # we round to avoid floating point errors messing
  # up our comparison (e.g. 0.9999999999999994 != 1)
  simp2 <- comb[which(round(rowSums(comb),5) == 1),]
  rownames(simp2) <- seq_along(simp2[,1])

  return(simp2)
}

# Plot Ternary Balance Scheme ---------------------------------------------

# We take the share of deaths [0,1] by cause over year, age and sex and derive
# the mixed colours in hex code. These colours are then used directly by ggplot
# as fill colours for each tile in the Lexis-surface.
cod3 %>%
  group_by(year, age, sex) %>%
  # do the ternary balance scheme colour mixing...
  mutate(rgb = MixTernBalance(.simplex2 = px, .h = 320)) %>%
  ungroup() -> cod3_mix

# plot the Lexis surface
plot_tern_balance <-
  cod3_mix %>%
  filter(sex == "total") %>%
  # align tiles with grid (by default they are placed at tile midpoint)
  mutate(
    year = year + 0.5,
    age_start = age_start + age_width/2
  ) %>%
  ggplot() +
  # main
  geom_tile(aes(x = year, width = 1,
                y = age_start, height = age_width,
                fill = rgb)) +
  # grid
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
  # annotation
  annotate("point", x = 1990, y = 57, shape = 21) +
  annotate("text", x = 1990, y = 57, label = "italic(A)",
           size = 4,
           hjust = -0.3, vjust = 1, parse = TRUE) +
  # theme
  theme_void() +
  theme(
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text()
  )

ggsave("./fig/ternary_balance/tern_balance_raw.pdf", plot_tern_balance,
       width = 5, height = 7)

# Plot Ternary Balance Scheme Legend --------------------------------------

# We generate the legend, a colour coded ternary diagram. For each ternary
# combination of {0.1, ..., 1} which sums to 1 we derive the mixed colour.

library(ggtern)

# generate data for the legend
Simp2() %>%
  group_by(rownames(.)) %>%
  mutate(rgb = MixTernBalance(c(x, y, z), .h = 320)) -> simp2_mix

# plot legend as colour-coded ternary diagram
plot_tern_balance_lgnd <-
  ggplot(simp2_mix, aes(x = x, y = y, z = z)) +
  # main
  geom_point(aes(fill = rgb), size = 8, pch = 21) +
  scale_fill_identity() +
  coord_tern() +
  # scale
  scale_L_continuous("External") +
  scale_T_continuous("Neoplasms") +
  scale_R_continuous("Other") +
  # arrows
  Larrowlab("% External") +
  Tarrowlab("% Neoplasms") +
  Rarrowlab("% Other") +
  # theme
  theme_minimal() +
  theme(
    tern.axis.arrow.show = TRUE,
    tern.axis.ticks = element_blank(),
    tern.axis.ticks.length.major = unit(12, "pt"),
    tern.axis.text = element_text(size = 12, colour = "black"),
    tern.panel.background = element_blank(), # disable clipping region
    tern.axis.title.T = element_text(),
    tern.axis.title.L = element_text(hjust = 0.2, vjust = 1, angle = -60),
    tern.axis.title.R = element_text(hjust = 0.8, vjust = 0.6, angle = 60)
  )

ggsave("./fig/ternary_balance/tern_balance_lgnd_raw.pdf", plot_tern_balance_lgnd,
       width = 5, height = 5)

# Plot Ternary Balance Legend Explanation ---------------------------------

plot_tern_balance_exmpl <-
  plot_tern_balance_lgnd +
  scale_L_continuous("Group 1") +
  scale_T_continuous("Group 2") +
  scale_R_continuous("Group 3") +
  Tarrowlab("% Group 2") +
  Larrowlab("% Group 1") +
  Rarrowlab("% Group 3")

ggsave("./fig/ternary_balance/tern_balance_exmpl_raw.pdf", plot_tern_balance_exmpl,
       width = 5, height = 5)
