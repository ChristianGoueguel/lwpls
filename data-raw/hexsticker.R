# Script used to create the package hex sticker (not part of the package).

library(car)

X <- seq(1, 101)
Y <- X^3 + X^5
Z <- 10e2 + 24*X + 0.1*X^3 + 00.8*Y + 57*Y^3 + 21*X*Y + 9*X^2*Y + 34*X*Y^2

image3d <- scatter3d(
  x = X, y = Y, z = Z,
  fit = "smooth",
  bg.col = "black",
  surface.col = "skyblue",
  surface.alpha = 1,
  point.col = "gold",
  grid.col = "white",
  residuals = TRUE,
  surface = TRUE,
  axis.scales = FALSE
  )

rgl::rgl.snapshot(filename = "data-raw/image3d.png")

hexSticker::sticker(
  subplot = "data-raw/image3d.png",
  package = "lwpls",
  p_y = 1.55,
  p_x = 1.05,
  p_size = 27,
  p_color = "gold",
  s_x = 0.9,
  s_y = 0.83,
  s_width = 0.51,
  s_height = 0.4,
  h_fill = "black",
  h_color = "#F2AA4CFF",
  url = "https://github.com/ChristianGoueguel/lwpls",
  u_color = "gold",
  u_size = 3.5,
  spotlight = TRUE,
  l_x = 0.9,
  l_y = 0.8,
  l_width = 20,
  l_alpha = 0.5,
  filename = "inst/figures/pkg_sticker.png",
  )

# usethis::use_logo(img = "inst/figures/pkg_sticker.png", geometry = "250x300", retina = TRUE)
