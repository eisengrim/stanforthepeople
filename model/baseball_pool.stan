// baseball model, following
// https://mc-stan.org/users/documentation/case-studies/pool-binary-trials.html

data {
  int<lower=0> N;           // items
  int<lower=0> K[N];        // initial trials
  int<lower=0> y[N];        // initial successes
}

parameters {
  real<lower=0, upper=1> phi;  // chance of success (pooled)
}

model {

  // Will use default prior.
  y ~ binomial(K, phi);
}
