// logistic model
// augment model by adding x2?

data {
    int N;
    vector[N] x1;
    vector[N] x2;
    int y[N];
}

parameters {
    real beta;
    real beta2;
}

model {
    // specify prior distribution
    beta ~ normal(2.0, 1.0);
    beta2 ~ normal(0, 1.0);

    // specify likelihood
    y ~ bernoulli_logit(beta * x1 + beta2 * x2);
}

// how to use ppc? 
// use misclassification rate (need to normalize)
generated quantities {
    int y_p[N];
    int sum_err = 0;
    
    for (i in 1:N) {
      y_p[i] = bernoulli_logit_rng(beta * x1[i] + beta2 * x2[i]);
      sum_err += (y[i] != y_p[i]);
    }
}

