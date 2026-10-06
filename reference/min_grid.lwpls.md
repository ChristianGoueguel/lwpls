# Determine the minimal set of model fits for tuning

`min_grid()` is used by the tune package to fit as few models as
possible. LW-PLS predictions for `num_comp` components include those for
all smaller numbers of components, so only the largest `num_comp` value
of each combination of the other parameters is fitted.

## Usage

``` r
# S3 method for class 'lwpls'
min_grid(x, grid, ...)
```

## Arguments

- x:

  A [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  model specification.

- grid:

  A tibble with tuning parameter combinations.

- ...:

  Not currently used.

## Value

A tibble with the minimal tuning grid and a list column with the
submodel values to predict.
