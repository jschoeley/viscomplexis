####################################################
# Plot Qualitative Sequential Scheme Lexis Surface #
####################################################

# Init --------------------------------------------------------------------

library(readr)
library(dplyr)
library(tidyr)
library(rgl)
library(mgcv)

# Data --------------------------------------------------------------------

cpal <- c(
  "Circulatory diseases" = "#CB040C",
  "Neoplasms"            = "#B05D00",
  "Infections"           = "#1E6617",
  "External"             = "#A5147B",
  "Other"                = "#18657A"
)

# mortality rates by year, age and sex
mx_male <- read_csv("./out/data/mx.csv") %>% filter(sex == "male")

# proportions of 5 selected causes of death on
# all causes of death by year, age and sex
cod5 <- read_csv("./out/data/cod5.csv")

# Within each year, sex and age category, we look for the cause of death with
# the highest proportion on all deaths and subset to that cause. The result is
# a data set with the most prominent cause of death for each tile on the Lexis
# surface.

cod5 %>%
  group_by(year, age, sex) %>%
  filter(px == max(px)) %>%
  ungroup() %>%
  filter(sex == "male") %>%
  arrange(age_start, year)-> cod5_mode_male

# Smooth Data -------------------------------------------------------------

# visual options
smooth = 0.07 # how much to smooth the mortality surface
resolution = 0.1 # how many polygons to use when drawing the surface
stretch = 10 # how much to stretch the surface along the z axis

# fine surface grid
surface_x = seq(min(mx_male$year), max(mx_male$year), resolution)
surface_y  = seq(min(mx_male$age_start), max(mx_male$age_start), resolution)

# smooth the mortality rate surface
mx_loess_fit <- loess(log(mx) ~ year + age_start,
                      span = smooth,
                      data = mx_male)
mx_loess_smooth <- predict(mx_loess_fit,
                           newdata = expand.grid(year = surface_x, age_start = surface_y))

# smooth the cause of death surface with a multinomial GAM model
cod5_mode_male %>%
  select(year, age_start, cod) %>%
  mutate(cod = as.integer(as.factor(cod))-1) -> cod_gam_format
# read the multinom {mgcv} help page to understand whats going on here
cod_fit <- gam(list(cod ~ s(year) + s(age_start),
                    ~ s(year) + s(age_start),
                    ~ s(year) + s(age_start),
                    ~ s(year) + s(age_start)),
               family = multinom(K = 4),
               data = cod_gam_format)
cod_pred <- predict(cod_fit,
                    newdata = expand.grid(year = surface_x, age_start = surface_y),
                    type = "response")
cod_pred <- apply(cod_pred, 1, function(x) which(max(x)==x)[1])
cols <- recode(c(cod_pred), `1` = cpal[1], `2` = cpal[4],
               `3` = cpal[3], `4` = cpal[2], `5` = cpal[5])

# gridlines
grid_x = seq(1930, 1990, 10); grid_y = seq(0, 100, 10);
grid_z = c(0.0001, 0.0005, 0.001, 0.005,
           0.01, 0.05, 0.1, 0.5)

# Plot 3D Surface of Mortality Rates Coloured by Most Common COD ----------

# plot qualitative-sequential scheme on a 3d-surface
{
  open3d(windowRect = c(0, 0, 1000, 1000))

  # mortality rates as 3d-surface
  surface3d(x = surface_x,
            y = surface_y,
            z = mx_loess_smooth*stretch,
            color = cols)

  # bounding box
  rgl.bbox(color = c("white", "grey"),
           xat = seq(1930, 1990, 20),
           yat = seq(0, 100, 20),
           zat = format(log(grid_z)*stretch, scientific = FALSE),
           zlab = grid_z,
           marklen = 30)

  # period grid
  for (i in grid_x) {
    x = i; y = surface_y
    z = mx_loess_smooth[(i-min(surface_x))*(1/resolution)+1,]*stretch
    lines3d(x, y, z, add = TRUE, alpha = 0.1, lwd = 2,
            line_antialias = TRUE, color = "white")
    lines3d(x, y, min(mx_loess_smooth)*stretch, add = TRUE, alpha = 0.1, lwd = 2,
            line_antialias = TRUE, color = "white")
  }

  # age grid
  for (j in grid_y) {
    x = surface_x; y = j
    z = mx_loess_smooth[,j*(1/resolution)+1]*stretch
    lines3d(x, y, z, add = TRUE, alpha = 0.1, lwd = 2,
            line_antialias = TRUE, color = "white")
    lines3d(x, y, min(mx_loess_smooth)*stretch, add = TRUE, alpha = 0.1, lwd = 2,
            line_antialias = TRUE, color = "white")
  }

  # mortality grid
  for (k in (log(grid_z)*stretch)[-1]) {
    lines3d(x = 1925:1999, y = 100, z = k, add = TRUE, alpha = 0.9, lwd = 2,
            line_antialias = TRUE, color = "white")
    lines3d(x = 1925, y = 0:100, z = k, add = TRUE, alpha = 0.9, lwd = 2,
            line_antialias = TRUE, color = "white")
  }

  # contour lines
  lines <- contourLines(x = surface_x,
                        y = surface_y,
                        z = mx_loess_smooth,
                        levels = log(grid_z))
  for (i in seq_along(lines)) {
    x = lines[[i]]$x
    y = lines[[i]]$y
    z = lines[[i]]$level*stretch
    lines3d(x, y, z, add = TRUE,
            line_antialias = TRUE, color = "white", alpha = 0.1, lwd = 4)
  }

}