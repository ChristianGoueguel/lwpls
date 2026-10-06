# Similarity index for LW-PLS

The similarity index determines how the distance between a query sample
and the training samples is measured before it is turned into weights by
[`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md):

## Usage

``` r
similarity(values = values_similarity)

values_similarity
```

## Arguments

- values:

  A character vector of possible similarity indexes.

## Value

A `qual_param` object (see
[`dials::new_qual_param()`](https://dials.tidymodels.org/reference/new-param.html)).

## Details

- `"euclidean"`: the Euclidean distance between the (standardized)
  predictors, as in the original LW-PLS.

- `"covariance"`: the distance after projecting the samples on the
  covariance direction \\\Gamma = X^\top Y / \lVert X^\top Y \rVert\\
  (covariance-based LW-PLS, CbLW-PLS; Hazama and Kano, 2015). It
  accounts for the relationships among the predictors and between the
  predictors and the outcome(s).

## References

Hazama, K. and Kano, M. (2015). Covariance-based locally weighted
partial least squares for high-performance adaptive modeling.
*Chemometrics and Intelligent Laboratory Systems*, 146, 55–62.
[doi:10.1016/j.chemolab.2015.05.007](https://doi.org/10.1016/j.chemolab.2015.05.007)

## Examples

``` r
similarity()
#> Similarity Index (qualitative)
#> 2 possible values include:
#> 'euclidean' and 'covariance'
values_similarity
#> [1] "euclidean"  "covariance"
```
