// load data for hierarchical linear model

data {
    int<lower=0> N;
    int<lower=1> L;
    int<lower=1, upper=L> group[N];
    
    real x[N]; // array, not a vector
    real y[N];
}

parameters {
    real mu;
    real<lower=0> tau;
    
    // group betas
    real beta[L];
    // group sigmas difficulat to calculate, data is sparse
    real<lower=0> sigma;
}

model {
    // specify prior distribution
    mu ~ normal(0.2, 1.0);
    tau ~ gamma(2.0, 0.1);

    // specify likelihood
    for (l in 1:L)
      beta[l] ~ normal(mu, tau);
    // also acceptable: beta ~ normal(mu, tau);
      
    for (n in 1:N)
      y[n] ~ normal(beta[group[n]]*x[n], sigma);
    // also acceptable: y ~ normal(x .* beta[group], sigma);
}

generated quantities {
  real y_pred[N];
  real y_pred_pop[N];
  real beta_pred = normal_rng(mu, tau);
  
  for (i in 1:N){
    y_pred[i] = normal_rng(x[i] * beta[group[i]], sigma);
    y_pred_pop[i] =  normal_rng(x[i] * beta_pred, sigma);
  }
}
