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
- [`sparsity()`](https://christiangoueguel.com/lwpls/reference/sparsity.md)
  : Sparsity of the LW-PLS local models

## Diagnostics and plots

The local models of the predictions and their plots.

- [`lwpls_local()`](https://christiangoueguel.com/lwpls/reference/lwpls_local.md)
  : Local models of LW-PLS predictions
- [`plot_reliability()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  [`plot_coefficients()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  [`plot_robust_weights()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  [`plot_selection()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  [`autoplot(`*`<lwpls_local>`*`)`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)
  : Plots of LW-PLS local models

## Metrics

Performance metrics for tuning robust models.

- [`trimmed_rmse()`](https://christiangoueguel.com/lwpls/reference/trimmed_rmse.md)
  [`trimmed_rmse_vec()`](https://christiangoueguel.com/lwpls/reference/trimmed_rmse.md)
  : Trimmed root mean squared error
