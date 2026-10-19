# lwpls: Locally-Weighted Partial Least Squares for 'tidymodels'

Locally-weighted partial least squares (LW-PLS) is a just-in-time
learning method that builds a dedicated weighted partial least squares
model around every new sample, where training samples are weighted by
their similarity to that sample (Kim et al. (2011)
[doi:10.1016/j.ijpharm.2011.10.007](https://doi.org/10.1016/j.ijpharm.2011.10.007)
). Regression (single or multiple outcomes) and classification (locally
weighted partial least squares-discriminant analysis; Bevilacqua and
Marini (2014)
[doi:10.1016/j.aca.2014.05.057](https://doi.org/10.1016/j.aca.2014.05.057)
) are supported. The local models can be robust to outliers, by partial
robust M-regression (Serneels et al. (2005)
[doi:10.1016/j.chemolab.2005.04.007](https://doi.org/10.1016/j.chemolab.2005.04.007)
), and sparse (Hoffmann et al. (2015)
[doi:10.1016/j.chemolab.2015.09.019](https://doi.org/10.1016/j.chemolab.2015.09.019)
). The prediction kernel is written in C++ with 'RcppArmadillo', and the
model is integrated with the 'parsnip', 'dials', 'tune' and 'yardstick'
packages so it can be used within the 'tidymodels' framework.
Diagnostics of the local models (prediction reliability, local
regression vectors, robust weights and selected predictors) come with
'ggplot2' plots designed for spectroscopic data.

## See also

Useful links:

- <https://github.com/ChristianGoueguel/lwpls>

- <https://christiangoueguel.com/lwpls/>

- Report bugs at <https://github.com/ChristianGoueguel/lwpls/issues>

## Author

**Maintainer**: Christian L. Goueguel <christian.goueguel@gmail.com>

Authors:

- Christian L. Goueguel <christian.goueguel@gmail.com>
