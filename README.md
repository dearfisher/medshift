
<!-- README.md is generated from README.Rmd. Please edit that file -->

# R/`medshift`

[![Travis-CI Build
Status](https://travis-ci.org/nhejazi/medshift.svg?branch=master)](https://travis-ci.org/nhejazi/medshift)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/nhejazi/medshift?branch=master&svg=true)](https://ci.appveyor.com/project/nhejazi/medshift)
[![Coverage
Status](https://img.shields.io/codecov/c/github/nhejazi/medshift/master.svg)](https://codecov.io/github/nhejazi/medshift?branch=master)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![MIT
license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

> Causal Mediation Analysis for Stochastic Interventions

**Authors:** [Nima Hejazi](https://nimahejazi.org) and [Iván
Díaz](https://idiaz.xyz)

-----

## What’s `medshift`?

The `medshift` R package is designed to provide facilities for
estimating a parameter that arises in a decomposition of the population
intervention causal effect into the (in)direct effects under stochastic
interventions in the setting of mediation analysis. `medshift` is
designed as an implementation to accompany the methodology described in
Díaz and Hejazi (2019).

-----

## Installation

Install the most recent *stable release* from GitHub via
[`devtools`](https://www.rstudio.com/products/rpackages/devtools/):

``` r
devtools::install_github("nhejazi/medshift")
```

-----

## Example

To illustrate how `medshift` may be used to estimate the effect of
applying a stochastic intervention to the treatment (`A`) while keeping
the mediator(s) (`Z`) fixed, consider the following example:

``` r
library(data.table)
library(medshift)

# produces a simple data set based on ca causal model with mediation
make_simple_mediation_data <- function(n_obs = 1000) {
  # baseline covariate -- simple, binary
  W <- rbinom(n_obs, 1, prob = 0.50)

  # create treatment based on baseline W
  A <- as.numeric(rbinom(n_obs, 1, prob = W / 4 + 0.1))

  # single mediator to affect the outcome
  z1_prob <- 1 - plogis((A^2 + W) / (A + W^3 + 0.5))
  z1_prob[z1_prob < 0.01] <- 0.01
  z1_prob[z1_prob > 0.99] <- 0.99
  Z <- rbinom(n_obs, 1, prob = z1_prob)

  # create outcome as a linear function of A, W + white noise
  Y <- Z + A - 0.1 * W + rnorm(n_obs, mean = 0, sd = 0.25)

  # full data structure
  data <- as.data.table(cbind(Y, Z, A, W))
  setnames(data, c("Y", "Z", "A", "W"))
  return(data)
}

# set seed and simulate example data
set.seed(75681)
example_data <- make_simple_mediation_data()

# compute AIPW estimate based on an incremental propensity score intervention
# that triples (delta = 3) the individual-specific odds of receiving treatment
aipw_medshift <- medshift(W = example_data$W, A = example_data$A,
                          Z = example_data$Z, Y = example_data$Y,
                          delta = 3, estimator = "onestep",
                          estimator_args = list(cv_folds = 3))
summary(aipw_medshift)
#>             lwr_ci          param_est             upr_ci 
#>           0.740072           0.788103           0.836135 
#>          param_var           eif_mean          estimator 
#>           0.000601      -3.501778e-17 one-step efficient
```

For details on how to use data adaptive regression (machine learning)
techniques in the estimation of nuisance parameters, consider consulting
the vignette that accompanies the package.

-----

## Issues

If you encounter any bugs or have any specific feature requests, please
[file an issue](https://github.com/nhejazi/medshift/issues).

-----

## Contributions

Contributions are very welcome. Interested contributors should consult
our [contribution
guidelines](https://github.com/nhejazi/medshift/blob/master/CONTRIBUTING.md)
prior to submitting a pull request.

-----

## Citation

After using the `medshift` R package, please cite the following:

``` 
    @article{diaz2019causal,
      title={Causal mediation analysis for stochastic interventions},
      author={D{\'\i}az, Iv{\'a}n and Hejazi, Nima S},
      year={2019},
      url = {https://arxiv.org/abs/1901.02776},
      doi = {},
      journal={submitted},
      volume={},
      number={},
      pages={},
      publisher={}
    }

    @manual{hejazi2019medshift,
      author = {Hejazi, Nima S and D{\'\i}az, Iv{\'a}n},
      title = {{medshift}: Causal mediation analysis for stochastic
        interventions in {R}},
      year  = {2019},
      url = {https://github.com/nhejazi/medshift},
      note = {R package version 0.0.8}
    }
```

-----

## License

© 2018-2019 [Nima S. Hejazi](https://nimahejazi.org)

The contents of this repository are distributed under the MIT license.
See below for details:

    MIT License
    
    Copyright (c) 2018-2019 Nima S. Hejazi
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

-----

## References

<div id="refs" class="references">

<div id="ref-diaz2019causal">

Díaz, Iván, and Nima S Hejazi. 2019. “Causal Mediation Analysis for
Stochastic Interventions.” *Submitted*.
<https://arxiv.org/abs/1901.02776>.

</div>

</div>
