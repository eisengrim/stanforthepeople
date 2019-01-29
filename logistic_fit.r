# filename: logistic_fit.r
# author:   kody andrew crowell
# date:     25 jan 2019

rm(list = ls())
gc()

library(rstan)
library(ggplot2)
library(plyr)
library(tidyr)
library(dplyr)

rstan_options(auto_write = TRUE)
set.seed(1954)

## read data
data <- read_rdump("data/logistic.data.r")

inits <- function() {
  list(beta = rnorm(1, 1, 1),
       beta2 = rnorm(1, 1, 1))
}

fit <- stan(file = "model/logistic.stan",
            data = data,
            init = inits,
            chains = 4,
            iter = 2000,
            control = list(adapt_delta = 0.99))
# note: target average proposal acceptance probability during stan’s adaptation 
# period, and increasing it will force Stan to take smaller steps. The downside
# is that sampling will tend to be slower because a smaller step size means that
# more steps are required. Since the validity of the estimates is not guaranteed
# if there are post-warmup divergences, the slower sampling is a minor cost.

# diagnostics
summary(fit, pars = c("beta", "beta2", "lp__", "sum_err"))[1]
pars = c("beta", "beta2", "sum_err", "lp__")
traceplot(fit, inc_warmup = TRUE, pars = pars)
stan_dens(fit, separate_chains = TRUE, pars = pars)
pairs(fit, pars = pars)
# sum_err decreased after addition of x2

# in terms of interpretation with two vars, something seems off
# in season data very sparse
# possible overfitting
# x1 and x2 together drastically improve model's prediction for early season
# performance but not for inference
## suspicious -- not uncommon with logistic models
# due to degeneracy in the model? countered by a strong, informative prior

