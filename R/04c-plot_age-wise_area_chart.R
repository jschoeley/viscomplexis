# Plot Age-wise Area Chart ------------------------------------------------

plot_agewise_area <-
  ggplot(filter(counts_5, sex == "total")) +
  # main
  geom_area(aes(x = year, y = px, fill = cod)) +
  # annotate
  geom_vline(xintercept = seq(1930, 1999, 10),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  # scale
  scale_x_continuous(name = "Year",
                     breaks = c(1925, seq(1930, 1990, 10), 1999),
                     labels = c(1925, "'30", "'40", "'50",
                                "'60", "'70", "'80", "'90", 1999),
                     expand = c(0.005, 0)) +
  scale_fill_brewer("", palette = "Set3") +
  # coord
  coord_fixed(ratio = 5) +
  # facet
  facet_grid(age~. , as.table = FALSE) +
  # theme
  #ggtheme_min(base_size = font_size, base_family = font_family, grid = "n") +
  theme(strip.text.y = element_text(angle = 0, hjust = 1),
        panel.margin = unit(0, "cm"),
        axis.text.y = element_blank())

#ExportPDF(plot_agewise_area, "./fig/agewise_area.pdf", 17, 17)
