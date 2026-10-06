# Update a locally-weighted PLS specification

Update a locally-weighted PLS specification

## Usage

``` r
# S3 method for class 'lwpls'
update(
  object,
  parameters = NULL,
  num_comp = NULL,
  localization = NULL,
  neighbors = NULL,
  fresh = FALSE,
  ...
)
```

## Arguments

- object:

  A [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md)
  model specification.

- parameters:

  A 1-row tibble or named list with *main* parameters to update. Use
  **either** `parameters` **or** the main arguments directly when
  updating. If the main arguments are used, these will supersede the
  values in `parameters`. Also, using engine arguments in this object
  will result in an error.

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

- fresh:

  A logical for whether the arguments should be modified in-place or
  replaced wholesale.

- ...:

  Not used for [`update()`](https://rdrr.io/r/stats/update.html).

## Value

An updated model specification.

## Examples

``` r
spec <- lwpls(num_comp = 3)
spec
#> Locally-Weighted PLS Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   num_comp = 3
#> 
#> Computational engine: lwpls 
#> 
update(spec, localization = 0.25)
#> Locally-Weighted PLS Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   num_comp = 3
#>   localization = 0.25
#> 
#> Computational engine: lwpls 
#> 
update(spec, localization = 0.25, fresh = TRUE)
#> Locally-Weighted PLS Model Specification (unknown mode)
#> 
#> Main Arguments:
#>   localization = 0.25
#> 
#> Computational engine: lwpls 
#> 
```
