# Trimmed root mean squared error

The root mean squared error of the `1 - trim` fraction of the
observations with the smallest absolute errors. When the reference
values contain outliers, they also appear in the assessment sets of a
resampling scheme, where their errors would dominate the usual RMSE and
favor non-robust models. The trimmed RMSE leaves them out, like the
trimmed standard error of prediction used to tune partial robust
M-regression (Serneels et al., 2005), so it is the metric to use when
tuning robust LW-PLS models
([`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
with `robust = TRUE`) on contaminated data.

## Usage

``` r
trimmed_rmse(data, ...)

# S3 method for class 'data.frame'
trimmed_rmse(
  data,
  truth,
  estimate,
  trim = 0.2,
  na_rm = TRUE,
  case_weights = NULL,
  ...
)

trimmed_rmse_vec(
  truth,
  estimate,
  trim = 0.2,
  na_rm = TRUE,
  case_weights = NULL,
  ...
)
```

## Arguments

- data:

  A data frame containing the columns given by `truth` and `estimate`.

- ...:

  Not currently used.

- truth:

  The column identifier for the true results (numeric).

- estimate:

  The column identifier for the predicted results (numeric).

- trim:

  The fraction of observations with the largest absolute errors to leave
  out, in `[0, 1)`. The default, 0.2, leaves out 20%.

- na_rm:

  A logical: should missing values be removed?

- case_weights:

  The optional column identifier for case weights.

## Value

A tibble with columns `.metric`, `.estimator` and `.estimate` and one
row (or one row per group), or, for `trimmed_rmse_vec()`, a single
number.

## References

Serneels, S., Croux, C., Filzmoser, P. and Van Espen, P. J. (2005).
Partial robust M-regression. *Chemometrics and Intelligent Laboratory
Systems*, 79(1–2), 55–64.
[doi:10.1016/j.chemolab.2005.04.007](https://doi.org/10.1016/j.chemolab.2005.04.007)

## Examples

``` r
df <- data.frame(truth = c(1, 2, 3, 4, 5), estimate = c(1.1, 2.1, 2.9, 4.2, 15))
trimmed_rmse(df, truth, estimate)
#> # A tibble: 1 × 3
#>   .metric      .estimator .estimate
#>   <chr>        <chr>          <dbl>
#> 1 trimmed_rmse standard       0.132
yardstick::rmse(df, truth, estimate)
#> # A tibble: 1 × 3
#>   .metric .estimator .estimate
#>   <chr>   <chr>          <dbl>
#> 1 rmse    standard        4.47

# In a metric set, for example with tune::tune_grid()
metrics <- yardstick::metric_set(trimmed_rmse, yardstick::rmse)
metrics(df, truth, estimate)
#> # A tibble: 2 × 3
#>   .metric      .estimator .estimate
#>   <chr>        <chr>          <dbl>
#> 1 trimmed_rmse standard       0.132
#> 2 rmse         standard       4.47 
```
