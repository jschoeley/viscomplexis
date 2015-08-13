# Ternary Balance ---------------------------------------------------------

#' Translate Lexis Group Compositions Into Ternary Balance Scheme
#'
#' @param .x x-axis values, usually calendar time.
#' @param .y y-axis values, usually age.
#' @param .group Group affiliation.
#' @param .p Group share on total.
#' @param .colour Turn the colour wheel, use angular degrees as input.
#' @param .L Lightness level.
#' @param .C Maximum chroma (saturation) level, used in case of complete
#'   dominance by a single group.
#'
#' @return Ternary balance scheme colours for each xy-position.
MixTernBalance <- function (.x, .y, .group, .p, .colour = 90, .L = 80, .C = 140) {

  # assemble args into data frame
  simp <- data_frame(Year = .x, Age = .y, Group = .group, p = .p)

  # generate base colours for each group
  simp %>%
    # set base hue for each group
    mutate(H = HueToGroup(.group = Group, .start = .colour)) %>%
    # set chroma according to the group shares range: [0, C]
    mutate(C = p * .C) %>%
    # get mixed colors for each year-age
    # mix group colours using vector addition in polarLAB coordinates
    group_by(Year, Age) %>%
    do(data.frame(AddPolVec(.$H, .$C))) %>% ungroup %>%
    # convert to hex-rgb
    mutate(ID = seq_along(Year),
           RGB = hex(polarLAB(L = .L, C = r, H = theta), fixup = TRUE)) -> result

  return(result)
}

#' Construct Data for Ternary Balance Scheme Legend from 2-Simplex
#'
#' @param .simp 2-Simplex as returned by Simp2()
#' @param .colour Turn the colour wheel, use angular degrees as input.
#' @param .L Lightness level.
#' @param .C Maximum chroma (saturation) level, used in case of
#'   complete dominance by a single group.
#'
#' @return Ternary balance scheme colours for each position in ternary
#'   diagram by steps of 0.1.
LgndTernBalance <- function(.simp, .colour = 90, .L = 80, .C = 140) {

  .simp %>%
    # long format
    gather(Group, p, -ID) %>%
    # chroma
    mutate(C = p * .C) %>%
    # hue
    mutate(H = HueToGroup(.group = Group, .start = .colour)) %>%
    # mixed colours
    group_by(ID) %>%
    do(data.frame(AddPolVec(.$H, .$C))) %>% ungroup %>%
    mutate(ID = seq_along(ID),
           RGB = hex(polarLAB(L = .L, C = r, H = theta), fixup = TRUE)) %>%
    # join with original simplex
    left_join(.simp) -> result

  return(result)
}

#' Generate a 2-Simplex for Use in Ternary Balance Legend
#'
#' @usage Simp2()
#'
#' @return Data frame containing all combinations of 3 numbers from set {0, 0.1,
#'   0.2, ... 0.9, 1}.
Simp2 <- function () {

  # all combinations of 3 numbers from set:
  # {0, 0.1, 0.2, ..., 0.9, 1}
  expand.grid(x = seq(0, 1, 0.1),
              y = seq(0, 1, 0.1),
              z = seq(0, 1, 0.1)) %>%
    # sum of individual combinations
    mutate(Sum = rowSums(.)) %>%
    # all combinations which sum is 1 (rounding to avoid FP error)
    filter(round(Sum, 3) == 1) %>% select(-Sum) %>%
    mutate(ID = seq_along(x))-> simp_2

  return(simp_2)
}

#' Assign an Angular Hue Value to Each Group
#'
#' @param .group Group affiliation.
#' @param .start Perimeter position of first point in degrees.
#'
#' @return Equidistant base hue values for groups.
HueToGroup <- function (.group, .start = 0) {

  group_lvl <- levels(.group)
  n         <- length(group_lvl)
  base_h    <- CircEquiDist(.n = n, .start = .start)

  h <- rep(NA, length(.group))
  for (i in group_lvl) {
    h[.group %in% i] <- base_h[group_lvl %in% i]
  }

  return(h)
}