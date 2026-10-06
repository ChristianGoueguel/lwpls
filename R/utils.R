# Argument checkers ------------------------------------------------------------

check_whole <- function(x,
                        arg,
                        min = -Inf,
                        allow_null = FALSE,
                        call = rlang::caller_env()) {
  if (is.null(x) && allow_null) {
    return(invisible(NULL))
  }
  ok <- is.numeric(x) && length(x) == 1 && !is.na(x) && is.finite(x) &&
    x == round(x) && x >= min
  if (!ok) {
    cli::cli_abort(
      "{.arg {arg}} must be a single whole number >= {min}, not {describe(x)}.",
      call = call
    )
  }
  invisible(x)
}

check_positive <- function(x, arg, allow_null = FALSE, call = rlang::caller_env()) {
  if (is.null(x) && allow_null) {
    return(invisible(NULL))
  }
  ok <- is.numeric(x) && length(x) == 1 && !is.na(x) && is.finite(x) && x > 0
  if (!ok) {
    cli::cli_abort(
      "{.arg {arg}} must be a single positive number, not {describe(x)}.",
      call = call
    )
  }
  invisible(x)
}

check_similarity <- function(x, allow_null = FALSE, call = rlang::caller_env()) {
  if (is.null(x) && allow_null) {
    return(invisible(NULL))
  }
  if (!rlang::is_string(x) || !x %in% values_similarity) {
    cli::cli_abort(
      "{.arg similarity} must be one of {.or {.val {values_similarity}}}, not {describe(x)}.",
      call = call
    )
  }
  invisible(x)
}

check_bool <- function(x, arg, call = rlang::caller_env()) {
  if (!rlang::is_bool(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be {.code TRUE} or {.code FALSE}, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

# Short description of an invalid argument value for error messages.
describe <- function(x) {
  if (is.numeric(x) && length(x) == 1) {
    format(x)
  } else if (rlang::is_string(x)) {
    encodeString(x, quote = '"')
  } else {
    cli::format_inline("{.obj_type_friendly {x}}")
  }
}
