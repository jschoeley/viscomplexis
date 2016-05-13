# CIE-Lch -----------------------------------------------------------------

# font sizes
size_scales <- 1
size_labels <- 1

# some cielch colours
cielch <- rbind(
  data.frame(h = CircEquiDist(.n = 24, .start = 0), c = 140),
  data.frame(h = CircEquiDist(.n = 16, .start = 0), c = 105),
  data.frame(h = CircEquiDist(.n = 8,  .start = 0), c = 70),
  data.frame(h = CircEquiDist(.n = 4,  .start = 0), c = 35),
  data.frame(h = 0, c = 0)
)
cielch$L  <- 80
cielch$id <- seq_along(cielch[,1])

# polar plot of CIE-Lch slice
plot_cielch <-
  ggplot(data = cielch) +
  # nice polar grid
  geom_hline(yintercept = seq(0, 140,   by = 35), colour = "black", size = 0.5) +
  geom_vline(xintercept = seq(0, 360-1, by = 45), colour = "black", size = 0.5) +
  coord_polar(theta = "x", start = 3*pi/2, direction = -1) +
  scale_x_continuous(limits = c(0, 360)) +
  # group points
  geom_point(aes(x = h, y = c, fill = as.factor(id)), size = 8, pch = 21) +
  scale_fill_manual(values = hex(polarLAB(cielch$L, cielch$c, cielch$h), fixup = TRUE),
                    guide = "none") +
  # theming
  ggtheme_min(grid = "n") +
  theme(axis.text = element_blank(),
        axis.title = element_blank())

# extract panel from ggplot object
plot_cielch_colours <- gtable_filter(ggplotGrob(plot_cielch), "panel")

# design viewport
grid.newpage()
vp_cielch <- viewport(x = 0.5, y = 0.5,
                      width  = unit(10, "cm"),
                      height = unit(10, "cm"))
pushViewport(vp_cielch)

# hue curve
plot_cielch_huecurve <-
  curveGrob(x1 = 0.98, y1 = 0.5, x2 = 0.5, y2 = 0.98,
            curvature = arcCurvature(90), ncp = 1000,
            gp = gpar(fill = "black", lend = 2),
            arrow = arrow(type = "closed", length = unit(0.02, "npc")))
plot_cielch_huetext <-
  textGrob("Hue", x = 0.85, y = 0.85, just = c("left", "bottom"),
           gp = gpar(cex = size_labels, font = 3))
# chroma line
plot_cielch_cromaline <-
  linesGrob(x = c(0.5, 0.13), y = c(0.54, 0.54),
            gp = gpar(fill = "black", lend = 2), # passed to arrow
            arrow = arrow(type = "closed", length = unit(0.02, "npc")))
plot_cielch_cromatext <-
  textGrob("Chroma", x = 0.297, y = 0.55, c("center", "bottom"),
           gp = gpar(cex = size_labels, font = 3))
# hue axis values
plot_cielch_hueaxis <-
  textGrob(parse(text = paste0(seq(0, 270, 90), "*degree")),
           just = "center",
           x = c(0.95, 0.5, 0.036, 0.5), y = c(0.5, 0.95, 0.5, 0.05),
           gp = gpar(cex = size_scales))
# chroma axis values
plot_cielch_chromaaxis <-
  textGrob(as.character(seq(0, 140, 35)), just = "center",
           x = c(0.51, 0.41, 0.31, 0.2, 0.1)-0.03, y = rep(0.45, 5),
           gp = gpar(cex = size_scales))

plot_cielch <- gTree(children = gList(
                     plot_cielch_colours,
                     plot_cielch_huecurve,
                     plot_cielch_huetext,
                     plot_cielch_cromaline,
                     plot_cielch_cromatext,
                     plot_cielch_hueaxis,
                     plot_cielch_chromaaxis))

# draw final plot
pdf('./fig/cielch.pdf', family = font_family,
    width = 11/2.54+0.05, height = 11/2.54, useDingbats = FALSE)
grid.draw(plot_cielch)
dev.off()
