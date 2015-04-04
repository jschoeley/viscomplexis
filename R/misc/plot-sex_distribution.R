# 1st example -------------------------------------------------------------

# sex distribution data
sex1 <- c(rep(1, 75), rep(2, 25))
sex1 <- factor(sex1, 1:2, c("F", "M"))
sex1 <- data.frame(sex = sex1)

# bar charts
plot.sex1.bar <- ggplot(data = sex1) +
  geom_bar(aes(x = sex, fill = sex)) +
  scale_fill_manual(values = c(hex(polarLAB(80, 140, 45), fixup = TRUE),
                               hex(polarLAB(80, 140, 225), fixup = TRUE))) +
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.ticks.x = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex1.bar <- gtable_filter(ggplotGrob(plot.sex1.bar), "(panel)|(axis-b)|(axis-l)|(xlab)|(ylab)")

# sex distribution coordinates in lch
sex1.coord <-
  data.frame(L = c(80, 80),
             c = c(105, 35),
             h = c(45, 225),
             sex = c(1, 2))
sex1.coord$sex <- factor(sex1.coord$sex, 1:2, c("F", "M"))

# polar plot
plot.sex1.polar <- ggplot(data = sex1.coord) +
  # nice polar grid
  geom_hline(yintercept = seq(0, 140, by = 35), colour = "black", size = 0.2) +
  geom_vline(xintercept = seq(0, 360-1, by = 45), colour = "black", size = 0.2) +
  scale_x_continuous(limits = c(0, 360),
                     breaks = seq(0, 270, 90),
                     labels = parse(text = paste0(seq(0, 270, 90), "*degree"))) +
  coord_polar(theta = "x", start = 3*pi/2, direction = -1) +
  # vectors from center to points
  geom_segment(aes(x = h, xend = h, y = 0, yend = c), size = 1.5) +
  # group points
  geom_point(aes(x = h, y = c, fill = sex), size = 8, pch = 21) +
  scale_fill_manual(values = c(hex(polarLAB(sex1.coord$L,
                                            sex1.coord$c,
                                            sex1.coord$h),
                                   fixup = TRUE))) +
  # composed colour
  geom_point(aes(x = 45, y = 70),
             fill = hex(polarLAB(80, 70, 45), fixup = TRUE),
             size = 8, pch = 21) +
  # theming
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex1.polar <- gtable_filter(ggplotGrob(plot.sex1.polar), "panel")

pdf('./fig/plot-exmpl1a.pdf', family = "Linux Biolinum", width = 3.4, height = 3.4, useDingbats = FALSE)
# combine plots
grid.newpage()
vp.sex1 <- viewport(x = 0.5, y = 0.5, # canvas
                    width = unit(10, "cm"),
                    height = unit(10, "cm"),
                    name = "sex1")
pushViewport(vp.sex1) # use viewport
vp.sex1.polar <- viewport(x = 0.57, y = 0.57, # polar plot
                          width = unit(7.5, "cm"),
                          height = unit(7.5, "cm"),
                          name = "sex1.polar")
pushViewport(vp.sex1.polar) # use viewport
grid.draw(gTree(children = gList(plot.sex1.polar)))
vp.sex1.bar <- viewport(x = 0.1, y = 0.2, # bar chart
                        width = unit(2, "cm"),
                        height = unit(3, "cm"),
                        name = "sex1.bar")
pushViewport(vp.sex1.bar) # use viewport
grid.draw(gTree(children = gList(plot.sex1.bar)))
dev.off()
embed_fonts("./fig/plot-exmpl1a.pdf")

# 2nd Example -------------------------------------------------------------

# sex distribution data
sex2 <- c(rep(1, 50), rep(2, 50))
sex2 <- factor(sex2, 1:2, c("F", "M"))
sex2 <- data.frame(sex = sex2)

# bar charts
plot.sex2.bar <- ggplot(data = sex2) +
  geom_bar(aes(x = sex, fill = sex)) +
  scale_fill_manual(values = c(hex(polarLAB(80, 140, 45), fixup = TRUE),
                               hex(polarLAB(80, 140, 225), fixup = TRUE))) +
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.ticks.x = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex2.bar <- gtable_filter(ggplotGrob(plot.sex2.bar), "(panel)|(axis-b)|(axis-l)|(xlab)|(ylab)")

# sex distribution coordinates in lch
sex2.coord <-
  data.frame(L = c(80, 80),
             c = c(70, 70),
             h = c(45, 225),
             sex = c(1, 2))
sex2.coord$sex <- factor(sex2.coord$sex, 1:2, c("F", "M"))

# polar plot
plot.sex2.polar <- ggplot(data = sex2.coord) +
  # nice polar grid
  geom_hline(yintercept = seq(0, 140, by = 35), colour = "black", size = 0.2) +
  geom_vline(xintercept = seq(0, 360-1, by = 45), colour = "black", size = 0.2) +
  scale_x_continuous(limits = c(0, 360),
                     breaks = seq(0, 270, 90),
                     labels = parse(text = paste0(seq(0, 270, 90), "*degree"))) +
  coord_polar(theta = "x", start = 3*pi/2, direction = -1) +
  # vectors from center to points
  geom_segment(aes(x = h, xend = h, y = 0, yend = c), size = 1.5) +
  # group points
  geom_point(aes(x = h, y = c, fill = sex), size = 8, pch = 21) +
  scale_fill_manual(values = c(hex(polarLAB(sex2.coord$L,
                                            sex2.coord$c,
                                            sex2.coord$h),
                                   fixup = TRUE))) +
  # composed colour
  geom_point(aes(x = 45, y = 0),
             fill = hex(polarLAB(80, 0, 45), fixup = TRUE),
             size = 8, pch = 21) +
  # theming
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex2.polar <- gtable_filter(ggplotGrob(plot.sex2.polar), "panel")

pdf('./fig/plot-exmpl1b.pdf', family = "Linux Biolinum", width = 3.4, height = 3.4, useDingbats = FALSE)
# combine plots
grid.newpage()
vp.sex2 <- viewport(x = 0.5, y = 0.5, # canvas
                    width = unit(10, "cm"),
                    height = unit(10, "cm"),
                    name = "sex2")
pushViewport(vp.sex2) # use viewport
vp.sex2.polar <- viewport(x = 0.57, y = 0.57, # polar plot
                          width = unit(7.5, "cm"),
                          height = unit(7.5, "cm"),
                          name = "sex2.polar")
pushViewport(vp.sex2.polar) # use viewport
grid.draw(gTree(children = gList(plot.sex2.polar)))
vp.sex2.bar <- viewport(x = 0.1, y = 0.2, # bar chart
                        width = unit(2, "cm"),
                        height = unit(3, "cm"),
                        name = "sex2.bar")
pushViewport(vp.sex2.bar) # use viewport
grid.draw(gTree(children = gList(plot.sex2.bar)))
dev.off()
embed_fonts("./fig/plot-exmpl1b.pdf")

# 3rd Example -------------------------------------------------------------

# sex distribution data
sex3 <- c(rep(1, 100), rep(2, 0))
sex3 <- factor(sex3, 1:2, c("F", "M"))
sex3 <- data.frame(sex = sex3)

# bar charts
plot.sex3.bar <- ggplot(data = sex3) +
  geom_bar(aes(x = sex, fill = sex)) +
  scale_fill_manual(values = c(hex(polarLAB(80, 140, 45), fixup = TRUE),
                               hex(polarLAB(80, 140, 225), fixup = TRUE))) +
  scale_x_discrete(drop = FALSE) + # don't drop empty groups
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.ticks.x = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex3.bar <- gtable_filter(ggplotGrob(plot.sex3.bar), "(panel)|(axis-b)|(axis-l)|(xlab)|(ylab)")

# sex distribution coordinates in lch
sex3.coord <-
  data.frame(L = c(80, 80),
             c = c(140, 0),
             h = c(45, 225),
             sex = c(1, 2))
sex3.coord$sex <- factor(sex3.coord$sex, 1:2, c("F", "M"))

# polar plot
plot.sex3.polar <- ggplot(data = sex3.coord) +
  # nice polar grid
  geom_hline(yintercept = seq(0, 140, by = 35), colour = "black", size = 0.2) +
  geom_vline(xintercept = seq(0, 360-1, by = 45), colour = "black", size = 0.2) +
  scale_x_continuous(limits = c(0, 360),
                     breaks = seq(0, 270, 90),
                     labels = parse(text = paste0(seq(0, 270, 90), "*degree"))) +
  coord_polar(theta = "x", start = 3*pi/2, direction = -1) +
  # vectors from center to points
  geom_segment(aes(x = h, xend = h, y = 0, yend = c), size = 1.5) +
  # group points
  geom_point(aes(x = h, y = c, fill = sex), size = 8, pch = 21) +
  scale_fill_manual(values = c(hex(polarLAB(sex3.coord$L,
                                            sex3.coord$c,
                                            sex3.coord$h),
                                   fixup = TRUE))) +
  # theming
  theme_bw() +
  theme(legend.position = "none",
        panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        text = element_text(family = "Linux Biolinum", size = 12))
plot.sex3.polar <- gtable_filter(ggplotGrob(plot.sex3.polar), "panel")

pdf('./fig/plot-exmpl1c.pdf', family = "Linux Biolinum", width = 3.4, height = 3.4, useDingbats = FALSE)
# combine plots
grid.newpage()
vp.sex3 <- viewport(x = 0.5, y = 0.5, # canvas
                    width = unit(10, "cm"),
                    height = unit(10, "cm"),
                    name = "sex3")
pushViewport(vp.sex3) # use viewport
vp.sex3.polar <- viewport(x = 0.57, y = 0.57, # polar plot
                          width = unit(7.5, "cm"),
                          height = unit(7.5, "cm"),
                          name = "sex3.polar")
pushViewport(vp.sex3.polar) # use viewport
grid.draw(gTree(children = gList(plot.sex3.polar)))
vp.sex3.bar <- viewport(x = 0.1, y = 0.2, # bar chart
                        width = unit(2, "cm"),
                        height = unit(3, "cm"),
                        name = "sex3.bar")
pushViewport(vp.sex3.bar) # use viewport
grid.draw(gTree(children = gList(plot.sex3.bar)))
dev.off()
embed_fonts("./fig/plot-exmpl1c.pdf")