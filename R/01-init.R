# Packages ----------------------------------------------------------------

# visualization
library(gridBase)      # integrating grid and base graphics
library(gridExtra)     # extended grid functions
library(ggplot2)       # 2d plotting framework
library(gtable)        # work with ggplot objects
library(ggtern)        # ternary diagrams
                       # devtools::install_bitbucket("nicholasehamilton/ggtern")
library(scales)        # different scales, RGB-alpha functions
library(colorspace)    # handle different colour-spaces
library(rcpal)         # colour palettes (github)
                       # library(devtools); install_github("jschoeley/rcpal")
library(ggtheme)       # flexible minimal ggplot theme (github)
                       # library(devtools); install_github("jschoeley/ggtheme")

# data transformation
library(tidyr)         # tidy data, convert between long and wide
library(dplyr)         # data verbs, operations on subsets of data

# System ------------------------------------------------------------------

# System info
sessionInfo()

# Defaults ----------------------------------------------------------------

# 5 level qualitative colour scheme
cpal_qual_5 <- c(rcpal$quacla[4], # green
                 rcpal$quacla[3], # yellow
                 rcpal$quacla[1], # red
                 rcpal$quacla[5], # purple
                 "#757575")       # grey

# font family
font_family <- "sans"
font_size <- 11
