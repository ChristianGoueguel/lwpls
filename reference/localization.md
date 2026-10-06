# Localization parameter for LW-PLS

The localization parameter controls how fast the similarity weights of
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
decrease with the distance to the query sample. Small values give very
local models; large values give all training samples similar weights, so
that the model tends to a global PLS model.

## Usage

``` r
localization(range = c(-9, 5), trans = scales::transform_log2())
```

## Arguments

- range:

  A two-element vector holding the *defaults* for the smallest and
  largest possible values, respectively. If a transformation is
  specified, these values should be in the *transformed units*.

- trans:

  A `trans` object from the `scales` package, such as
  [`scales::transform_log10()`](https://scales.r-lib.org/reference/transform_log.html)
  or
  [`scales::transform_reciprocal()`](https://scales.r-lib.org/reference/transform_reciprocal.html).
  If not provided, the default is used which matches the units used in
  `range`. If no transformation, `NULL`.

## Value

A `quant_param` object (see
[`dials::new_quant_param()`](https://dials.tidymodels.org/reference/new-param.html)).

## Details

The default range, \\2^{-9}\\ to \\2^{5}\\ on a log-2 scale, follows the
candidate values used by Kaneko for the LW-PLS hyperparameter search.

## Examples

``` r
localization()
#> Localization Parameter (quantitative)
#> Transformer: log-2 [1e-100, Inf]
#> Range (transformed scale): [-9, 5]
dials::value_seq(localization(), 5)
#> [1]  0.001953125  0.022097087  0.250000000  2.828427125 32.000000000
dials::grid_regular(dials::num_comp(c(1, 5)), localization(), levels = 3)
#> # A tibble: 9 × 2
#>   num_comp localization
#>      <int>        <dbl>
#> 1        1      0.00195
#> 2        3      0.00195
#> 3        5      0.00195
#> 4        1      0.25   
#> 5        3      0.25   
#> 6        5      0.25   
#> 7        1     32      
#> 8        3     32      
#> 9        5     32      
```
