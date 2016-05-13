#########################################################################
# Plot Small Multiple Lexis Surfaces with Outlined Modal Cause of Death #
#########################################################################

# Init --------------------------------------------------------------------

library(readr)
library(rgeos)
library(raster)
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------

# proportions of 10 selected causes of death on
# all causes of death by year, age and sex
cod10 <- read_csv("./data/plots/cod10.csv")

# Generate Outline for Modal COD Areas ------------------------------------

# In order to outline the areas where a given cause of death is the most
# common one we use libraries and functions for geospatial manipulation.
# 0) Generate a 1x1 Lexis surface. The `raster` package we are going to use
#    later on expects each tile/cell/pixel to have the same dimensions,
# 1) generate a Lexis surface with value 1 (modal cause of death) or NA (not
#    modal cause of death),
# 2) convert to a raster object,
# 3) generate polygons along the cells with value 1; dissolve neighboring
#    polygons,
# 4) convert polygon object back to data frame,
# 5) plot as path in ggplot.

# generate a 1x1 Lexis surface
left_join(
  # a full 1x1 Lexis grid by sex and cod
  expand.grid(year      = unique(cod10$year),
              age_start = 0:104,
              age_width = 1,
              sex       = unique(cod10$sex),
              cod       = unique(cod10$cod),
              stringsAsFactors = FALSE
  ),
  # the original data in irregular age categories
  select(cod10, -age, -age_width)
) %>%
  # the px values for the new ages are copied over
  # from the observed px values of the corresponding
  # age groups. we sort in a suitable fashion and perform
  # "last observation carried forward".
  arrange(sex, year, cod, age_start) %>%
  mutate(px = zoo::na.locf(.$px)) -> cod10_1x1

# Within each year, sex and age category, we look for the cause of death with
# the highest proportion on all deaths and subset to that cause. The result is
# a data set with the most prominent cause of death for each tile on the Lexis
# surface.

cod10_1x1 %>%
  group_by(sex, year, age_start) %>%
  mutate(cod_mode = ifelse(px == max(px), 1, NA)) %>%
  ungroup() -> cod10_mode

# For each Lexis surface by sex and cause of death we outline the areas where
# the proportion of the cause of death is highest among all causes of death. In
# order to do so we use some fancy geospatial manipulations as described above.

cod10_mode %>% group_by(sex, cod) %>%
do(
  {
    # convert to matrix [age,period]
    M <-
      matrix(
        .$cod_mode,
        nrow = n_distinct(.$age_start),
        ncol = n_distinct(.$year),
        dimnames = list(unique(.$age_start),
                        unique(.$year))
      )
    # last row becomes the first and so on
    M <- apply(M, 2, rev)

    # convert matrix to raster
    # each raster has 1650 cells, e.g. 22 age groups * 75 single years
    # we have to set the dimensions of the raster to the dimensions of
    # the Lexis surface
    R <- raster(M,
                xmn = min(.$year),
                xmx = max(.$year)+1,
                ymn = min(.$age_start),
                ymx = max(.$age_start)+1)

    # outline the cells with value 1 with polygons and convert to data frame
    outline <- fortify(rasterToPolygons(R, dissolve = TRUE))

    data.frame(x = outline$lon, y = outline$lat, group = outline$group)
  }
) -> cod10_mode_outline

# Plot Small Multiples ----------------------------------------------------

plot_small_multiples <-
  ggplot() +
  # Lexis surface heatmap
  geom_tile(aes(x = year+0.5, y = age_start+age_width/2,
                width = 1, height = age_width,
                fill = cut_interval(px, length = 0.1)),
            data = filter(cod10, sex == "total")) +
  # Lexis surface outline
  geom_path(aes(x = x, y = y, group = group),
            data = filter(cod10_mode_outline, sex == "total"),
            lwd = 0.3) +
  # scale
  scale_fill_brewer(type = "seq", palette = "PuBuGn",
                    guide = guide_legend(reverse = TRUE)) +
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
    axis.text   = element_text(colour = "black"),
    axis.text.y = element_text(),
    axis.text.x = element_text(),
    panel.margin = unit(0, "cm")
  )

ggsave("./fig/small_multiples/small_multiples_raw.svg", plot_small_multiples,
       width = 10, height = 6)
