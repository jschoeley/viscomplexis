# Colour Mixing -----------------------------------------------------------

# share of deaths [0,1] by cause over Year, Age and Sex
counts_3 %>%
  # reorder factors to match specific colours with specific CODs
  mutate(COD = factor(COD, c("Neoplasms", "Other", "External"))) %>%
  # subset to Female & Male
  filter(Sex == "total") %>%
  # do the ternary balance scheme colour mixing...
  do(
    MixTernBalance(
      .x = .$Year, .y = .$Age, .group = .$COD, .p = .$px
    )
  ) -> counts_3_mix

# data for legend
Simp2() %>%
  do(LgndTernBalance(.)) -> tern_lgnd

# Plot Ternary Balance Scheme ---------------------------------------------

plot_tern_balance <-
  ggplot(counts_3_mix) +
  # main
  geom_tile(aes(x = Year, y = Age, fill = factor(ID))) +
  # scale
  scale_fill_manual(values = counts_3_mix$RGB, guide = "none") +
  scale_x_continuous(breaks = c(1925, seq(1930, 1990, 10), 1999),
                     labels = c(1925, "'30", "'40", "'50",
                                "'60", "'70", "'80", "'90", 1999),
                     expand = c(0.005, 0)) +
  # coord
  coord_fixed(ratio = 5) + # age-year := period year
  # annotation
  annotate("point", x = 1990, y = "55-59", shape = 21) +
  annotate("text", x = 1990, y = "55-59", label = "italic(A)",
           family = font_family, size = 4,
           hjust = -0.3, vjust = 1, parse = TRUE) +
  geom_vline(xintercept = seq(1930, 1999, 10),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  geom_hline(yintercept = seq(2, 22, 2),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  # theme
  ggtheme_min(base_size = font_size, base_family = font_family, grid = "n")

ExportPDF(plot_tern_balance, "./fig/tern_balance_no_lgnd.pdf", 13, 17)

# Plot Ternary Balance Scheme Legend --------------------------------------

# plot legend
plot_tern_balance_lgnd <-
  ggplot(tern_lgnd, aes(x = x, y = y, z = z)) +
  # main
  geom_point(aes(fill = as.factor(ID)), size = 8, pch = 21) +
  # coord
  coord_tern(L = "y", T = "x", R = "z") +
  # scale
  scale_fill_manual(values = tern_lgnd$RGB, guide = FALSE) +
  scale_L_continuous("Other") +
  scale_T_continuous("Neoplasms") +
  scale_R_continuous("External") +
  # theme
  theme_bw() +
  theme_hidearrows() +
  theme(panel.grid.tern.minor         = element_blank(),
        axis.tern.text                = element_text(size = 12),
        axis.tern.ticklength.major    = unit(0.5, "cm"),
        axis.tern.title.T             = element_text(vjust = -1),
        axis.tern.title.L             = element_text(hjust = 0.5, vjust = 2.5, angle = -60),
        axis.tern.title.R             = element_text(hjust = 0.5, vjust = 2.5, angle = 60),
        text                          = element_text(family = font_family, size = font_size),
        plot.background               = element_rect(fill = "transparent", colour = NA))

ExportPDF(plot_tern_balance_lgnd, "./fig/tern_balance_lgnd.pdf", 13, 13)

# Plot Ternary Balance Legend Explanation ---------------------------------

plot_tern_balance_exmpl <-
  plot_tern_balance_lgnd +
  theme_bw() +
  scale_L_continuous("Group 1") +
  scale_T_continuous("Group 2") +
  scale_R_continuous("Group 3") +
  theme(panel.grid.tern.minor         = element_blank(),
        axis.tern.text                = element_text(size = 12),
        axis.tern.ticklength.major    = unit(0.5, "cm"),
        axis.tern.title.T             = element_text(vjust = -1),
        axis.tern.title.L             = element_text(hjust = 0.5, vjust = 2.5, angle = -60),
        axis.tern.title.R             = element_text(hjust = 0.5, vjust = 2.5, angle = 60),
        axis.tern.arrowsep            = unit(2, "pt"),
        text                          = element_text(family = font_family, size = font_size),
        plot.background               = element_rect(fill = "transparent", colour = NA))

ExportPDF(plot_tern_balance_exmpl, "./fig/tern_exmpl.pdf", 13, 13)
