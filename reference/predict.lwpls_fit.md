# Predict from a locally-weighted PLS model

For every row of `new_data`, a weighted PLS model is fitted around that
sample and used to predict it.

## Usage

``` r
# S3 method for class 'lwpls_fit'
predict(object, new_data, type = NULL, num_comp = NULL, ...)
```

## Arguments

- object:

  A `lwpls_fit` object created by
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md).

- new_data:

  A data frame or matrix of new predictors.

- type:

  A single character string, or `NULL`. One of:

  - `"numeric"` for numeric predictions (regression; the default).

  - `"class"` for hard class predictions (classification; the default).

  - `"prob"` for class probabilities (classification).

  - `"raw"` for an array with the predictions of the local models with
    `1, ..., num_comp` components (see Value).

- num_comp:

  The number of PLS components to use. Defaults to the value used in
  [`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md).
  Since the model is lazy, any value can be used; values larger than the
  maximum possible number of components give the same predictions as
  that maximum.

- ...:

  Not used, but required for extensibility.

## Value

A tibble of predictions with one row per row of `new_data`, following
the tidymodels conventions: `.pred` (or `.pred_{outcome}` for multiple
outcomes), `.pred_class`, or `.pred_{level}` columns.

For `type = "raw"`, a numeric array of dimension
`nrow(new_data) x q x num_comp`, where `q` is the number of outcomes (or
of classes, for the predicted class indicators), on the original outcome
scale.

Rows of `new_data` with missing values get missing predictions.

## See also

[`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md),
[`multi_predict._lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/multi_predict._lwpls_fit.md)

## Examples

``` r
train <- mtcars[-(1:5), ]
test <- mtcars[1:5, ]

fit <- lwpls_fit(mpg ~ ., data = train, num_comp = 3, localization = 0.5)
predict(fit, test)
#> # A tibble: 5 × 1
#>   .pred
#>   <dbl>
#> 1  21.1
#> 2  20.7
#> 3  27.0
#> 4  18.8
#> 5  17.4
predict(fit, test, num_comp = 1)
#> # A tibble: 5 × 1
#>   .pred
#>   <dbl>
#> 1  21.7
#> 2  21.4
#> 3  27.6
#> 4  18.7
#> 5  16.7
predict(fit, test, type = "raw")
#> , , 1
#> 
#>           mpg
#> [1,] 21.66757
#> [2,] 21.37123
#> [3,] 27.64895
#> [4,] 18.73608
#> [5,] 16.65921
#> 
#> , , 2
#> 
#>           mpg
#> [1,] 21.33833
#> [2,] 21.13447
#> [3,] 27.35273
#> [4,] 18.62587
#> [5,] 17.52832
#> 
#> , , 3
#> 
#>           mpg
#> [1,] 21.14190
#> [2,] 20.70355
#> [3,] 27.03485
#> [4,] 18.75206
#> [5,] 17.44782
#> 
```
