# Direct R transcription of `lwpls()` from https://github.com/hkaneko1985/lwpls
# (NIPALS with explicit deflation). `x_train`, `y_train` and `x_test` must be
# autoscaled with the training statistics. Returns an
# nrow(x_test) x max_component_number matrix of predictions.
#
# `gamma` (optional) is the p x r projection used to measure distances,
# d_n = ||gamma' (x_n - x_q)||: Gamma = X'y / ||X'y|| gives covariance-based
# LW-PLS (Hazama & Kano 2015, eqs. 28 and 33).
kaneko_lwpls <- function(x_train, y_train, x_test, max_component_number,
                         lambda_in_similarity, gamma = NULL) {
  x_train <- as.matrix(x_train)
  x_test <- as.matrix(x_test)
  y_train <- matrix(y_train, ncol = 1)
  if (is.null(gamma)) {
    gamma <- diag(ncol(x_train))
  }
  est <- matrix(0, nrow(x_test), max_component_number)
  for (i in seq_len(nrow(x_test))) {
    xq <- x_test[i, , drop = FALSE]
    d <- sqrt(colSums((crossprod(gamma, t(x_train) - drop(xq)))^2))
    s <- exp(-d / stats::sd(d) / lambda_in_similarity)
    yw <- sum(s * y_train) / sum(s)
    xw <- colSums(s * x_train) / sum(s)
    cy <- y_train - yw
    cx <- sweep(x_train, 2, xw)
    cq <- xq - xw
    est[i, ] <- yw
    for (a in seq_len(max_component_number)) {
      wa <- crossprod(cx, s * cy)
      wa <- wa / sqrt(sum(wa^2))
      ta <- cx %*% wa
      pa <- crossprod(cx, s * ta) / sum(s * ta^2)
      qa <- sum(s * cy * ta) / sum(s * ta^2)
      tqa <- drop(cq %*% wa)
      est[i, a:max_component_number] <- est[i, a:max_component_number] + tqa * qa
      cx <- cx - ta %*% t(pa)
      cy <- cy - ta * qa
      cq <- cq - tqa * t(pa)
    }
  }
  est
}

# Kaneko's LW-PLS on the original scale (autoscaling as in his demo script).
kaneko_predict <- function(x_train, y_train, x_test, num_comp, localization,
                           scale = TRUE, covariance = FALSE) {
  mu <- colMeans(x_train)
  s <- if (scale) apply(x_train, 2, stats::sd) else rep(1, ncol(x_train))
  y_mu <- mean(y_train)
  y_s <- if (scale) stats::sd(y_train) else 1
  xs <- scale(x_train, mu, s)
  ys <- (y_train - y_mu) / y_s
  gamma <- NULL
  if (covariance) {
    gamma <- crossprod(xs, ys)
    gamma <- gamma / sqrt(sum(gamma^2))
  }
  est <- kaneko_lwpls(
    xs,
    ys,
    scale(x_test, mu, s),
    num_comp,
    localization,
    gamma = gamma
  )
  est * y_s + y_mu
}

# Simulated nonlinear regression data.
sim_reg <- function(n = 120, p = 6, seed = 1) {
  withr::with_seed(seed, {
    x <- matrix(stats::rnorm(n * p), n, p, dimnames = list(NULL, paste0("x", seq_len(p))))
    y <- sin(x[, 1]) + x[, 2]^2 + 0.5 * x[, 3] + stats::rnorm(n, sd = 0.1)
    y2 <- x[, 4] * x[, 5] + stats::rnorm(n, sd = 0.1)
  })
  dat <- as.data.frame(x)
  dat$y <- y
  dat$y2 <- y2
  dat
}
