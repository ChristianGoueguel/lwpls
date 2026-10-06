# Introduction to lwpls

Locally-weighted partial least squares (LW-PLS) is a *just-in-time*
learning method. Instead of fitting a single global PLS model, LW-PLS
builds a new weighted PLS model around every sample to be predicted.
Training samples that are similar to the query get large weights and
dissimilar ones get small weights. The result is a locally linear model
that can follow nonlinear and drifting relationships, which is why
LW-PLS is widely used for soft sensors and for spectroscopic
calibration.

The lwpls package implements LW-PLS natively (the prediction kernel is
written in C++) and integrates it with tidymodels:

- [`lwpls()`](https://christiangoueguel.com/lwpls/reference/lwpls.md) is
  a [parsnip](https://parsnip.tidymodels.org) model specification for
  regression and classification;
- [`localization()`](https://christiangoueguel.com/lwpls/reference/localization.md)
  is a [dials](https://dials.tidymodels.org) tuning parameter;
- [tune](https://tune.tidymodels.org) evaluates all values of `num_comp`
  from a single model fit.

``` r

library(lwpls)
library(parsnip)
library(rsample)
library(tune)
library(workflows)
library(yardstick)
library(ggplot2)
```

## The algorithm

For a query sample $`x_q`$, the similarity weight of the training sample
$`x_i`$ is

``` math
\omega_i = \exp\left(-\frac{d_i}{\sigma_d \, \varphi}\right), \qquad
d_i = \lVert x_i - x_q \rVert,
```

where $`\sigma_d`$ is the standard deviation of the distances $`d_i`$
and $`\varphi > 0`$ is the **localization** parameter. The training data
are centered with the weighted means, a PLS model with `num_comp`
components is fitted using the weights $`\omega_i`$, and the query is
projected onto that local model to get its prediction.

The two main hyperparameters are therefore:

- `num_comp`: the number of PLS components of the local models;
- `localization`: small values make the models very local (only the
  nearest samples matter); large values make all weights similar, so
  LW-PLS tends to a global PLS model.

Optionally, `neighbors` restricts each local model to the nearest
training samples, which reduces the cost of each local model for large
training sets.

## Regression: fat-free water content of meat from NIR spectra

The `meats` data from the modeldata package contain 100 near-infrared
absorbance values for 215 meat samples. We predict the water content.

``` r

data(meats, package = "modeldata")
meats <- meats[, !names(meats) %in% c("fat", "protein")]

set.seed(123)
meats_split <- initial_split(meats, prop = 0.75)
meats_train <- training(meats_split)
meats_test <- testing(meats_split)
meats_folds <- vfold_cv(meats_train, v = 5)
```

The model specification marks both hyperparameters for tuning. Since
LW-PLS calculates its local models at prediction time, all values of
`num_comp` are obtained from the same model, and tune fits only one
model per value of `localization` (the “submodel trick”).

``` r

lwpls_spec <-
  lwpls(num_comp = tune(), localization = tune()) |>
  set_mode("regression")

lwpls_wflow <- workflow(water ~ ., lwpls_spec)

lwpls_grid <- dials::grid_regular(
  dials::num_comp(c(1, 15)),
  localization(),
  levels = c(num_comp = 15, localization = 8)
)

lwpls_res <- tune_grid(
  lwpls_wflow,
  resamples = meats_folds,
  grid = lwpls_grid,
  metrics = metric_set(rmse, rsq)
)

show_best(lwpls_res, metric = "rmse", n = 5)
#> # A tibble: 5 × 8
#>   num_comp localization .metric .estimator  mean     n std_err .config          
#>      <int>        <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>            
#> 1       10          0.5 rmse    standard    1.66     5   0.156 pre0_mod077_post0
#> 2       13          0.5 rmse    standard    1.68     5   0.198 pre0_mod101_post0
#> 3        9          0.5 rmse    standard    1.70     5   0.174 pre0_mod069_post0
#> 4        8          0.5 rmse    standard    1.71     5   0.184 pre0_mod061_post0
#> 5       12          0.5 rmse    standard    1.77     5   0.194 pre0_mod093_post0
```

``` r

autoplot(lwpls_res, metric = "rmse") +
  scale_color_viridis_d(option = "mako", end = 0.9) +
  theme_bw()
```

![Cross-validated RMSE versus the number of components, one line per
localization value.](lwpls_files/figure-html/tune-plot-1.png)

Very local models (small `localization`) quickly over-fit, while very
large values reproduce global PLS. The best models lie in between.

We finalize the workflow with the best parameters and evaluate it on the
test set:

``` r

best_params <- select_best(lwpls_res, metric = "rmse")
best_params
#> # A tibble: 1 × 3
#>   num_comp localization .config          
#>      <int>        <dbl> <chr>            
#> 1       10          0.5 pre0_mod077_post0

lwpls_final <-
  lwpls_wflow |>
  finalize_workflow(best_params) |>
  last_fit(meats_split)

collect_metrics(lwpls_final)
#> # A tibble: 2 × 4
#>   .metric .estimator .estimate .config        
#>   <chr>   <chr>          <dbl> <chr>          
#> 1 rmse    standard       1.38  pre0_mod0_post0
#> 2 rsq     standard       0.978 pre0_mod0_post0
```

### Comparison with global PLS

With a very large localization, all training samples get the same weight
and LW-PLS reduces to ordinary PLS. This gives a convenient baseline:

``` r

pls_wflow <- workflow(
  water ~ .,
  lwpls(num_comp = tune(), localization = 1e6) |> set_mode("regression")
)
pls_res <- tune_grid(
  pls_wflow,
  resamples = meats_folds,
  grid = data.frame(num_comp = 1:15),
  metrics = metric_set(rmse, rsq)
)

pls_final <-
  pls_wflow |>
  finalize_workflow(select_best(pls_res, metric = "rmse")) |>
  last_fit(meats_split)

collect_metrics(pls_final)
#> # A tibble: 2 × 4
#>   .metric .estimator .estimate .config        
#>   <chr>   <chr>          <dbl> <chr>          
#> 1 rmse    standard       2.40  pre0_mod0_post0
#> 2 rsq     standard       0.933 pre0_mod0_post0
```

The local models clearly improve on the global calibration.

``` r

test_preds <- rbind(
  data.frame(model = "Global PLS", collect_predictions(pls_final)),
  data.frame(model = "LW-PLS", collect_predictions(lwpls_final))
)

ggplot(test_preds, aes(water, .pred)) +
  geom_abline(color = "grey50", linetype = 2) +
  geom_point(alpha = 0.7) +
  facet_wrap(~model) +
  coord_obs_pred() +
  labs(x = "Observed water (%)", y = "Predicted water (%)") +
  theme_bw()
```

![Observed versus predicted water content on the test set for global PLS
and LW-PLS.](lwpls_files/figure-html/obs-pred-1.png)

## Classification

For a factor outcome, LW-PLS models the class indicators (LW-PLS-DA).
The predicted class is the one with the largest predicted indicator, and
the indicators, truncated to $`[0, 1]`$, give the class probabilities.

``` r

set.seed(1)
iris_split <- initial_split(iris, strata = Species)

iris_fit <-
  lwpls(num_comp = 2, localization = 0.5) |>
  set_mode("classification") |>
  fit(Species ~ ., data = training(iris_split))

iris_preds <- augment(iris_fit, testing(iris_split))
head(iris_preds[, 1:5])
#> # A tibble: 6 × 5
#>   .pred_class .pred_setosa .pred_versicolor .pred_virginica Sepal.Length
#>   <fct>              <dbl>            <dbl>           <dbl>        <dbl>
#> 1 setosa             0.927          0.0729          0                4.9
#> 2 setosa             1              0               0                5  
#> 3 setosa             0.985          0.00747         0.00782          5.4
#> 4 setosa             0.956          0.0440          0                4.8
#> 5 setosa             0.958          0.0128          0.0289           5.7
#> 6 setosa             0.986          0.00366         0.00985          5.4
accuracy(iris_preds, truth = Species, estimate = .pred_class)
#> # A tibble: 1 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy multiclass     0.923
```

## Using the engine directly

The fitting function
[`lwpls_fit()`](https://christiangoueguel.com/lwpls/reference/lwpls_fit.md)
can be used without parsnip. It has matrix, data frame, formula and
recipe interfaces, and its
[`predict()`](https://rdrr.io/r/stats/predict.html) method can use any
number of components:

``` r

fit <- lwpls_fit(water ~ ., data = meats_train, num_comp = 10, localization = 0.5)
fit
#> Locally-weighted PLS (regression)
#> 
#> Training samples: 161 
#> Predictors:       100 (standardized) 
#> Outcomes:         water 
#> Components:       10 
#> Localization:     0.5 
#> Neighbors:        all (161)

predict(fit, head(meats_test))
#> # A tibble: 6 × 1
#>   .pred
#>   <dbl>
#> 1  47.1
#> 2  70.4
#> 3  63.4
#> 4  75.7
#> 5  69.8
#> 6  72.1
predict(fit, head(meats_test), num_comp = 3)
#> # A tibble: 6 × 1
#>   .pred
#>   <dbl>
#> 1  47.3
#> 2  70.5
#> 3  63.1
#> 4  73.0
#> 5  62.3
#> 6  74.7
```

Several numbers of components can be predicted at once from a parsnip
model with
[`multi_predict()`](https://parsnip.tidymodels.org/reference/multi_predict.html):

``` r

parsnip_fit <- extract_fit_parsnip(lwpls_final)
multi_predict(parsnip_fit, head(meats_test), num_comp = c(5, 10, 15))$.pred[[1]]
#> # A tibble: 3 × 2
#>   num_comp .pred
#>      <int> <dbl>
#> 1        5  49.2
#> 2       10  47.1
#> 3       15  47.1
```

## Engine arguments

The `"lwpls"` engine standardizes the predictors (and numeric outcomes)
before computing distances by default. For data measured on a common
scale, such as spectra, this can be switched off:

``` r

lwpls(num_comp = 10, localization = 0.5) |>
  set_mode("regression") |>
  set_engine("lwpls", scale = FALSE) |>
  translate()
#> Locally-Weighted PLS Model Specification (regression)
#> 
#> Main Arguments:
#>   num_comp = 10
#>   localization = 0.5
#> 
#> Engine-Specific Arguments:
#>   scale = FALSE
#> 
#> Computational engine: lwpls 
#> 
#> Model fit template:
#> lwpls::lwpls_fit(x = missing_arg(), y = missing_arg(), num_comp = 10, 
#>     localization = 0.5, scale = FALSE)
```

## References

- Kim, S., Kano, M., Nakagawa, H. and Hasebe, S. (2011). Estimation of
  active pharmaceutical ingredients content using locally weighted
  partial least squares and statistical wavelength selection.
  *International Journal of Pharmaceutics*, 421(2), 269–274.
- Kaneko, H. Locally-weighted partial least squares (LWPLS).
  <https://datachemeng.com/locallyweightedpartialleastsquares/>
- Dayal, B. S. and MacGregor, J. F. (1997). Improved PLS algorithms.
  *Journal of Chemometrics*, 11(1), 73–85.
