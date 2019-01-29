rm(list = ls())
gc()
.libPaths()

# Make sure to adjust your working and lib directory.

library(rstan)  # should load version 2.18.2
library(ggplot2)
library(plyr)
library(tidyr)
library(dplyr)

rstan_options(auto_write = TRUE)
set.seed(1954)

## read data
data <- read_rdump("data/linear.data.r")

## create initial estimates (optional)
init <- function() {
  list(sigma = rgamma(1, 1),
       beta = rnorm(1, mean = 1, sd = 1))#,
       # alpha = rnorm(1, mean = 1, sd = 1))
}

## run Stan
fit <- stan(file = "model/linear.stan",
            data = data,
            init = init)

# Remark: the result is stored in the fit object.
summary(fit)[1]
# r hat shows good agreement with chains

# Do graphical checks.
pars = c("beta", "alpha", "sigma", "lp__")
traceplot(fit, inc_warmup = TRUE, pars = pars)
# takeaways from this plot: warm up too long, markov chains all in agreement
# log posterior rapidly increases when we hit the high density parameter space

# if chains not in agreement -- could indicate bias 
# happens with bimodal distributions, degenerate distributions
# manifests itself in R hat

# can plot without warmup
traceplot(fit, pars = pars)

# distribution of parameters and structures for diagnosis
stan_dens(fit, separate_chains = TRUE, pars = pars)
pairs(fit, pars = pars)

# Posterior predictive checks (PPC) -- very powerful
# simulate data according to y_pred ~ norm(x * beta(i), sigma(i))
data_pred <- data.frame(data$x, data$y)
names(data_pred) <- c("x", "y")

pred <- as.data.frame(fit, pars = "y_pred") %>%
  gather(factor_key = TRUE) %>%
  group_by(key) %>%
  summarize(lb = quantile(value, probs = 0.05),
            median = quantile(value, probs = 0.5),
            ub = quantile(value, probs = 0.95)) %>%
  bind_cols(data_pred)

p1 <- ggplot(pred, aes(x = x, y = y))
p1 <- p1 + geom_point()
p1 + geom_line(aes(x = x, y = median)) +
  geom_ribbon(aes(ymin = lb, ymax = ub), alpha = 0.25)
# posterior check indicates a systematic underestimation
## since line starts at zero, it would seem as though an intercept is needed in
# a new model specification to correct for model underestimation

# just as we did posterior predictive checks, we can do prior predictive checks
# results are a compromise of prior and data ... if data is very informative,
# then information from the data is going to dominate
## stan prior-choice-recommendations

## note
# the prior should be thought of as part of the model
# the prior can encode:
# an existing distribution
# theoretical information
# a regularization device (lasso, ridge regression) 
## (ie, define priors close to zero satisfies sparsity)
# any quantitative assumption