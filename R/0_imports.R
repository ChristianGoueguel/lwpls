#' @importFrom parsnip set_new_model
#' @importFrom stats predict

# ------------------------------------------------------------------------------

# The functions below define the model information. These access the model
# environment inside of parsnip so they have to be executed once parsnip has
# been loaded.

.onLoad <- function(libname, pkgname) {
  # This defines lwpls in the model database
  make_lwpls_engine()
}
