# Plot Small Multiples ----------------------------------------------------

# subset to modal cause of death for each year, sex, age
counts_10 %>%
  group_by(year, sex, age) %>%
  filter(px == max(px)) %>% ungroup -> counts_10_mode

# annotation data
annot_dat <- data_frame(year = 1930,
                        age = factor("30-34"),
                        cod = factor("Infections"))

# plot small multiples of all COD
plot_small_multiples <-
  ggplot(filter(counts_10, sex == "total")) +
  # aestetic
  geom_tile(aes(x = year, y = age,
                fill = cut_interval(px, length = 0.1))) +
  geom_tile(data = filter(counts_10_mode, sex == "total"),
            aes(x = year, y = age),
            fill = "transparent", colour = "black") +
  # annotate
  geom_point(data = annot_dat, aes(x = year, y = age), shape = 21,
             colour = "white", fill = "white") +
  geom_text(data = annot_dat, aes(x = year, y = age), label = "bold(italic(A))",
            family = font_family, size = 4, colour = "white",
            hjust = -0.3, vjust = 1, parse = TRUE) +
  # scale
  scale_x_continuous(name = "Year",
                     breaks = c(1925, seq(1950, 1990, 20)),
                     labels = c(1925, "'50", "'70", "'90"),
                     expand = c(0.005, 0)) +
  scale_y_discrete(name = "Age") +
  scale_fill_brewer(name = "px", type = "seq", palette = "YlGnBu",
                    guide = guide_legend(reverse = TRUE)) +
  # coord
  coord_fixed(ratio = 5) +
  # facet
  facet_wrap(~ cod, ncol = 5, as.table = TRUE)
  # theme
  #ggtheme_min(base_size = font_size, base_family = font_family, grid = "n")

#ExportPDF(plot_small_multiples, "./fig/small_multiples.pdf", 30, 20)
