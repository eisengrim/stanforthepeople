rm(list = ls())
gc()
set.seed(1954)

## Hierarchical models
library(rstan)
library(ggplot2)
library(plyr)
library(tidyr)
library(dplyr)

## read data
df <- read.csv("data/efron-morris-75-data.tsv", sep = "\t")
df <- with(df, data.frame(FirstName, LastName,
                          Hits, At.Bats,
                          RemainingAt.Bats,
                          RemainingHits = SeasonHits - Hits))

# split the data into a training and a validation set.
N <- dim(df)[1]
K <- df$At.Bats
y <- df$Hits
data =  c("N", "K", "y")

## fit the pool model.
fit_pool <- stan("model/baseball_pool.stan",
                 data = data,
                 chains = 4,
                 cores = min(4, parallel::detectCores()))

summary(fit_pool)[1]

## fit the no pooling model.
fit_no_pool <- stan("model/baseball_no_pool.stan",
                    data = data,
                    chains = 4,
                    cores = min(4, parallel::detectCores()))

summary(fit_no_pool)[1]

# initial values
init <- function(){
  list(mu = rnorm(1,1,1),
       alpha = rnorm(18,0,1),
       sigma = rgamma(1,0.5))
}

## fit partial pooling
fit_partial <- stan("model/baseball_hier.stan",
                    data = data,
                    init = init,
                    chains = 4,
                    cores = min(4, parallel::detectCores()))

# low n_eff due to autocorrelation between samples in markov chain
#   --> increase number of iterations

# divergent transitions possibly due to too large a resolution / step size
# when approximating a hamiltonian trajectory -- vulnerable to funnel geometry
# solution: reparamrize the model using a standardized alpha

# diagnostic checks
pars = c("alpha", "sigma", "mu", "lp__")
summary(fit_partial, pars = pars)[1]
traceplot(fit_partial, inc_warmup = TRUE, pars = pars)
stan_dens(fit_partial, separate_chains = TRUE, pars = pars)
pairs(fit_partial, pars = c("sigma", "mu"))

# reparametrized model
# initial values
init <- function(){
  list(mu = rnorm(1,1,1),
       alpha_std = rnorm(18,0,1),
       sigma = rgamma(1,0.5))
}

## fit partial pooling
fit_partial2 <- stan("model/baseball_hier2.stan",
                    data = data,
                    init = init,
                    seed = 1234,
                    chains = 4,
                    iter = 10000,
                    control = list(adapt_delta = 0.99),
                    cores = min(4, parallel::detectCores()))

# diagnostic checks
pars = c("alpha_std", "sigma", "mu", "lp__")
summary(fit_partial2, pars = pars)[1]
traceplot(fit_partial2, inc_warmup = TRUE, pars = pars)
stan_dens(fit_partial2, separate_chains = TRUE, pars = pars)
pairs(fit_partial2, pars = c("sigma", "mu", "alpha_std[1]", "alpha_std[2]"))

## what to cover
# logistic models with multiple categories
# gaussian processes
# differential equations based models
# time series models

# install: rstanarm, brms