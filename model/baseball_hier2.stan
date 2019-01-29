// load data for hierarchical linear model

data {
    int<lower=0> N;       // players
    
    int<lower=0> K[N];    // initial trial
    int<lower=0> y[N];    // iniitial successes
}

parameters {
    real mu;              // population mean successes
    vector[N] alpha_std;  // success log odds
    real<lower=0> sigma;  // population sd of success
}

model {
    // specify prior distribution
    mu ~ normal(-1.0, 1.0);
    alpha_std ~ normal(0, 1);
    sigma ~ normal(0, 1.0); // half-normal
    
    // likelihood
    y ~ binomial_logit(K,  mu + sigma*alpha_std);
}

generated quantities {
  vector[N] theta;
  
  for (n in 1:N) theta[n] = inv_logit(mu + sigma*alpha_std[n]);
}
