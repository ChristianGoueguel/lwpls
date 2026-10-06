# Fit a locally-weighted partial least squares model

`lwpls_fit()` is the computational engine behind
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md). It
can also be used on its own through the matrix, data frame, formula or
recipe interfaces.

LW-PLS is a lazy learner: fitting validates and standardizes the
training data and stores it together with the hyperparameters. The local
models are built at prediction time (see
[`predict.lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/predict.lwpls_fit.md)).

Sparse (`sparsity > 0`) and robust (`robust = TRUE`) local models are
described in
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md).

## Usage

``` r
lwpls_fit(x, ...)

# Default S3 method
lwpls_fit(x, ...)

# S3 method for class 'data.frame'
lwpls_fit(
  x,
  y,
  num_comp = 2L,
  localization = 1,
  neighbors = NULL,
  similarity = "euclidean",
  sparsity = 0,
  scale = TRUE,
  robust = FALSE,
  weight_function = "fair",
  robust_constant = NULL,
  max_iter = 30L,
  ...
)

# S3 method for class 'matrix'
lwpls_fit(
  x,
  y,
  num_comp = 2L,
  localization = 1,
  neighbors = NULL,
  similarity = "euclidean",
  sparsity = 0,
  scale = TRUE,
  robust = FALSE,
  weight_function = "fair",
  robust_constant = NULL,
  max_iter = 30L,
  ...
)

# S3 method for class 'formula'
lwpls_fit(
  formula,
  data,
  num_comp = 2L,
  localization = 1,
  neighbors = NULL,
  similarity = "euclidean",
  sparsity = 0,
  scale = TRUE,
  robust = FALSE,
  weight_function = "fair",
  robust_constant = NULL,
  max_iter = 30L,
  ...
)

# S3 method for class 'recipe'
lwpls_fit(
  x,
  data,
  num_comp = 2L,
  localization = 1,
  neighbors = NULL,
  similarity = "euclidean",
  sparsity = 0,
  scale = TRUE,
  robust = FALSE,
  weight_function = "fair",
  robust_constant = NULL,
  max_iter = 30L,
  ...
)
```

## Arguments

- x:

  Depending on the context:

  - A **data frame** or **matrix** of numeric predictors.

  - A **recipe** specifying a set of preprocessing steps created from
    [`recipes::recipe()`](https://recipes.tidymodels.org/reference/recipe.html).

- ...:

  Not currently used, but required for extensibility.

- y:

  When `x` is a **data frame** or **matrix**, `y` is the outcome:

  - A **factor** (or a one-column data frame with a factor) for
    classification.

  - A **numeric vector**, or a **matrix**/**data frame** with one or
    more numeric columns, for regression.

- num_comp:

  The number of PLS components in each local model. It is capped at the
  maximum possible value, `min(ncol(x), nrow(x) - 1)`.

- localization:

  A positive number: the localization parameter of the similarity
  weights (see
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)).
  Smaller values give more local models.

- neighbors:

  Either `NULL` (default), to use all training samples, or the number of
  nearest training samples used to build each local model.

- similarity:

  The similarity index used to weight the training samples:
  `"euclidean"` (default) or `"covariance"` (covariance-based LW-PLS,
  CbLW-PLS). See
  [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  for details.

- sparsity:

  A number in `[0, 1)`: the sparsity threshold \\\eta\\ of the local
  models (Hoffmann et al., 2015). Zero (default) gives ordinary local
  PLS models.

- scale:

  A logical: should the predictors (and numeric outcomes) be
  standardized to unit variance? Predictors are always centered, which
  does not affect the predictions. For robust models, the center and
  scale are the median and the median absolute deviation (MAD).

- robust:

  A logical: should the local models be robust to outliers (partial
  robust M-regression, Serneels et al., 2005)?

- weight_function:

  The weight function of the robust models: `"fair"` (default) or
  `"hampel"`.

- robust_constant:

  The tuning constant(s) of the weight function: for `"fair"`, the
  constant \\c\\ of the Fair function (default 4); for `"hampel"`, three
  increasing probabilities that define the cutoffs (default
  `c(0.95, 0.975, 0.999)`). `NULL` uses the defaults.

- max_iter:

  The maximum number of iterations of the robust models.

- formula:

  A formula specifying the outcome terms on the left-hand side and the
  predictor terms on the right-hand side. Multiple numeric outcomes can
  be given as `y1 + y2 ~ .`.

- data:

  When a **recipe** or **formula** is used, `data` is a data frame
  containing both the predictors and the outcome(s).

## Value

A `lwpls_fit` object, which stores the standardized training data, the
standardization constants and the hyperparameters.

## See also

[`predict.lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/predict.lwpls_fit.md),
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)

## Examples

``` r
train <- mtcars[-(1:5), ]
test <- mtcars[1:5, ]

# XY interface
fit <- lwpls_fit(train[, -1], train$mpg, num_comp = 3, localization = 0.5)
fit
#> Locally-weighted PLS (regression)
#> 
#> Training samples: 27 
#> Predictors:       10 (standardized) 
#> Components:       3 
#> Localization:     0.5 
#> Similarity:       Euclidean 
#> Neighbors:        all (27) 
predict(fit, test[, -1])
#> # A tibble: 5 × 1
#>   .pred
#>   <dbl>
#> 1  21.1
#> 2  20.7
#> 3  27.0
#> 4  18.8
#> 5  17.4

# Formula interface, with two outcomes
fit2 <- lwpls_fit(mpg + qsec ~ ., data = train, num_comp = 3)
predict(fit2, test)
#> # A tibble: 5 × 2
#>   .pred_mpg .pred_qsec
#>       <dbl>      <dbl>
#> 1      22.1       16.4
#> 2      21.7       16.4
#> 3      28.6       18.9
#> 4      19.2       20.0
#> 5      16.8       16.9

# Classification
fit3 <- lwpls_fit(Species ~ ., data = iris, num_comp = 2)
predict(fit3, iris[c(1, 51, 101), ], type = "prob")
#> # A tibble: 3 × 3
#>   .pred_setosa .pred_versicolor .pred_virginica
#>          <dbl>            <dbl>           <dbl>
#> 1      0.990            0.00970           0    
#> 2      0.0269           0.502             0.471
#> 3      0.00553          0.0235            0.971

# Robust and sparse local models
fit4 <- lwpls_fit(mpg ~ ., data = train, num_comp = 3, robust = TRUE, sparsity = 0.3)
fit4
#> Locally-weighted PLS (regression)
#> 
#> Training samples: 27 
#> Predictors:       10 (standardized) 
#> Outcomes:         mpg 
#> Components:       3 
#> Localization:     1 
#> Similarity:       Euclidean 
#> Neighbors:        all (27) 
#> Sparsity:         0.3 (SNIPLS)
#> Robust:           PRM, Fair weights (c = 4)
predict(fit4, test)
#> # A tibble: 5 × 1
#>   .pred
#>   <dbl>
#> 1  20.3
#> 2  20.7
#> 3  25.2
#> 4  18.6
#> 5  16.0
```
