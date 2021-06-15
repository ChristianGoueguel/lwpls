#' @title General Interface for Locally-Weighted Partial Least Squares (LWPLS)
#'
#' @param mode A single character string for the type of model.
#' Possible values for this model are "unknown", "regression", or "classification".
#' @param num_comp The number of components to retain in the local PLS models.
#' @param neighbors The number of neighbors considered at each prediction.
#'
#' @examples
#' lwpls() %>%
#'   parsnip::set_args(num_comp = 2, neighbors = 2) %>%
#'   parsnip::set_engine("rnirs") %>%
#'   parsnip::set_mode("regression") %>%
#'   parsnip::translate()
#'
#' lwpls() %>%
#'   parsnip::set_args(num_comp = 5, neighbors = 3) %>%
#'   parsnip::set_engine("rnirs") %>%
#'   parsnip::set_mode("classification") %>%
#'   parsnip::translate()
#'
#' @export
lwpls <- function(mode = "unknown",  num_comp = NULL, neighbors = NULL) {
    args <- list(num_comp = rlang::enquo(num_comp), neighbors = rlang::enquo(neighbors))
    parsnip::new_model_spec(
      "lwpls",
      args = args,
      eng_args = NULL,
      mode = mode,
      method = NULL,
      engine = NULL
    )
}
#' @export
print.lwpls <- function(x, ...) {
  cat("LWPLS Model Specification (", x$mode, ")\n\n", sep = "")
  parsnip::model_printer(x, ...)
  if (!is.null(x$method$fit$args)) {
    cat("Model fit template:\n")
    print(parsnip::show_call(x))
  }
  invisible(x)
}

# ------------------------------------------------------------------------------
#' @title General Interface for Updating Models Parameters
#'
#' @param object lwpls model specification.
#' @param parameters A 1-row tibble or named list with _main_
#'  parameters to update. If the individual arguments are used,
#'  these will supersede the values in `parameters`. Also, using
#'  engine arguments in this object will result in an error.
#' @param num_comp The number of components to retain in the local PLS models.
#' @param neighbors The number of neighbors considered at each prediction.
#' @param fresh A logical for whether the arguments should be
#'  modified in-place of or replaced wholesale.
#' @param ... Not used for `update()`.
#'
#' @examples
#' model <- lwpls(neighbors =  3)
#' model
#' update(model, neighbors = 1)
#' update(model, neighbors = 1, fresh = TRUE)
#'
#' @export
update.lwpls <- function(object, parameters = NULL, num_comp = NULL, neighbors = NULL, fresh = FALSE, ...) {
    parsnip::update_dot_check(...)
    if (!is.null(parameters)) {
      parameters <- parsnip::check_final_param(parameters)
    }
    args <- list(neighbors = rlang::enquo(neighbors), num_comp  = rlang::enquo(num_comp))
    args <- parsnip::update_main_parameters(args, parameters)
    if (fresh) {
      object$args <- args
    } else {
      null_args <- purrr::map_lgl(args, parsnip::null_value)
      if (any(null_args))
        args <- args[!null_args]
      if (length(args) > 0)
        object$args[names(args)] <- args
    }
    parsnip::new_model_spec(
      "lwpls",
      args = object$args,
      eng_args = object$eng_args,
      mode = object$mode,
      method = NULL,
      engine = object$engine
    )
  }

# ------------------------------------------------------------------------------
check_args.lwpls <- function(object) {
  args <- lapply(object$args, rlang::eval_tidy)
  if (is.numeric(args$num_comp) && args$num_comp < 0)
    rlang::abort("`num_comp` should be >= 1.")
  invisible(object)
}
