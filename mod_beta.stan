data {
  int<lower=0> N;
  array[N] int<lower=0,upper=1> y;
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> beta;
}
model {
  theta ~ beta(0.5,beta);  // uniform prior on interval 0,1
  y ~ bernoulli(theta);
}