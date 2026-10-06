#' Locally-weighted partial least squares
#'
#' @description
#' `lwpls()` defines a locally-weighted partial least squares (LW-PLS) model
#' for use with the [parsnip][parsnip::parsnip] package. LW-PLS is a
#' *just-in-time* (lazy) learner: instead of fitting one global model, a
#' dedicated weighted PLS model is built around every new sample, where each
#' training sample is weighted by its similarity to that sample. This lets a
#' linear method capture nonlinear and time-varying relationships, which makes
#' it popular for soft sensors and spectroscopic calibration.
#'
#' The model can be used for regression (one or more numeric outcomes) and
#' classification (discriminant analysis on class indicators).
#'
#' There is a single engine, `"lwpls"`, implemented in this package (C++ via
#' RcppArmadillo).
#'
#' @param mode A single character string for the prediction outcome mode.
#'   Possible values are `"unknown"`, `"regression"`, or `"classification"`.
#' @param num_comp The number of PLS components (latent variables) in each
#'   local model (engine default: 2).
#' @param localization A positive number controlling how local the models
#'   are (engine default: 1). Small values give large weights to the closest
#'   training samples only; large values give all samples similar weights, so
#'   that LW-PLS tends to a global PLS model. See Details.
#' @param neighbors The number of nearest training samples used for each
#'   local model. The default (`NULL`) uses all training samples, as in the
#'   original LW-PLS algorithm.
#' @param engine A single character string specifying the computational
#'   engine. Only `"lwpls"` is available.
#'
#' @details
#' For a query sample \eqn{x_q}, the similarity weight of the training sample
#' \eqn{x_i} is
#'
#' \deqn{\omega_i = \exp\left(-\frac{d_i}{\sigma_d \, \varphi}\right),}
#'
#' where \eqn{d_i = \lVert x_i - x_q \rVert} is the Euclidean distance (on
#' standardized predictors by default), \eqn{\sigma_d} is the standard
#' deviation of the distances and \eqn{\varphi} is the `localization`
#' parameter (\eqn{\lambda} in Kaneko's implementation). A weighted PLS model
#' is then fitted with weighted centering, weighted covariances and the
#' query is projected onto its local latent space to obtain the prediction.
#'
#' When `neighbors` is set, only the `neighbors` closest training samples
#' receive a non-zero weight and \eqn{\sigma_d} is computed over their
#' distances.
#'
#' For classification, the outcome is converted to class indicator columns
#' and modeled with a multi-response LW-PLS (LW-PLS-DA). The predicted class
#' is the one with the largest predicted indicator. Class probabilities are
#' obtained by truncating the predicted indicators to `[0, 1]` and
#' renormalizing them to sum to one.
#'
#' Because LW-PLS is a lazy learner, fitting only stores the (standardized)
#' training data; the computational work happens at prediction time. A
#' prediction for `num_comp` components also yields the predictions for all
#' smaller numbers of components, so [tune::tune_grid()] evaluates every value
#' of `num_comp` from a single model (the "submodel trick").
#'
#' # Engine details
#'
#' The `"lwpls"` engine calls [lwpls_fit()]. It accepts the engine argument
#' `scale` (logical, default `TRUE`): should the predictors (and numeric
#' outcomes) be standardized to unit variance? Set it to `FALSE` for spectra
#' and other data measured on a common scale. Predictors with factor columns
#' are converted to dummy variables when the model is fitted with a formula.
#'
#' Tuning parameters:
#'
#' * `num_comp`: [dials::num_comp()]
#' * `localization`: [localization()]
#' * `neighbors`: [dials::neighbors()] (default range 10--200)
#'
#' @references
#' Kim, S., Kano, M., Nakagawa, H. and Hasebe, S. (2011). Estimation of active
#' pharmaceutical ingredients content using locally weighted partial least
#' squares and statistical wavelength selection. *International Journal of
#' Pharmaceutics*, 421(2), 269--274. \doi{10.1016/j.ijpharm.2011.10.007}
#'
#' @return A model specification object with classes `lwpls` and
#'   `model_spec`.
#' @seealso [lwpls_fit()] for the underlying fitting function,
#'   [multi_predict._lwpls_fit()], [localization()].
#' @examples
#' lwpls(num_comp = 3, localization = 0.5) |>
#'   parsnip::set_mode("regression") |>
#'   parsnip::translate()
#'
#' lwpls_mod <-
#'   lwpls(num_comp = 3, localization = 0.5) |>
#'   parsnip::set_mode("regression") |>
#'   parsnip::fit(mpg ~ ., data = mtcars[-(1:5), ])
#'
#' lwpls_mod
#' predict(lwpls_mod, new_data = mtcars[1:5, ])
#'
#' # Classification
#' lwpls(num_comp = 2) |>
#'   parsnip::set_mode("classification") |>
#'   parsnip::fit(Species ~ ., data = iris) |>
#'   predict(new_data = iris[c(1, 51, 101), ], type = "prob")
#' @export
lwpls <- function(mode = "unknown",
                  num_comp = NULL,
                  localization = NULL,
                  neighbors = NULL,
                  engine = "lwpls") {
  args <- list(
    num_comp = rlang::enquo(num_comp),
    localization = rlang::enquo(localization),
    neighbors = rlang::enquo(neighbors)
  )

  parsnip::new_model_spec(
    "lwpls",
    args = args,
    eng_args = NULL,
    mode = mode,
    user_specified_mode = !missing(mode),
    method = NULL,
    engine = engine,
    user_specified_engine = !missing(engine)
  )
}

#' @export
print.lwpls <- function(x, ...) {
  parsnip::print_model_spec(x, desc = "Locally-Weighted PLS", ...)
}

#' Update a locally-weighted PLS specification
#'
#' @param object A [lwpls()] model specification.
#' @param parameters A 1-row tibble or named list with *main* parameters to
#'   update. Use **either** `parameters` **or** the main arguments directly
#'   when updating. If the main arguments are used, these will supersede the
#'   values in `parameters`. Also, using engine arguments in this object will
#'   result in an error.
#' @inheritParams lwpls
#' @param fresh A logical for whether the arguments should be modified
#'   in-place or replaced wholesale.
#' @param ... Not used for `update()`.
#' @return An updated model specification.
#' @examples
#' spec <- lwpls(num_comp = 3)
#' spec
#' update(spec, localization = 0.25)
#' update(spec, localization = 0.25, fresh = TRUE)
#' @export
update.lwpls <- function(object,
                         parameters = NULL,
                         num_comp = NULL,
                         localization = NULL,
                         neighbors = NULL,
                         fresh = FALSE,
                         ...) {
  args <- list(
    num_comp = rlang::enquo(num_comp),
    localization = rlang::enquo(localization),
    neighbors = rlang::enquo(neighbors)
  )

  parsnip::update_spec(
    object = object,
    parameters = parameters,
    args_enquo_list = args,
    fresh = fresh,
    cls = "lwpls",
    ...
  )
}

#' @exportS3Method parsnip::check_args
check_args.lwpls <- function(object, call = rlang::caller_env()) {
  args <- lapply(object$args, rlang::eval_tidy)
  check_whole(args$num_comp, "num_comp", min = 1, allow_null = TRUE, call = call)
  check_positive(args$localization, "localization", allow_null = TRUE, call = call)
  check_whole(args$neighbors, "neighbors", min = 1, allow_null = TRUE, call = call)
  invisible(object)
}

#' Determine the minimal set of model fits for tuning
#'
#' `min_grid()` is used by the tune package to fit as few models as possible.
#' LW-PLS predictions for `num_comp` components include those for all
#' smaller numbers of components, so only the largest `num_comp` value of
#' each combination of the other parameters is fitted.
#'
#' @param x A [lwpls()] model specification.
#' @param grid A tibble with tuning parameter combinations.
#' @param ... Not currently used.
#' @return A tibble with the minimal tuning grid and a list column with the
#'   submodel values to predict.
#' @keywords internal
#' @export
min_grid.lwpls <- function(x, grid, ...) {
  rlang::check_installed("tune")
  tune::fit_max_value(x, grid, ...)
}
