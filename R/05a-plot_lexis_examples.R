# Data for Lexis example ------------------------------

# simulated lexis data
lexis.example <-
  data.frame(
    expand.grid(1900:1999, 0:99),
    value = rnorm(100000, 100, sd = 10))
names(lexis.example) <- c("Year", "Age", "Value")

# simulated age effect covering ages 50-60
upper <- rnorm(100000, 60, sd = 1) # random upper bound
lower <- rnorm(100000, 50, sd = 1) # random lower bound
lexis.example$agefx <- lexis.example$Value
lexis.example <- within(lexis.example,
                        agefx[Age >= lower & Age <= upper] <-
                          Value[Age >= lower & Age <= upper] * 1.5)

# simulated period effects covering periods 1950-1955
upper <- rnorm(100000, 1960, sd = 1) # random upper bound
lower <- rnorm(100000, 1950, sd = 1) # random lower bound
lexis.example$periodfx <- lexis.example$Value
lexis.example <-
  within(lexis.example,
         periodfx[Year >= lower & Year <= upper] <-
           Value[Year >= lower & Year <= upper] * 1.5)

# simulated cohort effect covering cohorts 1920-1925
upper <- rnorm(100000, 1930, sd = 1) # random upper bound
lower <- rnorm(100000, 1920, sd = 1) # random lower bound
lexis.example$Cohort <- lexis.example$Year - lexis.example$Age
lexis.example$cohortfx <- lexis.example$Value
lexis.example <- within(lexis.example,
                        cohortfx[Cohort >= lower & Cohort <= upper] <-
                          Value[Cohort >= lower & Cohort <= upper] * 1.5)

# long format
lexis.example.long <-
  melt(lexis.example, measure.vars = c("agefx", "periodfx", "cohortfx"))

# new variable names
levels(lexis.example.long$variable) <-
  c("Age effect", "Period effect", "Cohort effect")

# Plot Lexis Example ----------------------------------

plot.lexis.example <-
  ggplot() +
  # aestetics
  geom_hline(yintercept = seq(0, 100, 10), alpha = 0.8) +
  geom_vline(xintercept = seq(1900, 2000, 10), alpha = 0.8) +
  geom_abline(intercept = seq(-80, 100, 10) - 1910, alpha = 0.8) +
  geom_rect(aes(xmin = 1950, xmax = 1960, ymin = 0, ymax = Inf),
            fill = "black", alpha = 0.5) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 50, ymax = 60),
            fill = "black", alpha = 0.5) +
  geom_polygon(aes(x = c(1920, 2001, 2001, 1930), y = c(0, 81, 71, 0)),
            fill = "black", alpha = 0.5) +
  # scale
  scale_x_continuous(name = "Year", breaks = seq(1900, 2000, 20)) +
  scale_y_continuous(name = "Age", breaks = seq(0, 100, 20)) +
  coord_equal(ylim = c(0, 101), xlim = c(1899, 2001)) +
  # annotation
  annotate("text", family = "Linux Biolinum", angle = 90,
           label = "Period 1950-1960", x = 1955, y = 84,
           colour = "white") +
  annotate("text", family = "Linux Biolinum", angle = 0,
           label = "Age 50-60", x = 1910, y = 55,
           colour = "white") +
  annotate("text", family = "Linux Biolinum", angle = 45,
           label = "Birthcohort 1920-1925", x = 1940, y = 15,
           colour = "white") +
  # theme
  theme_minimal() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.ticks = element_blank(),
        axis.ticks.margin = unit(0, "cm"),
        text = element_text(family = "Linux Biolinum", size = 12))

ExportPDF(plot.lexis.example, "./fig/plot-lexis_example.pdf", 15, 15)
embed_fonts("./fig/plot-lexis_example.pdf")

# Plot simulated age, cohort, period fx -----------------------------------

plot.lexis.fx <-
  ggplot(lexis.example.long) +
  # aestetics
  geom_tile(aes(x = Year, y = Age, fill = value)) +
  geom_hline(yintercept = seq(10, 90, 10), colour = "white", alpha = 0.7) +
  geom_vline(xintercept = seq(1910, 1990, 10), colour = "white", alpha = 0.7) +
  geom_abline(intercept = seq(-80, 100, 10) - 1910, colour = "white", alpha = 0.7) +
  # scale
  scale_x_continuous(expand = c(0, 0.01),
                     breaks = seq(1900, 2000, 25),
                     labels = c("1900", "1925", "1950", "1975", "")) +
  scale_y_continuous(expand = c(0, 0.01)) +
  scale_fill_continuous(name = "Some\ncontinuous\nvariable",
                        low = "#000000", high = "#EAEAEA") +
  coord_equal() +
  # facet
  facet_grid(~ variable) +
  # theme
  theme_minimal() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))

ExportPDF(plot.lexis.fx, "./fig/plot-lexis_fx.pdf", 30, 15)
embed_fonts("./fig/plot-lexis_fx.pdf")