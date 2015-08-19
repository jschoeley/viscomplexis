# Data for Simulated Lexis FX ---------------------------------------------

# simulate Gaussian Lexis data
lexis_exmpl <- data.frame(expand.grid(1900:1950, 0:99),
                          value = rnorm(5100, 100, sd = 10))
names(lexis_exmpl) <- c("Year", "Age", "Value")

# Simulate a multiplicative Lexis FX
SimulateLexisFx <- function (.x, .lower, .upper, .measure, .n, .fx) {
  # random bounds for fx
  upper <- rnorm(.n, .upper, sd = 1)
  lower <- rnorm(.n, .lower, sd = 1)
  # find indices of values falling within bounds
  if (.measure == "Cohort") {
    i <- which(.x$Year - .x$Age >= lower & .x$Year - .x$Age <= upper)
  } else
    i <- which(.x[, .measure] >= lower & .x[.measure] <= upper)
  # add multiplicative fx
  .x$Value[i] <- .x$Value[i] * .fx

  return(.x$Value)
}

# add age, period and cohort FX
lexis_exmpl$age_fx <- SimulateLexisFx(lexis_exmpl, 50, 60, "Age", 5100, 1.5)
lexis_exmpl$per_fx <- SimulateLexisFx(lexis_exmpl, 1920, 1930, "Year", 5100, 1.5)
lexis_exmpl$coh_fx <- SimulateLexisFx(lexis_exmpl, 1900, 1910, "Cohort", 5100, 1.5)

# long format
lexis_exmpl %>% as_data_frame %>%
  gather(key = Timeframe, value = fx,
         age_fx, per_fx, coh_fx) -> lexis_exmpl_long

# new variable names
levels(lexis_exmpl_long$Timeframe) <-
  c("Age effect", "Period effect", "Cohort effect")

# Plot Simulated Age, Cohort and Period FX --------------------------------

plot_lexis_fx <-
  ggplot(lexis_exmpl_long) +
  # main
  geom_tile(aes(x = Year, y = Age, fill = fx)) +
  geom_hline(yintercept = seq(10, 90, 10),
             colour = "white", size = 0.3, alpha = 0.7) +
  geom_vline(xintercept = seq(1910, 1950, 10),
             colour = "white", size = 0.3, alpha = 0.7) +
  geom_abline(intercept = seq(-80, 100, 10) - 1910,
              colour = "white", size = 0.3, alpha = 0.7) +
  # scale
  scale_x_continuous(breaks = c(1900, 1920, 1940),
                     labels = c(1900, "'20", "'40")) +
  scale_y_continuous(breaks = seq(20, 100, 20)) +
  scale_fill_continuous(name = "z",
                        low = "#000000", high = "#EAEAEA") +
  # coord
  coord_equal(ylim = c(0, 101), xlim = c(1899, 1951)) +
  # facet
  facet_grid(~ Timeframe) +
  # theme
  ggtheme_min(base_size = font_size + 8, base_family = font_family) +
  theme(axis.ticks.margin = unit(5, "pt"))

ExportPDF(plot_lexis_fx, "./fig/lexis_fx.pdf", 25, 13)

# Plot Lexis Example ------------------------------------------------------

plot_lexis_exmpl <-
  ggplot() +
  # main
  geom_hline(yintercept = seq(0, 100, 10), colour = "grey") +
  geom_vline(xintercept = seq(1900, 2000, 10), colour = "grey") +
  geom_abline(intercept = seq(-80, 100, 10) - 1910, colour = "grey") +
  geom_rect(aes(xmin = 1950, xmax = 1960, ymin = 0, ymax = Inf),
            fill = "black", alpha = 0.5) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 50, ymax = 60),
            fill = "black", alpha = 0.5) +
  geom_polygon(aes(x = c(1920, 2001, 2001, 1930), y = c(0, 81, 71, 0)),
               fill = "black", alpha = 0.5) +
  # scale
  scale_x_continuous("Year",
                     breaks = c(1900, seq(1920, 1980, 20)),
                     labels = c(1900, "'20", "'40", "'60", "'80")) +
  scale_y_continuous("Age", breaks = seq(20, 100, 20)) +
  # coord
  coord_equal(ylim = c(0, 101), xlim = c(1899, 2001)) +
  # annot
  annotate("text", family = font_family, angle = 90,
           label = "Period 1950-1960", x = 1955, y = 75,
           colour = "white", size = 6) +
  annotate("text", family = font_family, angle = 0,
           label = "Age 50-60", x = 1915, y = 55,
           colour = "white", size = 6) +
  annotate("text", family = font_family, angle = 45,
           label = "Birthcohort 1920-1930", x = 1950, y = 25,
           colour = "white", size = 6) +
  # theme
  ggtheme_min(base_size = font_size + 10, base_family = font_family) +
  theme(axis.ticks.margin = unit(5, "pt"))

ExportPDF(plot_lexis_exmpl, "./fig/lexis_exmpl.pdf", 25, 13)