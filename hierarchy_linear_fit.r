rm(list = ls())
gc()

# Remember to set your working directory!

library(rstan)  # should load version 2.18.2
library(ggplot2)
library(plyr)
library(tidyr)
library(dplyr)

rstan_options(auto_write = TRUE)
set.seed(1954)

## read data
data <- read_rdump("data/hierarchical_linear.data.r")

# Since our data is a little more complex, let's take
# a look at it.
data_pred <- data.frame(data$x, data$y, as.factor(data$group))
names(data_pred) <- c("x", "y", "group")

# Plot data without groups
p <- ggplot(data_pred, aes(x = x, y = y)) + geom_point() +
  ylim(0, 50) + xlim(0, 20)

# Plot data with groups.
p1 <- ggplot(data_pred, aes(x = x, y = y, color = group)) + geom_point() +
  ylim(0, 50) + xlim(0, 20)

# How many points are there in each group?
table(data_pred$group)

###############################################################################
## Fit the model

## create initial estimates
L <- data$L
init <- function() {
  list(beta = rnorm(10,1,1),
       tau = rgamma(1,1),
       mu = rnorm(1,2,1),
       sigma = rgamma(1,1))
}

## run Stan (in parallel, this time!)
fit <- stan(file = "model/hier.stan",
            data = data,
            init = init,
            chains = 4,
            cores = 3,
            iter = 2000)


# diagnostic checks
pars = c("beta", "sigma", "mu", "tau", "lp__")
summary(fit, pars = pars)[1]
traceplot(fit, inc_warmup = TRUE, pars = pars)
stan_dens(fit, separate_chains = TRUE, pars = pars)
# pairs(fit, pars = pars)

###############################################################################
## posterior predictive plots

pred <- as.data.frame(fit, pars = "y_pred_pop") %>%
  gather(factor_key = TRUE) %>%
  group_by(key) %>%
  summarize(lb = quantile(value, probs = 0.05),
            median = quantile(value, probs = 0.5),
            ub = quantile(value, probs = 0.95)) %>%
  bind_cols(data_pred)

# predictions for a new group
p2 <- ggplot(pred, aes(x = x, y = y))
p2 <- p2 + geom_point()
p2 + geom_line(aes(x = x, y = median)) +
  geom_ribbon(aes(ymin = lb, ymax = ub), alpha = 0.25)

# prediction within groups
pred2 <- as.data.frame(fit, pars = "y_pred") %>%
  gather(factor_key = TRUE) %>%
  group_by(key) %>%
  summarize(lb = quantile(value, probs = 0.05),
            median = quantile(value, probs = 0.5),
            ub = quantile(value, probs = 0.95)) %>%
  bind_cols(data_pred)

p3 <- ggplot(pred2, aes(x = x, y = y))
p3 <- p3 + geom_point()
p3 + geom_line(aes(x = x, y = median)) +
  geom_ribbon(aes(ymin = lb, ymax = ub), alpha = 0.25) +
  facet_wrap(~ group)
