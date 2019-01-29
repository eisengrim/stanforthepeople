// load data for hierarchical linear model

data {
    int<lower=0> N;       // players
    
    int<lower=0> K[N];    // initial trial
    int<lower=0> y[N];    // iniitial successes
}

parameters {
    real mu;              // population mean successes
    real alpha[N];        // success log odds
    real<lower=0> sigma;  // population sd of success
}

model {
    // specify prior distribution
    mu ~ normal(-1.0, 1.0);
    sigma ~ normal(0, 1.0); // half-normal
    
    // specify likelihood
    alpha ~ normal(mu, sigma);
    y ~ binomial_logit(K, alpha);
}
