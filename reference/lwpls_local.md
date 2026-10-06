# Local models of LW-PLS predictions

`lwpls_local()` returns the local models that
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
builds to predict new samples, with the diagnostics that matter in
practice, such as for spectroscopic calibration:

- **Reliability** of each prediction: the effective number of neighbors,
  the distance to the nearest training sample, and the Hotelling \\T^2\\
  and \\Q\\ statistics of the query in its local model, compared with
  theoretical and empirical limits and ranked among the training samples
  of the local model. Queries beyond the limits are extrapolations of
  their local model. See
  [`plot_reliability()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md).

- **Regression coefficients** and variable importance in projection
  (VIP) of each local model, on the original scale of the predictors and
  outcomes. See
  [`plot_coefficients()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md).

- **Selected predictors** of sparse local models. See
  [`plot_selection()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md).

- **Robust weights** of the training samples, averaged over the local
  models in which they take part. See
  [`plot_robust_weights()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md).

## Usage

``` r
lwpls_local(object, ...)

# Default S3 method
lwpls_local(object, ...)

# S3 method for class 'lwpls_fit'
lwpls_local(
  object,
  new_data,
  num_comp = NULL,
  wavelength = NULL,
  limits = c("empirical", "theoretical"),
  level = 0.95,
  ...
)

# S3 method for class 'model_fit'
lwpls_local(object, new_data, ...)

# S3 method for class 'workflow'
lwpls_local(object, new_data, ...)
```

## Arguments

- object:

  A fitted
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  model: a `lwpls_fit` object from
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md),
  a parsnip model fit, or a fitted workflow.

- ...:

  Not currently used.

- new_data:

  A data frame or matrix of new samples (the queries).

- num_comp:

  The number of components of the local models. Defaults to the value
  used to fit the model.

- wavelength:

  An optional numeric vector with the position of each predictor on the
  spectral axis (wavelengths, wavenumbers, ...). By default, the
  positions are the numbers at the end of the predictor names (for
  example `nm_1650` or `x_001`) when they are all present and unique,
  and the column numbers otherwise.

- limits:

  The limits that define the `status` and the ratios of the reliability
  table: `"empirical"` (default) or `"theoretical"`. Both are always
  computed; see Details.

- level:

  The coverage of the limits, and the percentile rank beyond which a
  query is flagged. Defaults to 0.95.

## Value

An object of class `lwpls_local`, a list with:

- `reliability`: a tibble with one row per query: `.row`, the
  prediction(s), `n_eff`, `nearest_distance`, `num_comp`, `t2`,
  `t2_limit_theoretical`, `t2_limit_empirical`, `t2_percentile`, `q`,
  `q_limit_theoretical`, `q_limit_empirical`, `q_percentile`, `t2_ratio`
  and `q_ratio` (the statistics divided by the limits chosen by
  `limits`), and `status`.

- `coefficients`: a tibble with one row per query, outcome and
  predictor: `.row`, `outcome`, `predictor`, `position`, `coefficient`,
  `vip` and `selected`.

- `selection`: a tibble with one row per component and predictor:
  `component`, `predictor`, `position`, `frequency` (the fraction of the
  local models with this component whose weight vector selects the
  predictor) and `queries` (the number of those local models). Sparse
  models select predictors per component; a predictor is used by a local
  model (`selected` in `coefficients`) if any component selects it.

- `training`: a tibble with one row per training sample: `.row`, the
  outcome(s), `influence` (the sum of its similarity weights over the
  queries) and `robust_weight` (the average of its robust weights,
  weighted by the similarity weights).

- `info`: the settings of the model and of the spectral axis.

## Details

For a query with local model weights \\w_i\\ (the similarity weights,
multiplied by the robust weights for robust models), the effective
number of neighbors is \\(\sum w_i)^2 / \sum w_i^2\\.

The \\T^2\\ statistic of a sample is its squared distance to the
weighted mean of the local scores, scaled by their weighted variances,
and its \\Q\\ statistic is the squared norm of its residual (on the
standardized scale). They are computed for the query and for the
training samples of its local model, and the query is compared with them
in three ways:

- **Theoretical limits** (`t2_limit_theoretical`,
  `q_limit_theoretical`): the \\T^2\\ limit of a new observation for a
  model with \\a\\ components fitted on \\n\\ samples, \\a (n^2 - 1) /
  (n (n - a)) F\_{level}(a, n - a)\\, where \\n\\ is the effective
  number of samples of the local model, and the Box approximation of the
  weighted distribution of the \\Q\\ of the training samples (Nomikos
  and MacGregor, 1995). They assume normally distributed scores and
  residuals, and they are derived for ordinary, unweighted models.

- **Empirical limits** (`t2_limit_empirical`, `q_limit_empirical`): the
  `level` quantiles of the \\T^2\\ and \\Q\\ of the training samples of
  the local model, weighted by their weights in the model. They make no
  distributional assumption. The training samples were used to fit the
  model, so their statistics are slightly smaller than those of new
  samples, which makes these limits slightly conservative (more queries
  are flagged).

- **Percentile ranks** (`t2_percentile`, `q_percentile`): the weighted
  fraction of the training samples of the local model whose statistic is
  not larger than that of the query. A rank above `level` is equivalent
  to exceeding the empirical limit, on a continuous scale.

A query is flagged as `"few neighbors"` when its local model has too few
effective samples to assess it (no more than \\a + 1\\), whatever the
limits.

## References

Nomikos, P. and MacGregor, J. F. (1995). Multivariate SPC charts for
monitoring batch processes. *Technometrics*, 37(1), 41–59.
[doi:10.1080/00401706.1995.10485888](https://doi.org/10.1080/00401706.1995.10485888)

## See also

[`plot_reliability()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md),
[`plot_coefficients()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md),
[`plot_robust_weights()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md),
[`plot_selection()`](https://christiangoueguel.com/lwpls/reference/lwpls_plots.md)

## Examples

``` r
fit <- lwpls_fit(mpg ~ ., data = mtcars[-(1:5), ], num_comp = 3)
local <- lwpls_local(fit, mtcars[1:5, ])
local
#> LW-PLS local models
#> 
#> Queries:           5 
#> Components:        3 
#> Reliability:       5 inside (empirical limits, 95%) 
local$reliability
#> # A tibble: 5 × 16
#>    .row .pred n_eff nearest_distance num_comp    t2 t2_limit_theoretical
#>   <int> <dbl> <dbl>            <dbl>    <int> <dbl>                <dbl>
#> 1     1  22.3  11.2            2.12         3 0.478                 16.4
#> 2     2  21.9  11.9            2.20         3 0.266                 15.5
#> 3     3  28.0  13.5            0.719        3 0.493                 14.0
#> 4     4  19.2  11.8            0.789        3 0.874                 15.6
#> 5     5  17.0  14.2            0.513        3 1.26                  13.5
#> # ℹ 9 more variables: t2_limit_empirical <dbl>, t2_percentile <dbl>, q <dbl>,
#> #   q_limit_theoretical <dbl>, q_limit_empirical <dbl>, q_percentile <dbl>,
#> #   t2_ratio <dbl>, q_ratio <dbl>, status <fct>

# Theoretical limits at 99%
lwpls_local(fit, mtcars[1:5, ], limits = "theoretical", level = 0.99)
#> LW-PLS local models
#> 
#> Queries:           5 
#> Components:        3 
#> Reliability:       5 inside (theoretical limits, 99%) 
```
