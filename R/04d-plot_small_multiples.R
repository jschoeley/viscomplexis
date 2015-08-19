# Plot Small Multiples ----------------------------------------------------

# subset to modal cause of death for each year, sex, age
counts_10 %>%
  group_by(Year, Sex, Age) %>%
  filter(px == max(px)) %>% ungroup -> counts_10_mode

# annotation data
annot_dat <- data_frame(Year = 1930,
                        Age = factor("30-34"),
                        COD = factor("Infections"))

# plot small multiples of all COD
plot_small_multiples <-
  ggplot(filter(counts_10, Sex == "total")) +
  # aestetic
  geom_tile(aes(x = Year, y = Age,
                fill = cut_interval(px, length = 0.1))) +
  geom_tile(data = filter(counts_10_mode, Sex == "total"),
            aes(x = Year, y = Age),
            fill = "transparent", colour = "black") +
  # annotate
  geom_point(data = annot_dat, aes(x = Year, y = Age), shape = 21,
             colour = "white", fill = "white") +
  geom_text(data = annot_dat, aes(x = Year, y = Age), label = "bold(italic(A))",
            family = font_family, size = 4, colour = "white",
            hjust = -0.3, vjust = 1, parse = TRUE) +
  # scale
  scale_x_continuous(breaks = c(1925, seq(1950, 1990, 20)),
                     labels = c(1925, "'50", "'70", "'90"),
                     expand = c(0.005, 0)) +
  scale_fill_brewer(name = "px", type = "seq", palette = "YlGnBu",
                    guide = guide_legend(reverse = TRUE)) +
  # coord
  coord_fixed(ratio = 5) +
  # facet
  facet_wrap(~ COD, ncol = 5, as.table = TRUE) +
  # theme
  ggtheme_min(base_size = font_size, base_family = font_family, grid = "n")

ExportPDF(plot_small_multiples, "./fig/small_multiples.pdf", 30, 20)
