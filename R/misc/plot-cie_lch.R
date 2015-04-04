# CIE-Lch -----------------------------------------------------------------

# font sizes
size.scales <- 1
size.labels <- 1


# some cielch colours
cielch <- rbind(
  data.frame(h = CircEquiDist(n = 24),
             c = 140),
  data.frame(h = CircEquiDist(n = 16),
             c = 105),
  data.frame(h = CircEquiDist(n = 8),
             c = 70),
  data.frame(h = CircEquiDist(n = 4),
             c = 35),
  data.frame(h = 0,
             c = 0)
)
cielch$L <- 80
cielch$id <- seq_along(cielch[,1])

# polar plot of CIE-Lch slice
plot.cielch <- ggplot(data = cielch) +
  # nice polar grid
  geom_hline(yintercept = seq(0, 140, by = 35), colour = "black", size = 0.2) +
  geom_vline(xintercept = seq(0, 360-1, by = 45), colour = "black", size = 0.2) +
  coord_polar(theta = "x", start = 3*pi/2, direction = -1) +
  scale_x_continuous(limits = c(0, 360)) +
  # group points
  geom_point(aes(x = h, y = c, fill = as.factor(id)), size = 8, pch = 21) +
  scale_fill_manual(values = hex(polarLAB(cielch$L, cielch$c, cielch$h),
                                 fixup = TRUE)) +
  # theming
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank())
# extract panel from ggplot object
plot.cielch.colours <- gtable_filter(ggplotGrob(plot.cielch), "panel")

# design vieport
grid.newpage()
vp.cielch <- viewport(x = 0.5, y = 0.5,
                      width = unit(10, "cm"),
                      height = unit(10, "cm"))
pushViewport(vp.cielch) # use viewport
#showViewport(vp.cielch)

# hue curve
plot.cielch.huecurve <-
  curveGrob(x1 = 0.98, y1 = 0.5, x2 = 0.5, y2 = 0.98,
            curvature = arcCurvature(90), ncp = 1000, # on circle arc
            gp = gpar(fill = "black", lend = 2), # passed to arrow
            arrow = arrow(type = "closed", length = unit(0.02, "npc")))
plot.cielch.huetext <-
  textGrob("Hue", x = 0.85, y = 0.85, just = c("left", "bottom"),
           gp = gpar(cex = size.labels, font = 3))
# chroma line
plot.cielch.cromaline <-
  linesGrob(x = c(0.5, 0.1), y = c(0.54, 0.54),
            gp = gpar(fill = "black", lend = 2), # passed to arrow
            arrow = arrow(type = "closed", length = unit(0.02, "npc")))
plot.cielch.cromatext <-
  textGrob("Chroma", x = 0.35, y = 0.55, c("center", "bottom"),
           gp = gpar(cex = size.labels, font = 3))
# hue axis values
plot.cielch.hueaxis <-
  textGrob(parse(text = paste0(seq(0, 270, 90), "*degree")),
           just = "center",
           x = c(0.95, 0.5, 0.03, 0.5), y = c(0.5, 0.95, 0.5, 0.05),
           gp = gpar(cex = size.scales))
# chroma axis values
plot.cielch.chromaaxis <-
  grid.text(as.character(seq(0, 140, 35)), just = "center",
           x = seq(0.5, 0.1, length.out = 5), y = rep(0.45, 5),
           gp = gpar(cex = size.scales))

plot.cielch <- gTree(children = gList(
                     plot.cielch.colours,
                     plot.cielch.huecurve,
                     plot.cielch.huetext,
                     plot.cielch.cromaline,
                     plot.cielch.cromatext,
                     plot.cielch.hueaxis,
                     plot.cielch.chromaaxis))

grid.draw(plot.cielch)

# draw final plot
pdf('./fig/plot-cielch.pdf', family = "Palatino", width = 11/2.54, height = 11/2.54, useDingbats = FALSE)
grid.draw(plot.cielch)
dev.off()
embed_fonts("./fig/plot-cielch.pdf")
