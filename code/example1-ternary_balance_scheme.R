#############################################
# Plot Ternary Balance Scheme Lexis Surface #
#############################################

# We plot a Lexis surface of the proportions among three causes of death accross
# period and age using a discrete ternary-balance-scheme colour scale derived
# from the CIE-Lch colour space. We also produce a version of that plot
# featuring a continuous ternary scale and overlaid contour lines of overall
# mortality.

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(ggplot2)
library(ggtern)
library(colorspace)

# Data --------------------------------------------------------------------

# proportions of 3 selected causes of death on
# all causes of death by year, age and sex
cod3 <- read_csv("./out/data/cod3.csv")

# Lexis surface of mortality rates
mx <- read_csv("./out/data/mx.csv")

# Functions for Ternary Geometry ------------------------------------------

#' Centroid Coordinates in Segmented Ternary Diagram
#'
#' @param k Number of rows in the segmented ternary diagram
#'
#' @return A matrix of ternary centroid coordinates of regions i in row j.
#'
#' @details We operate on a ternary diagram segmented into k^2 regular triangles
#'   of equal size. The regular triangles are indexed by row j and row-member i.
#'   See S. H. Derakhshan and C. V. Deutsch (2009): A Color Scale for Ternary
#'   Mixtures for further details.
TernaryCentroidCoord <- function (k) {
  centroids <- matrix(nrow = k^2, ncol = 5,
                      dimnames = list(NULL, c("j", "i", "p1", "p2", "p3")))
  for (j in 1:k) {
    for (i in 1:(2*k - 2*j + 1)) {
      p1 = (6*k - 6*j - 3*i + 4 + i%%2) / (6*k)
      p2 = (6*j - 2 - 2*i%%2) / (6*k)
      p3 = (3*i - 2 + i%%2) / (6*k)
      centroids[i+(j-1)*(2*k-j+1),] = c(j, i, p1, p2, p3)
    }
  }
  return(centroids)
}

#' Distance Between Two Points in Ternary Coordinates
#'
#' @param p,c ternary coordinates as vector of length 3
#'
#' @return Distance between p and c.
TernaryDistance <- function(p, c) {
  q = p-c
  d = -q[2]*q[3] - q[3]*q[1] - q[1]*q[2]
  return(d)
}

#' For Ternary Coordinate p Return the Nearest Coordinate in Set C
#'
#' @param p ternary coordinate as vector of length 3
#' @param C matrix of ternary coordinates
#' @param index return row index of match instead of match
#'
#' @return The ternary coordinates in C with the lowest distance to p or the row
#'   index of these coordinates.
TernaryNearest <- function (p, C, index = FALSE) {
  i <- nnet::which.is.max(# breaking ties at random
    apply(C, 1, function (x) -TernaryDistance(p, x))
  )
  # return index of values or values
  return(ifelse(index, i, C[i,]))
}

#' Vertex Coordinates Given Centroids in Segmented Ternary Diagram
#'
#' @param p ternary coordinate as vector of length 3
#' @param i row member index of centroid
#' @param k row index of centroid
#'
#' @return A matrix of vertices around each centroid.
#'
#' @details We operate on a ternary diagram segmented into k^2 regular triangles
#'   of equal size. The regular triangles are indexed by row j and row-member i.
#'   See S. H. Derakhshan and C. V. Deutsch (2009): A Color Scale for Ternary
#'   Mixtures for further details.

TernaryVerticesFromCentroid <- function (p, i, k) {
  term1 = ((-1)^(i %% 2) * 2) / (3*k)
  term2 = ((-1)^(i %% 2)) / (3*k)
  A = c(p[1] - term1, p[2] + term2, p[3] + term2)
  B = c(p[1] + term2, p[2] - term1, p[3] + term2)
  C = c(p[1] + term2, p[2] + term2, p[3] - term1)
  return(matrix(c(A, B, C), 3, 3, byrow = TRUE))
}

# Function for Deriving Mixed Colour from Ternary Compositions ------------

#' Add Polar Coordinate Vectors
#'
#' @param .phi polar angle in radians
#' @param .r   radius
#'
#' @details Each vector (phi_i, r_i) is represented as a complex number in
#'   polar form z_i = r_i*exp(i phi_i). The resultant vector P = sum_i(z_i) has
#'   polar angle Arg(P) and radius abs(P).
#'
#' @return Sum of vectors in polar coordinates (r, theta).
AddPolVec <- function (.phi, .r) {
  z = complex(argument = .phi, modulus = .r)
  resultant = sum(z)
  return(list(phi = Arg(resultant), r = abs(resultant)))
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
#' @param .contrast increases chroma and lightness contrast between primary
#'   colours and mixtures [0=no additional contrast, 1=maximal additional
#'   contrast]
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
MixTernBalance <- function (.simplex2, .l = 80, .c = 140, .h = 90, .rev = FALSE,
                            .contrast = 0) {

  # generate primary colours starting with a value H in [0, 360) and then
  # picking two equidistant points on the circumference of the colour wheel
  primaries = (.h + c(0, 120, 240)) %% 360
  if (.rev == TRUE) primaries <- rev(primaries)

  # scale chroma according to the group proportions: [0, .C]
  chroma <- .simplex2*.c

  # mix group colours using vector addition in polar LCH coordinates
  mixed_coord <- AddPolVec(.phi = primaries*pi/180, # convert degrees to radians
                           .r = chroma)

  # boost lightness and chroma contrast of balanced to unbalanced mixtures
  contrast_factor = scales::rescale(mixed_coord$r,
                                    from = c(0, .c), to = c(1-.contrast, 1))
  l = contrast_factor*.l
  C = contrast_factor*mixed_coord$r

  # convert to hex-rgb
  mixed_hex_rgb <-
    colorspace::hex(colorspace::polarLAB(L = l,
                                         C = C,
                                         # convert radians to degrees
                                         H = mixed_coord$phi*180/pi),
                    fixup = TRUE)

  return(mixed_hex_rgb)

}

# Plot Ternary Balance Scheme ---------------------------------------------

k = 5   # number of intervals along the ternary scale (high k for smooth colour transitions)
l = 90  # lightness of colour mixture
c = 140 # chroma of colour mixture
h = 320 # initial hue of colour mixture
contrast = 0.5 # introduce lightness and additional chroma contrast between
               # mixed colours

# We map our data onto a set of points in a ternary diagram and derive a mixed
# colour for each point.
as_data_frame(TernaryCentroidCoord(k)) %>%
  rowwise() %>%
  mutate(rgb = MixTernBalance(c(p1, p2, p3), .l = l, .c = c, .h = h, .contrast = contrast)) %>%
  ungroup() -> ternary_centroids

# We take the share of deaths [0,1] by cause over year, age and sex and derive
# the mixed colours in hex code. These colours are then used directly by ggplot
# as fill colours for each tile in the Lexis-surface.
cod3 %>%
  group_by(year, age, sex) %>%
  # quantize each data point to nearest ternary centroid and get
  # corresponding colour mixture
  mutate(
    rgb = ternary_centroids$rgb[
    TernaryNearest(px, ternary_centroids[,3:5], index = TRUE)
    ]
  ) %>%
  ungroup() -> cod3_mix

# plot the Lexis surface
plot_tern_balance <-
  ggplot() +
  # ternary composition
  geom_tile(aes(x = year+.5, width = 1,
               y = age_start + age_width/2, height = age_width,
               fill = rgb), data = filter(cod3_mix, sex == "total")) +
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
  # theme
  theme_void() +
  theme(
    axis.text = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text()
  )

#ggsave("./out/fig/tern_balance_raw.pdf", plot_tern_balance,
#       width = 5, height = 7)

# Plot Ternary Balance Scheme Legend --------------------------------------

# We generate the legend, a colour coded ternary diagram segmented into rows
# j_1, ... j_k. Each row is tiled out of each i triangles. Given the centroids
# of each triangle (ji) we calculate the ternary coordinates of the vertices
# for plotting.

# calculate the ternary centroid coordinates and their corresponding mixed
# colours for a ternary diagram with k rows.
as_data_frame(TernaryCentroidCoord(k)) %>%
  rowwise() %>%
  mutate(rgb = MixTernBalance(c(p1, p2, p3), .l = l, .c = c, .h = h, .contrast = contrast)) %>%
  ungroup() -> ternary_centroids

# for each sub-triangle in a ternary diagram with k rows calculate the ternary
# coordinates of the vertices
ternary_centroids %>%
  group_by(j, i) %>%
  do({
    vertices = TernaryVerticesFromCentroid(p = c(.$p1, .$p2, .$p3),
                                           i = .$i, k = k)
    # copy first vertex to close the path
    vertices = rbind(vertices, vertices[1,])
    vertices = as.data.frame(vertices)
    colnames(vertices) <- c("v1", "v2", "v3")
    return(vertices)
  }) %>% ungroup() %>%
  mutate(id = sort(rep(1:(k^2), 4))) -> ternary_vertices

plot_tern_balance_lgnd <-
  ggplot(ternary_vertices) +
  geom_polygon(aes(x = v1, y = v2, z = v3,
                   group = id,
                   fill = factor(id)), colour = "white") +
  # scale
  scale_fill_manual(values = ternary_centroids$rgb, guide = FALSE) +
  scale_L_continuous("External", breaks = seq(0, 1, length.out = k+1)) +
  scale_T_continuous("Neoplasm", breaks = seq(0, 1, length.out = k+1)) +
  scale_R_continuous("Other", breaks = seq(0, 1, length.out = k+1)) +
  # coord
  coord_tern() +
  # arrows
  Larrowlab("% External") +
  Tarrowlab("% Neoplasm") +
  Rarrowlab("% Other") +
  # theme
  theme_classic() +
  theme(
    tern.axis.arrow.show = TRUE,
    tern.axis.ticks.length.major = unit(12, "pt"),
    tern.axis.text = element_text(size = 12, colour = "black"),
    tern.panel.background = element_blank(), # disable clipping region
    tern.axis.title.T = element_text(),
    tern.axis.title.L = element_text(hjust = 0.2, vjust = 1, angle = -60),
    tern.axis.title.R = element_text(hjust = 0.8, vjust = 0.6, angle = 60)
  )

#ggsave("./out/fig/tern_balance_lgnd_raw.pdf", plot_tern_balance_lgnd,
#       width = 5, height = 7)

# Plot Ternary Balance Scheme with Contours -------------------------------

# Same procedure as before, but we use a more continuous colour scale and
# overlay overall mortality rates as contours.

k = 30
l = 90
c = 140
h = 320
contrast = 0.3

as_data_frame(TernaryCentroidCoord(k)) %>%
  rowwise() %>%
  mutate(rgb = MixTernBalance(c(p1, p2, p3), .l = l, .c = c, .h = h, .contrast = contrast)) %>%
  ungroup() -> ternary_centroids

cod3 %>%
  group_by(year, age, sex) %>%
  mutate(rgb = ternary_centroids$rgb[TernaryNearest(px, ternary_centroids[,3:5], index = TRUE)]) %>%
  ungroup() -> cod3_mix

# plot the Lexis surface
plot_tern_balance_cont <-
  ggplot() +
  # ternary composition
  geom_tile(aes(x = year+.5, width = 1,
                y = age_start + age_width/2, height = age_width,
                fill = rgb), data = filter(cod3_mix, sex == "total")) +
  # grid
  geom_hline(yintercept = seq(10, 100, 10),
             alpha = 0.2, lty = "dotted") +
  geom_vline(xintercept = seq(1930, 1990, 10),
             alpha = 0.2, lty = "dotted") +
  geom_abline(intercept = seq(-100, 100, 10)-1930,
              alpha = 0.2, lty = "dotted") +
  # mortality rate contours
  stat_contour(aes(x = year+.5, y = age_start+age_width/2, z = mx),
               breaks = c(.0001, .0003, .0005,
                          .001, .003, .005,
                          .01, .03, .05,
                          .1, .3),
               colour = "#545454", lwd = .3,
               data = filter(mx,sex == "total")) +
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

#ggsave("./out/fig/tern_balance_cont_raw.pdf", plot_tern_balance_cont,
#       width = 5, height = 7)

# Plot Ternary Balance Scheme Legend with Contours ------------------------

as_data_frame(TernaryCentroidCoord(k)) %>%
  rowwise() %>%
  mutate(rgb = MixTernBalance(c(p1, p2, p3), .l = l, .c = c, .h = h, .contrast = contrast)) %>%
  ungroup() -> ternary_centroids

ternary_centroids %>%
  group_by(j, i) %>%
  do({
    vertices = TernaryVerticesFromCentroid(p = c(.$p1, .$p2, .$p3),
                                           i = .$i, k = k)
    # copy first vertex to close the path
    vertices = rbind(vertices, vertices[1,])
    vertices = as.data.frame(vertices)
    colnames(vertices) <- c("v1", "v2", "v3")
    return(vertices)
  }) %>% ungroup() %>%
  mutate(id = sort(rep(1:(k^2), 4))) -> ternary_vertices

plot_tern_balance_cont_lgnd <-
  ggplot(ternary_vertices) +
  geom_polygon(aes(x = v1, y = v2, z = v3,
                   group = id,
                   fill = factor(id))) +
  # scale
  scale_fill_manual(values = ternary_centroids$rgb, guide = FALSE) +
  scale_L_continuous("External", breaks = seq(0, 1, .2)) +
  scale_T_continuous("Neoplasm", breaks = seq(0, 1, .2)) +
  scale_R_continuous("Other", breaks = seq(0, 1, .2)) +
  # coord
  coord_tern() +
  # arrows
  Larrowlab("% External") +
  Tarrowlab("% Neoplasm") +
  Rarrowlab("% Other") +
  # theme
  theme_classic() +
  theme(
    tern.axis.arrow.show = TRUE,
    tern.axis.ticks.length.major = unit(12, "pt"),
    tern.axis.text = element_text(size = 12, colour = "black"),
    tern.panel.background = element_blank(), # disable clipping region
    tern.axis.title.T = element_text(),
    tern.axis.title.L = element_text(hjust = 0.2, vjust = 1, angle = -60),
    tern.axis.title.R = element_text(hjust = 0.8, vjust = 0.6, angle = 60)
  )

#ggsave("./out/fig/tern_balance_lgnd_cont_raw.pdf", plot_tern_balance_cont_lgnd,
#       width = 5, height = 5)
