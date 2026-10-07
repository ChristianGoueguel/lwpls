# Changelog

## lwpls 0.3.0

- First CRAN release.

### New features

- New
  [`lwpls_local()`](https://christiangoueguel.com/lwpls/reference/lwpls_local.md)
  returns the local models that LW-PLS builds for new samples, with
  their diagnostics: the reliability of each prediction (effective
  number of neighbors, distance to the nearest training sample, and the
  Hotelling T² and Q statistics of the query in its local model,
  compared with empirical limits, theoretical limits and as percentile
  ranks among the training samples of the local model), the regression
  coefficients and VIP of each local model, the predictors selected by
  sparse models, and the robust weights of the training samples. It
  accepts
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md)
  objects, parsnip fits and workflows.

- New ggplot2 plots of the local models, also available with
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html):
  [`plot_reliability()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  (applicability domain of the predictions),
  [`plot_coefficients()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  (local regression vectors or VIP along the spectrum, as lines or a
  heatmap),
  [`plot_robust_weights()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  (training samples down-weighted by robust models, such as wrong
  reference values) and
  [`plot_selection()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  (wavelengths selected by sparse models, per component or overall). The
  spectral axis is read from the predictor names or given as
  `wavelength`.

- New vignette,
  [`vignette("diagnostics")`](https://christiangoueguel.com/lwpls/articles/diagnostics.md).

### Documentation

- The README and
  [`vignette("lwpls")`](https://christiangoueguel.com/lwpls/articles/lwpls.md)
  show the cross-validated RMSE as a 3D surface over `num_comp` and
  `localization` (interactive on the package website, with plotly as a
  new suggested package).

- New vignette,
  [`vignette("similarity")`](https://christiangoueguel.com/lwpls/articles/similarity.md),
  on choosing a similarity index: the geometry of the Euclidean and
  covariance-based distances, and simulations showing when each one
  works best.

## lwpls 0.2.1

### New features

- Robust LW-PLS: with `robust = TRUE` (an engine argument of
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  and an argument of
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md)),
  each local model is fitted by partial robust M-regression (PRM;
  Serneels et al., 2005), with the Fair (default) or Hampel weight
  function. The medians and the L1-median that PRM uses are weighted by
  the similarity weights, so the robust models stay local. Robust models
  are available for regression with one or more outcomes and for
  classification, and they standardize the data and scale the distances
  with the median and the MAD.

- Sparse LW-PLS: the new `sparsity` argument (a tunable main argument of
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md),
  with the dials parameter
  [`sparsity()`](https://christiangoueguel.com/lwpls/reference/sparsity.md))
  fits the local models by sparse NIPALS (SNIPLS; Hoffmann et al.,
  2015), so that each local model selects its own predictors. Combined
  with `robust = TRUE`, it gives local sparse PRM (SPRM).

- New yardstick metric
  [`trimmed_rmse()`](https://christiangoueguel.com/lwpls/reference/trimmed_rmse.md)
  to tune robust models on data with outliers.

- New vignette,
  [`vignette("robust-sparse")`](https://christiangoueguel.com/lwpls/articles/robust-sparse.md).

## lwpls 0.2.0

This is a rewrite of the package. LW-PLS is now implemented natively and
no longer depends on the archived rnirs package.

### Breaking changes

- [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  now has the arguments `mode`, `num_comp`, `localization`, `neighbors`,
  `similarity` and `engine`. The `shapefactor` argument is replaced by
  `localization`, the parameter of the similarity function of Kim et
  al. (2011) (`lambda` in Kaneko’s implementation). The engine is now
  `"lwpls"` (was `"rnirs"`).

- The magrittr pipe `%>%` and
  [`generics::tidy()`](https://generics.r-lib.org/reference/tidy.html)
  are no longer re-exported. Use the native pipe `|>` (R \>= 4.1.0).

### New features

- Native implementation of LW-PLS, validated against Kaneko’s reference
  implementation. The prediction kernel is written in C++
  (RcppArmadillo): it uses the kernel PLS algorithm of Dayal &
  MacGregor (1997) and processes queries in blocks so that most of the
  work runs as BLAS matrix-matrix products.

- Regression with one or more numeric outcomes, and classification
  (LW-PLS-DA) with class and probability predictions.

- New
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md),
  a hardhat-based fitting function with matrix, data frame, formula and
  recipe interfaces. Its
  [`predict()`](https://rdrr.io/r/stats/predict.html) method returns
  tibbles that follow the tidymodels conventions and can use any number
  of components.

- [`multi_predict()`](https://parsnip.tidymodels.org/reference/multi_predict.html)
  and [`min_grid()`](https://generics.r-lib.org/reference/min_grid.html)
  methods: tune evaluates all values of `num_comp` from a single model
  fit.

- New dials tuning parameter
  [`localization()`](https://christiangoueguel.com/lwpls/reference/localization.md).

- Covariance-based LW-PLS (CbLW-PLS, Hazama and Kano, 2015): the new
  `similarity` argument measures the similarity between samples with the
  Euclidean distance (`"euclidean"`, the default) or along the
  covariance direction of the training data (`"covariance"`). It can be
  tuned with the new dials parameter
  [`similarity()`](https://christiangoueguel.com/lwpls/reference/similarity.md).

- The optional `neighbors` argument restricts each local model to the
  nearest training samples.

- The `"lwpls"` engine has a `scale` argument to switch off the
  standardization of the data.

- Added unit tests (with test coverage tracked on Codecov) and an
  introductory vignette
  ([`vignette("lwpls")`](https://christiangoueguel.com/lwpls/articles/lwpls.md)),
  including regression and classification examples.

## lwpls 0.1.0

- Added a `NEWS.md` file to track changes to the package.
