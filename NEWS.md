# lwpls 0.2.1

## New features

* Robust LW-PLS: with `robust = TRUE` (an engine argument of `lwpls()` and an
  argument of `lwpls_fit()`), each local model is fitted by partial robust
  M-regression (PRM; Serneels et al., 2005), with the Fair (default) or
  Hampel weight function. The medians and the L1-median that PRM uses are
  weighted by the similarity weights, so the robust models stay local. Robust
  models are available for regression with one or more outcomes and for
  classification, and they standardize the data and scale the distances with
  the median and the MAD.

* Sparse LW-PLS: the new `sparsity` argument (a tunable main argument of
  `lwpls()`, with the dials parameter `sparsity()`) fits the local models by
  sparse NIPALS (SNIPLS; Hoffmann et al., 2015), so that each local model
  selects its own predictors. Combined with `robust = TRUE`, it gives local
  sparse PRM (SPRM).

* New yardstick metric `trimmed_rmse()` to tune robust models on data with
  outliers.

* New vignette, `vignette("robust-sparse")`.

# lwpls 0.2.0

This is a rewrite of the package. LW-PLS is now implemented natively and no
longer depends on the archived rnirs package.

## Breaking changes

* `lwpls()` now has the arguments `mode`, `num_comp`, `localization`,
  `neighbors`, `similarity` and `engine`. The `shapefactor` argument is replaced by
  `localization`, the parameter of the similarity function of Kim et al. (2011)
  (`lambda` in Kaneko's implementation). The engine is now `"lwpls"` (was
  `"rnirs"`).

* The magrittr pipe `%>%` and `generics::tidy()` are no longer re-exported. Use
  the native pipe `|>` (R >= 4.1.0).

## New features

* Native implementation of LW-PLS, validated against Kaneko's reference
  implementation. The prediction kernel is written in C++ (RcppArmadillo): it
  uses the kernel PLS algorithm of Dayal & MacGregor (1997) and processes
  queries in blocks so that most of the work runs as BLAS matrix-matrix
  products.

* Regression with one or more numeric outcomes, and classification
  (LW-PLS-DA) with class and probability predictions.

* New `lwpls_fit()`, a hardhat-based fitting function with matrix, data frame,
  formula and recipe interfaces. Its `predict()` method returns tibbles that
  follow the tidymodels conventions and can use any number of components.

* `multi_predict()` and `min_grid()` methods: tune evaluates all values of
  `num_comp` from a single model fit.

* New dials tuning parameter `localization()`.

* Covariance-based LW-PLS (CbLW-PLS, Hazama and Kano, 2015): the new
  `similarity` argument measures the similarity between samples with the
  Euclidean distance (`"euclidean"`, the default) or along the covariance
  direction of the training data (`"covariance"`). It can be tuned with the
  new dials parameter `similarity()`.

* The optional `neighbors` argument restricts each local model to the nearest
  training samples.

* The `"lwpls"` engine has a `scale` argument to switch off the
  standardization of the data.

* Added unit tests (with test coverage tracked on Codecov) and an introductory
  vignette (`vignette("lwpls")`), including regression and classification
  examples.

# lwpls 0.1.0

* Added a `NEWS.md` file to track changes to the package.
