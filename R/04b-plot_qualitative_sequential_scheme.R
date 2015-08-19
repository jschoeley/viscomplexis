# Plot Qualitative Sequential Scheme --------------------------------------

# subset to modal cause of death for each year, sex, age
counts_5 %>%
  group_by(Year, Sex, Age) %>%
  filter(px == max(px), Sex == "total") %>%
  ungroup %>% droplevels -> counts_5_mode

# minimum alpha level (used for lowest share category)
alpha_min <- 0.2

# plot qualitative sequential scheme
plot_qual_seq <-
  ggplot(counts_5_mode) +
  # avoid background shine through transparency
  geom_tile(aes(x = Year, y = Age), fill = "white") +
  # main
  geom_tile(aes(x = Year, y = Age, fill = COD,
                alpha = cut_interval(px, length = 0.2)),
            colour = "transparent") +
  # annotate
  geom_vline(xintercept = seq(1930, 1999, 10),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  geom_hline(yintercept = seq(2, 22, 2),
             colour = "black", size = 0.4, alpha = 0.2, lty = 3) +
  geom_hline(yintercept = 14,
             colour = "black", size = 0.4, lty = 2) +
  # scale
  scale_x_continuous(breaks = c(1925, seq(1930, 1990, 10), 1999),
                     labels = c(1925, "'30", "'40", "'50",
                                "'60", "'70", "'80", "'90", 1999),
                     expand = c(0.005, 0)) +
  scale_fill_manual(values = cpal_qual_5, guide = "none") +
  scale_alpha_discrete(range = c(alpha_min, 1), guide = "none") +
  # coord
  coord_fixed(ratio = 5) +
  # theme
  ggtheme_min(base_size = font_size, base_family = font_family, grid = "n")

# Plot Qualitative Sequential Legend --------------------------------------

# sequence of alpha values based on minimum alpha and number of steps
seqnce <- seq(alpha_min, 1, length.out = 4)
# alpha blended base colours
alpha_blend <- sapply(cpal_qual_5, function (.x) AlphaRGBToRGB(.x, seqnce))
alpha_blend <- t(alpha_blend)
# transform into long format with positions and ids for ggplotting
xy_coord <- expand.grid(x = 1:nrow(alpha_blend),
                        y = 1:ncol(alpha_blend))
xy_coord$col <- as.vector(alpha_blend)
xy_coord$id <- seq_along(xy_coord[,1])

# plot qualitative sequential legend
plot_qual_seq_lgnd <-
  ggplot(xy_coord) +
  geom_tile(aes(x = as.factor(x), y = as.factor(y), fill = as.factor(id)),
            colour = "white", lwd = 1) +
  scale_fill_manual(values = xy_coord$col, guide = "none") +
  scale_x_discrete(labels = levels(counts_5$COD)) +
  scale_y_discrete(labels = levels(cut_interval(counts_5_mode$px, length = 0.2))) +
  coord_fixed(4) +
  ggtheme_min(base_size = font_size, base_family = font_family, grid = "n") +
  theme(axis.text.x = element_text(hjust = 1, angle = 90),
        axis.text.y = element_text(hjust = 0.5, angle = 90),
        axis.title = element_blank(),
        axis.ticks = element_blank())

# Merge Legend and Plot ---------------------------------------------------

# a hack to add the legend to the plot and save the result
AddLegQualSeq <- function (.plot, .legend, .path, .width, .height) {
  pdf(.path, width = 0.4*.width, height = 0.4*.height, useDingbats = FALSE)
  grid.newpage()
  print(.plot, vp = viewport(x = 0.5, y = 0.5))
  print(.legend, vp = viewport(x = 0.82, y = 0.5, height = 0.6))
  dev.off()
}

AddLegQualSeq(plot_qual_seq, plot_qual_seq_lgnd, "./fig/qual_seq.pdf", 20, 15)
