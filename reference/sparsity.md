# Sparsity of the LW-PLS local models

The sparsity threshold \\\eta\\ of
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md): the
weight vector of each component of a local model is soft-thresholded at
\\\eta \max_j \|w_j\|\\ (sparse NIPALS, Hoffmann et al., 2015). Zero
gives ordinary local PLS models; larger values drop more predictors.

## Usage

``` r
sparsity(range = c(0, 0.9), trans = NULL)
```

## Arguments

- range:

  A two-element vector holding the *defaults* for the smallest and
  largest possible values, respectively.

- trans:

  A `trans` object from the `scales` package, or `NULL` (the default)
  for no transformation.

## Value

A `quant_param` object (see
[`dials::new_quant_param()`](https://dials.tidymodels.org/reference/new-param.html)).

## References

Hoffmann, I., Serneels, S., Filzmoser, P. and Croux, C. (2015). Sparse
partial robust M regression. *Chemometrics and Intelligent Laboratory
Systems*, 149, 50–59.
[doi:10.1016/j.chemolab.2015.09.019](https://doi.org/10.1016/j.chemolab.2015.09.019)

## Examples

``` r
sparsity()
#> Sparsity Threshold (quantitative)
#> Range: [0, 0.9]
dials::value_seq(sparsity(), 4)
#> [1] 0.0 0.3 0.6 0.9
```
