# Package index

## Model specification

Locally-weighted PLS models for parsnip and tidymodels.

- [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md) :
  Locally-weighted partial least squares
- [`update(`*`<lwpls>`*`)`](https://christiangoueguel.com/lwpls/reference/update.lwpls.md)
  : Update a locally-weighted PLS specification

## Fitting and prediction

The computational engine, usable on its own.

- [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md)
  : Fit a locally-weighted partial least squares model
- [`predict(`*`<lwpls_fit>`*`)`](https://christiangoueguel.com/lwpls/reference/predict.lwpls_fit.md)
  : Predict from a locally-weighted PLS model
- [`multi_predict(`*`<_lwpls_fit>`*`)`](https://christiangoueguel.com/lwpls/reference/multi_predict._lwpls_fit.md)
  : Predictions for several numbers of components

## Tuning parameters

- [`localization()`](https://christiangoueguel.com/lwpls/reference/localization.md)
  : Localization parameter for LW-PLS
- [`similarity()`](https://christiangoueguel.com/lwpls/reference/similarity.md)
  [`values_similarity`](https://christiangoueguel.com/lwpls/reference/similarity.md)
  : Similarity index for LW-PLS
