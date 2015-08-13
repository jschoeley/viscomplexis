# Util ----------------------------------------------------------

#' Export Graphical Object as PDF
#'
#' @param .x Graphical object
#' @param .path Filesystem destination to save object.
#' @param .width Figure width in cm.
#' @param .height Figure height in cm.
#'
#' @return PDF output to disk.
ExportPDF <- function (.x, .path, .width, .height) {
  pdf(.path, width = 0.4*.width, height = 0.4*.height,
      useDingbats = FALSE) # avoid problems with missing fonts
  grid.newpage()
  vp <- viewport(x = 0.5, y = 0.5,
                 width = unit(.width, "cm"),
                 height = unit(.height, "cm"))
  pushViewport(vp)

  print(.x, vp = vp)
  dev.off()
}

#' Convert RGB + Alpha Specification to RGB
#'
#' @details Assuming alpha blending with white background.
#'
#' @param .rgb RGB value in hex-code.
#' @param .alpha Alpha value within [0,1].
#'
#' @return RGB-hex value of RGB + alpha after blending with white
#'   background.
AlphaRGBToRGB <- function (.rgb, .alpha) {

  # convert colour hex to (s)rgb
  rgb <- col2rgb(.rgb)
  srgb <- rgb / 255
  # mix colours
  result <-
    mixcolor(.alpha, # mix according to these alpha
             sRGB(1, 1, 1), # mix with white background
             sRGB(srgb[1], srgb[2], srgb[3]))

  return(hex(result))
}