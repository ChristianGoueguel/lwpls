#' Fit a locally-weighted partial least squares model
#'
#' @description
#' `lwpls_fit()` is the computational engine behind [lwpls()]. It can also be
#' used on its own through the matrix, data frame, formula or recipe
#' interfaces.
#'
#' LW-PLS is a lazy learner: fitting validates and standardizes the training
#' data and stores it together with the hyperparameters. The local models are
#' built at prediction time (see [predict.lwpls_fit()]).
#'
#' @param x Depending on the context:
#'   * A __data frame__ or __matrix__ of numeric predictors.
#'   * A __recipe__ specifying a set of preprocessing steps created from
#'     [recipes::recipe()].
#' @param y When `x` is a __data frame__ or __matrix__, `y` is the outcome:
#'   * A __factor__ (or a one-column data frame with a factor) for
#'     classification.
#'   * A __numeric vector__, or a __matrix__/__data frame__ with one or more
#'     numeric columns, for regression.
#' @param data When a __recipe__ or __formula__ is used, `data` is a data
#'   frame containing both the predictors and the outcome(s).
#' @param formula A formula specifying the outcome terms on the left-hand
#'   side and the predictor terms on the right-hand side. Multiple numeric
#'   outcomes can be given as `y1 + y2 ~ .`.
#' @param num_comp The number of PLS components in each local model. It is
#'   capped at the maximum possible value, `min(ncol(x), nrow(x) - 1)`.
#' @param localization A positive number: the localization parameter of the
#'   similarity weights (see [lwpls()]). Smaller values give more local
#'   models.
#' @param neighbors Either `NULL` (default), to use all training samples, or
#'   the number of nearest training samples used to build each local model.
#' @param scale A logical: should the predictors (and numeric outcomes) be
#'   standardized to unit variance? Predictors are always mean-centered,
#'   which does not affect the predictions.
#' @param ... Not currently used, but required for extensibility.
#'
#' @return A `lwpls_fit` object, which stores the standardized training data,
#'   the standardization constants and the hyperparameters.
#'
#' @seealso [predict.lwpls_fit()], [lwpls()]
#' @examples
#' train <- mtcars[-(1:5), ]
#' test <- mtcars[1:5, ]
#'
#' # XY interface
#' fit <- lwpls_fit(train[, -1], train$mpg, num_comp = 3, localization = 0.5)
#' fit
#' predict(fit, test[, -1])
#'
#' # Formula interface, with two outcomes
#' fit2 <- lwpls_fit(mpg + qsec ~ ., data = train, num_comp = 3)
#' predict(fit2, test)
#'
#' # Classification
#' fit3 <- lwpls_fit(Species ~ ., data = iris, num_comp = 2)
#' predict(fit3, iris[c(1, 51, 101), ], type = "prob")
#' @export
lwpls_fit <- function(x, ...) {
  UseMethod("lwpls_fit")
}

#' @export
#' @rdname lwpls_fit
lwpls_fit.default <- function(x, ...) {
  cli::cli_abort("{.fn lwpls_fit} is not defined for {.obj_type_friendly {x}}.")
}

#' @export
#' @rdname lwpls_fit
lwpls_fit.data.frame <- function(x,
                                 y,
                                 num_comp = 2L,
                                 localization = 1,
                                 neighbors = NULL,
                                 scale = TRUE,
                                 ...) {
  rlang::check_dots_empty()
  check_character_outcome(y)
  processed <- hardhat::mold(x, y)
  lwpls_bridge(processed, num_comp, localization, neighbors, scale)
}

#' @export
#' @rdname lwpls_fit
lwpls_fit.matrix <- function(x,
                             y,
                             num_comp = 2L,
                             localization = 1,
                             neighbors = NULL,
                             scale = TRUE,
                             ...) {
  rlang::check_dots_empty()
  check_character_outcome(y)
  processed <- hardhat::mold(x, y)
  lwpls_bridge(processed, num_comp, localization, neighbors, scale)
}

#' @export
#' @rdname lwpls_fit
lwpls_fit.formula <- function(formula,
                              data,
                              num_comp = 2L,
                              localization = 1,
                              neighbors = NULL,
                              scale = TRUE,
                              ...) {
  rlang::check_dots_empty()
  # With an intercept, factors get the same reference-cell coding as with
  # parsnip's formula interface. The intercept column is dropped later.
  processed <- hardhat::mold(
    formula,
    data,
    blueprint = hardhat::default_formula_blueprint(
      intercept = TRUE,
      indicators = "traditional"
    )
  )
  lwpls_bridge(processed, num_comp, localization, neighbors, scale)
}

#' @export
#' @rdname lwpls_fit
lwpls_fit.recipe <- function(x,
                             data,
                             num_comp = 2L,
                             localization = 1,
                             neighbors = NULL,
                             scale = TRUE,
                             ...) {
  rlang::check_dots_empty()
  processed <- hardhat::mold(x, data)
  lwpls_bridge(processed, num_comp, localization, neighbors, scale)
}

# ------------------------------------------------------------------------------
# Bridge: validate the molded data and hyperparameters

lwpls_bridge <- function(processed,
                         num_comp,
                         localization,
                         neighbors,
                         scale,
                         call = rlang::caller_env()) {
  check_whole(num_comp, "num_comp", min = 1, call = call)
  check_positive(localization, "localization", call = call)
  check_whole(neighbors, "neighbors", min = 1, allow_null = TRUE, call = call)
  check_bool(scale, "scale", call = call)

  predictors <- processed$predictors
  predictors <- predictors[names(predictors) != "(Intercept)"]
  outcomes <- processed$outcomes

  nms <- names(predictors)
  if (any(is.na(nms) | nms == "") || anyDuplicated(nms) > 0) {
    cli::cli_abort(
      "The predictors must have unique, non-empty column names.",
      call = call
    )
  }

  is_numeric <- vapply(predictors, is.numeric, logical(1))
  if (!all(is_numeric)) {
    bad <- names(predictors)[!is_numeric]
    cli::cli_abort(
      c(
        "All predictors must be numeric.",
        "x" = "Non-numeric predictor{?s}: {.var {bad}}.",
        "i" = "Use the formula interface or a recipe to create dummy variables."
      ),
      call = call
    )
  }
  x <- as.matrix(predictors)
  storage.mode(x) <- "double"

  if (nrow(x) < 2) {
    cli::cli_abort("At least two training samples are required.", call = call)
  }
  if (ncol(x) < 1) {
    cli::cli_abort("At least one predictor is required.", call = call)
  }
  if (!all(is.finite(x))) {
    cli::cli_abort(
      "The predictors contain missing or infinite values.",
      call = call
    )
  }

  if (ncol(outcomes) == 1 && is.factor(outcomes[[1]])) {
    mode <- "classification"
    y_raw <- outcomes[[1]]
    if (anyNA(y_raw)) {
      cli::cli_abort("The outcome contains missing values.", call = call)
    }
    lvl <- levels(y_raw)
    if (length(lvl) < 2) {
      cli::cli_abort("The outcome factor must have at least two levels.", call = call)
    }
    y <- class_indicators(y_raw)
    outcome_names <- lvl
  } else if (all(vapply(outcomes, is.numeric, logical(1)))) {
    mode <- "regression"
    lvl <- NULL
    y <- as.matrix(outcomes)
    storage.mode(y) <- "double"
    if (!all(is.finite(y))) {
      cli::cli_abort(
        "The outcome contains missing or infinite values.",
        call = call
      )
    }
    outcome_names <- colnames(y)
  } else {
    cli::cli_abort(
      c(
        "Unsupported outcome type.",
        "i" = "Use a single factor (classification) or one or more numeric
               columns (regression)."
      ),
      call = call
    )
  }

  lwpls_fit_impl(
    x = x,
    y = y,
    mode = mode,
    lvl = lvl,
    outcome_names = outcome_names,
    num_comp = num_comp,
    localization = localization,
    neighbors = neighbors,
    scale = scale,
    blueprint = processed$blueprint
  )
}

# ------------------------------------------------------------------------------
# Implementation

lwpls_fit_impl <- function(x,
                           y,
                           mode,
                           lvl,
                           outcome_names,
                           num_comp,
                           localization,
                           neighbors,
                           scale,
                           blueprint) {
  n <- nrow(x)
  p <- ncol(x)

  max_comp <- min(p, n - 1L)
  if (num_comp > max_comp) {
    cli::cli_warn(c(
      "!" = "{.arg num_comp} = {num_comp} is larger than the maximum number of
             components ({max_comp}).",
      "i" = "{max_comp} component{?s} will be used."
    ))
    num_comp <- max_comp
  }

  if (is.null(neighbors)) {
    neighbors <- n
  } else if (neighbors > n) {
    cli::cli_warn(c(
      "!" = "{.arg neighbors} = {neighbors} is larger than the number of
             training samples ({n}).",
      "i" = "All {n} samples will be used."
    ))
    neighbors <- n
  }

  x_center <- colMeans(x)
  x_scale <- if (scale) column_sd(x) else rep(1, p)
  names(x_scale) <- names(x_center)

  # Class indicators are only centered: their predictions then sum to one.
  y_center <- colMeans(y)
  y_scale <- if (scale && mode == "regression") column_sd(y) else rep(1, ncol(y))

  hardhat::new_model(
    x = standardize(x, x_center, x_scale),
    y = standardize(y, y_center, y_scale),
    x_center = x_center,
    x_scale = x_scale,
    y_center = y_center,
    y_scale = y_scale,
    mode = mode,
    lvl = lvl,
    outcome_names = outcome_names,
    num_comp = as.integer(num_comp),
    max_comp = as.integer(max_comp),
    localization = as.numeric(localization),
    neighbors = as.integer(neighbors),
    scale = scale,
    blueprint = blueprint,
    class = "lwpls_fit"
  )
}

#' @export
print.lwpls_fit <- function(x, ...) {
  n <- nrow(x$x)
  cat("Locally-weighted PLS (", x$mode, ")\n\n", sep = "")
  cat("Training samples:", n, "\n")
  cat("Predictors:      ", ncol(x$x), if (x$scale) "(standardized)", "\n")
  if (x$mode == "classification") {
    cat("Classes:         ", paste(x$lvl, collapse = ", "), "\n")
  } else if (!identical(x$outcome_names, ".outcome")) {
    cat("Outcomes:        ", paste(x$outcome_names, collapse = ", "), "\n")
  }
  cat("Components:      ", x$num_comp, "\n")
  cat("Localization:    ", format(x$localization, digits = 4), "\n")
  cat(
    "Neighbors:       ",
    if (x$neighbors >= n) paste0("all (", n, ")") else x$neighbors,
    "\n"
  )
  invisible(x)
}

# ------------------------------------------------------------------------------
# Helpers

check_character_outcome <- function(y, call = rlang::caller_env()) {
  is_chr <- if (is.data.frame(y)) any(vapply(y, is.character, logical(1))) else is.character(y)
  if (is_chr) {
    cli::cli_abort(
      c(
        "Character outcomes are not supported.",
        "i" = "Convert the outcome to a factor for classification."
      ),
      call = call
    )
  }
  invisible(y)
}

class_indicators <- function(y) {
  lvl <- levels(y)
  res <- matrix(0, nrow = length(y), ncol = length(lvl), dimnames = list(NULL, lvl))
  res[cbind(seq_along(y), as.integer(y))] <- 1
  res
}

column_sd <- function(x) {
  res <- apply(x, 2, stats::sd)
  res[!is.finite(res) | res <= .Machine$double.eps * pmax(abs(colMeans(x)), 1)] <- 1
  res
}

standardize <- function(x, center, scale) {
  x <- sweep(x, 2, center, check.margin = FALSE)
  x <- sweep(x, 2, scale, "/", check.margin = FALSE)
  dimnames(x) <- NULL
  x
}
