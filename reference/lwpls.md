# Locally-weighted partial least squares

`lwpls()` defines a locally-weighted partial least squares (LW-PLS)
model for use with the
[parsnip](https://parsnip.tidymodels.org/reference/parsnip-package.html)
package. LW-PLS is a *just-in-time* (lazy) learner: instead of fitting
one global model, a dedicated weighted PLS model is built around every
new sample, where each training sample is weighted by its similarity to
that sample. This lets a linear method capture nonlinear and
time-varying relationships, which makes it popular for soft sensors and
spectroscopic calibration.

The model can be used for regression (one or more numeric outcomes) and
classification (discriminant analysis on class indicators).

There is a single engine, `"lwpls"`, implemented in this package (C++
via RcppArmadillo).

## Usage

``` r
lwpls(
  mode = "unknown",
  num_comp = NULL,
  localization = NULL,
  neighbors = NULL,
  engine = "lwpls"
)
```

## Arguments

- mode:

  A single character string for the prediction outcome mode. Possible
  values are `"unknown"`, `"regression"`, or `"classification"`.

- num_comp:

  The number of PLS components (latent variables) in each local model
  (engine default: 2).

- localization:

  A positive number controlling how local the models are (engine
  default: 1). Small values give large weights to the closest training
  samples only; large values give all samples similar weights, so that
  LW-PLS tends to a global PLS model. See Details.

- neighbors:

  The number of nearest training samples used for each local model. The
  default (`NULL`) uses all training samples, as in the original LW-PLS
  algorithm.

- engine:

  A single character string specifying the computational engine. Only
  `"lwpls"` is available.

## Value

A model specification object with classes `lwpls` and `model_spec`.

## Details

For a query sample \\x_q\\, the similarity weight of the training sample
\\x_i\\ is

\$\$\omega_i = \exp\left(-\frac{d_i}{\sigma_d \\ \varphi}\right),\$\$

where \\d_i = \lVert x_i - x_q \rVert\\ is the Euclidean distance (on
standardized predictors by default), \\\sigma_d\\ is the standard
deviation of the distances and \\\varphi\\ is the `localization`
parameter (\\\lambda\\ in Kaneko's implementation). A weighted PLS model
is then fitted with weighted centering, weighted covariances and the
query is projected onto its local latent space to obtain the prediction.

When `neighbors` is set, only the `neighbors` closest training samples
receive a non-zero weight and \\\sigma_d\\ is computed over their
distances. This is the "KNN-LW" strategy, which Lesnoff et al. (2020)
compare with the original LW-PLS that weights all training samples.

For classification, the outcome is converted to class indicator columns
and modeled with a multi-response LW-PLS (LW-PLS-DA; Bevilacqua and
Marini, 2014). The predicted class is the one with the largest predicted
indicator. Class probabilities are obtained by truncating the predicted
indicators to `[0, 1]` and renormalizing them to sum to one.

Because LW-PLS is a lazy learner, fitting only stores the (standardized)
training data; the computational work happens at prediction time. A
prediction for `num_comp` components also yields the predictions for all
smaller numbers of components, so
[`tune::tune_grid()`](https://tune.tidymodels.org/reference/tune_grid.html)
evaluates every value of `num_comp` from a single model (the "submodel
trick").

## Engine details

The `"lwpls"` engine calls
[`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md).
It accepts the engine argument `scale` (logical, default `TRUE`): should
the predictors (and numeric outcomes) be standardized to unit variance?
Set it to `FALSE` for spectra and other data measured on a common scale.
Predictors with factor columns are converted to dummy variables when the
model is fitted with a formula.

Tuning parameters:

- `num_comp`:
  [`dials::num_comp()`](https://dials.tidymodels.org/reference/num_comp.html)

- `localization`:
  [`localization()`](https://christiangoueguel.com/lwpls/reference/localization.md)

- `neighbors`:
  [`dials::neighbors()`](https://dials.tidymodels.org/reference/neighbors.html)
  (default range 10–200)

## References

Kim, S., Kano, M., Nakagawa, H. and Hasebe, S. (2011). Estimation of
active pharmaceutical ingredients content using locally weighted partial
least squares and statistical wavelength selection. *International
Journal of Pharmaceutics*, 421(2), 269–274.
[doi:10.1016/j.ijpharm.2011.10.007](https://doi.org/10.1016/j.ijpharm.2011.10.007)

Bevilacqua, M. and Marini, F. (2014). Local classification: Locally
weighted-partial least squares-discriminant analysis (LW-PLS-DA).
*Analytica Chimica Acta*, 838, 20–30.
[doi:10.1016/j.aca.2014.05.057](https://doi.org/10.1016/j.aca.2014.05.057)

Lesnoff, M., Metz, M. and Roger, J.-M. (2020). Comparison of locally
weighted PLS strategies for regression and discrimination on agronomic
NIR data. *Journal of Chemometrics*, 34(5), e3209.
[doi:10.1002/cem.3209](https://doi.org/10.1002/cem.3209)

## See also

[`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md)
for the underlying fitting function,
[`multi_predict._lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/multi_predict._lwpls_fit.md),
[`localization()`](https://christiangoueguel.com/lwpls/reference/localization.md).

## Examples

``` r
lwpls(num_comp = 3, localization = 0.5) |>
  parsnip::set_mode("regression") |>
  parsnip::translate()
#> Locally-Weighted PLS Model Specification (regression)
#> 
#> Main Arguments:
#>   num_comp = 3
#>   localization = 0.5
#> 
#> Computational engine: lwpls 
#> 
#> Model fit template:
#> lwpls::lwpls_fit(x = missing_arg(), y = missing_arg(), num_comp = 3, 
#>     localization = 0.5)

lwpls_mod <-
  lwpls(num_comp = 3, localization = 0.5) |>
  parsnip::set_mode("regression") |>
  parsnip::fit(mpg ~ ., data = mtcars[-(1:5), ])

lwpls_mod
#> parsnip model object
#> 
#> Locally-weighted PLS (regression)
#> 
#> Training samples: 27 
#> Predictors:       10 (standardized) 
#> Components:       3 
#> Localization:     0.5 
#> Neighbors:        all (27) 
predict(lwpls_mod, new_data = mtcars[1:5, ])
#> # A tibble: 5 × 1
#>   .pred
#>   <dbl>
#> 1  21.1
#> 2  20.7
#> 3  27.0
#> 4  18.8
#> 5  17.4

# Classification
lwpls(num_comp = 2) |>
  parsnip::set_mode("classification") |>
  parsnip::fit(Species ~ ., data = iris) |>
  predict(new_data = iris[c(1, 51, 101), ], type = "prob")
#> # A tibble: 3 × 3
#>   .pred_setosa .pred_versicolor .pred_virginica
#>          <dbl>            <dbl>           <dbl>
#> 1      0.990            0.00970           0    
#> 2      0.0269           0.502             0.471
#> 3      0.00553          0.0235            0.971
```
