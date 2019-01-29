// template for stan file.
// note: stan needs to end with a blank link

data {
  int N;
  vector[N] x;
  vector[N] y;
}

parameters {
  real alpha;
  real beta;
  real sigma;
}

model {
  // specify data generating process
  // prior distribution
  alpha ~ normal(20, 1.0);
  beta ~ normal(2.0, 1.0);
  sigma ~ gamma(1.0, 1.0);

  // likelihood distribution
  // since y and x are vectors, normal dist'n is vectorized
  // increases target log density -- not a number generator
  // deterministic statement, nothing is being sampled
  y ~ normal(alpha + beta * x, sigma);
  
  // can also write as (useful for more complex configurations):
  // for (i in 1:N) y[i] ~ normal(beta * x[i], sigma);
}

generated quantities {
  vector[N] y_pred;
  
  // randomly generate predicted y based on beta and sigma for ppc
  for (i in 1:N) 
    y_pred[i] = normal_rng(beta * x[i] + alpha, sigma);
}
