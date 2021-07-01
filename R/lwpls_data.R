make_lwpls_engine <- function() {

  parsnip::set_new_model(model = "lwpls")
  parsnip::set_model_mode(model = "lwpls", mode = "regression")
  parsnip::set_model_mode(model = "lwpls", mode = "classification")
  parsnip::set_model_engine(model = "lwpls", mode = "regression", eng = "rnirs")
  parsnip::set_model_engine(model = "lwpls", mode = "classification", eng = "rnirs")
  parsnip::set_dependency(model = "lwpls", eng = "rnirs", pkg = "rnirs")

  parsnip::set_model_arg(
    model = "lwpls",
    eng = "rnirs",
    parsnip = "num_comp",
    original = "ncomp",
    func = list(pkg = "dials", fun = "num_comp", range = c(1, 20)),
    has_submodel = TRUE
  )
  parsnip::set_model_arg(
    model = "lwpls",
    eng = "rnirs",
    parsnip = "neighbors",
    original = "k",
    func = list(pkg = "dials", fun = "neighbors", range = c(1, 5)),
    has_submodel = FALSE
  )
  parsnip::set_model_arg(
    model = "lwpls",
    eng = "rnirs",
    parsnip = "shapefactor",
    original = "h",
    func = list(pkg = "rnirs", fun = "lwplsr", range = c(1, 10)),
    has_submodel = FALSE
  )
  parsnip::set_fit(
    model = "lwpls",
    eng = "rnirs",
    mode = "regression",
    value = list(
      interface = "formula",
      protect = c("formula", "data"),
      func = c(pkg = "rnirs", fun = "lwplsr"),
      defaults = list()
    )
  )
  parsnip::set_fit(
    model = "lwpls",
    eng = "rnirs",
    mode = "classification",
    value = list(
      interface = "formula",
      protect = c("formula", "data"),
      func = c(pkg = "rnirs", fun = "lwplsda"),
      defaults = list()
    )
  )

  parsnip::set_encoding(
    model = "lwpls",
    eng = "rnirs",
    mode = "regression",
    options = list(
      predictor_indicators = "traditional",
      compute_intercept = TRUE,
      remove_intercept = TRUE,
      allow_sparse_x = FALSE
    )
  )
  parsnip::set_encoding(
    model = "lwpls",
    eng = "rnirs",
    mode = "classification",
    options = list(
      predictor_indicators = "traditional",
      compute_intercept = TRUE,
      remove_intercept = TRUE,
      allow_sparse_x = FALSE
    )
  )

  parsnip::set_pred(
    model = "lwpls",
    eng = "rnirs",
    mode = "regression",
    type = "numeric",
    value = list(
      pre = NULL,
      post = single_numeric_preds,
      func = c(fun = "predict"),
      args =list(
        object = quote(object$fit),
        newdata = quote(new_data),
        diss = "mahalanobis"
        )
      )
    )
  parsnip::set_pred(
    model = "lwpls",
    eng = "rnirs",
    mode = "regression",
    type = "raw",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data),
        dist = "mahalanobis"
        )
      )
    )

  parsnip::set_pred(
    model = "lwpls",
    eng = "rnirs",
    mode = "classification",
    type = "class",
    value = list(
      pre = NULL,
      post = single_class_preds,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data),
        dist = "mahalanobis"
        )
      )
    )

  parsnip::set_pred(
    model = "lwpls",
    eng = "rnirs",
    mode = "classification",
    type = "prob",
    value = list(
      pre = NULL,
      post = single_prob_preds,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data),
        dist = "mahalanobis"
        )
      )
    )

  parsnip::set_pred(
    model = "lwpls",
    eng = "rnirs",
    mode = "classification",
    type = "raw",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data),
        dist = "mahalanobis"
        )
      )
    )

}
