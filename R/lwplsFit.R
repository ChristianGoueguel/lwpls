lwplsFit <- function(x, y,  num_comp = NULL, shapefactor = NULL, neighbors = NULL, ...) {
  p <- ncol(x)

  if (!is.matrix(x)) {
    x <- as.matrix(x)
  }

  if (is.null(num_comp)) {
    num_comp <- p
  } else {
    num_comp <- min(num_comp, p)
  }

  if (is.null(shapefactor)) {
    shapefactor <- seq(1,10)
  }

  if (is.null(neighbors)) {
    shapefactor <- seq(1,5)
  }

  if (is.factor(y)) {
    res <- rnirs::lwplsda(
      Xr = x,
      Yr = y,
      Xu = x,
      Yu = NULL,
      ncompdis = NULL,
      diss = "euclidean",
      h = shapefactor,
      k = neighbors,
      ncomp = num_comp,
      cri = 5,
      stor = TRUE,
      print = FALSE
      )
  } else {
    res <- rnirs::lwplsr(
      Xr = x,
      Yr = y,
      Xu = x,
      Yu = NULL,
      ncompdis = NULL,
      diss = "euclidean",
      h = shapefactor,
      k = neighbors,
      ncomp = num_comp,
      cri = 3,
      stor = TRUE,
      print = FALSE
    )
  }
  res
}
