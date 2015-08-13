# Polar coordinates ---------------------------------------------

#' Sin Using Degrees
#'
#' @param x x in degrees.
#'
#' @return y = sin(x).
SinD <- function (.x) {
  result <- sin(.x*pi/180)
  result[.x == 180 | .x == 360] <- 0

  return(result)
}

#' Cos Using Degrees
#'
#' @param x x in degrees.
#'
#' @return y = cos(x).
CosD <- function (.x) {
  result <- cos(.x*pi/180)
  result[.x == 90 | .x == 270] <- 0

  return(result)
}

#' Convert Polar Coordinates to Cartesian Coordiantes
#'
#' @param .r Polar radius.
#' @param .theta Polar angle in degrees.
#'
#' @return Cartesian coordinates xy.
Pol2Cart <- function (.r, .theta) {
  x <- .r*CosD(.theta)
  y <- .r*SinD(.theta)

  return(cbind(x = x, y = y))
}

#' Convert Cartesian Coordinates to Polar Coordinates
#'
#' @param x Cartesian x position.
#' @param y Cartesian y position.
#'
#' @return Polar coordinates r (radius) and theta (angle).
Cart2Pol <- function (.x, .y) {
  r <- sqrt(.x^2 + .y^2)
  theta <- atan2(.y, .x)
  theta <- theta*180/pi # convert to degrees

  return(cbind(r = r, theta = theta))
}

#' Return Angles of Equidistant Points on a Circle Perimeter
#'
#' @param .n Number of points.
#' @param .start Perimeter position of first point in degrees.
#'
#' @return Position of n equidistant points on circle perimeter in
#'   angular degrees.
CircEquiDist <- function (.n, .start) {
  dist <- 360 / .n
  seqn <- cumsum(c(0, rep(dist, .n - 1))) + .start
  seqn[seqn >= 360] <- seqn[seqn >= 360] - 360

  return(seqn)
}

#' Add Vectors in Polar Coordinates
#'
#' @details The origin of the vectors is assumed to be (0, 0). The
#'   vectors are added in cartesian coordinates with the results being
#'   converted back to polar.
#'
#' @param .h Hue as theta, polar direction in degrees.
#' @param .c Chroma as r, polar radius.
#'
#' @return Sum of vectors in polar coordinates (r, theta).
AddPolVec <- function (.h, .c) {
  cart <- Pol2Cart(.r = .c, .theta = .h)
  cart_sum <- apply(cart, 2, sum)
  pol_sum <- Cart2Pol(.x = cart_sum[1], .y = cart_sum[2])

  # handle floating point errors by rounding to next whole number
  pol_sum <- round(pol_sum)

  # make sure the output doesn't use negative degrees
  pol_sum[pol_sum[,2] < 0, 2] <- pol_sum[pol_sum[,2] < 0, 2] + 360

  return(pol_sum)
}