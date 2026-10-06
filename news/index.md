# Changelog

## lwpls 0.2.0

This is a rewrite of the package. LW-PLS is now implemented natively and
no longer depends on the archived rnirs package.

### Breaking changes

- [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  now has the arguments `mode`, `num_comp`, `localization`, `neighbors`
  and `engine`. The `shapefactor` argument is replaced by
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
