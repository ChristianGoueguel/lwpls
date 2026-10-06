# Predictions for several numbers of components

`multi_predict()` returns the predictions of a fitted
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
model for several values of `num_comp` at once. All values are obtained
from a single pass over the data.

## Usage

``` r
# S3 method for class '`_lwpls_fit`'
multi_predict(object, new_data, type = NULL, num_comp = NULL, ...)
```

## Arguments

- object:

  A
  [parsnip::model_fit](https://parsnip.tidymodels.org/reference/model_fit.html)
  object created from a
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  specification.

- new_data:

  A rectangular data object, such as a data frame.

- type:

  A single character value or `NULL`. Possible values are `"numeric"`,
  `"class"`, or `"prob"`. When `NULL`, `"numeric"` is used for
  regression and `"class"` for classification.

- num_comp:

  An integer vector with the numbers of components. Defaults to the
  value used to fit the model.

- ...:

  Not currently used.

## Value

A tibble with the same number of rows as `new_data` and a list column
`.pred` of tibbles, each with a `num_comp` column and the prediction
column(s).

## Examples

``` r
fit <-
  lwpls(num_comp = 4) |>
  parsnip::set_mode("regression") |>
  parsnip::fit(mpg ~ ., data = mtcars[-(1:5), ])

preds <- parsnip::multi_predict(fit, mtcars[1:5, ], num_comp = 1:4)
preds
#> # A tibble: 5 × 1
#>   .pred           
#>   <list>          
#> 1 <tibble [4 × 2]>
#> 2 <tibble [4 × 2]>
#> 3 <tibble [4 × 2]>
#> 4 <tibble [4 × 2]>
#> 5 <tibble [4 × 2]>
preds$.pred[[1]]
#> # A tibble: 4 × 2
#>   num_comp .pred
#>      <int> <dbl>
#> 1        1  21.5
#> 2        2  22.1
#> 3        3  22.3
#> 4        4  22.1
```
