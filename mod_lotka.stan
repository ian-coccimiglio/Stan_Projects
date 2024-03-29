
functions {
  real[] dz_dt(real t, real[] z, real[] theta,
             real[] x_r, int[] x_i) {
      real u = z[1];
      real v = z[2];
      real alpha = theta[1];
      real beta = theta[2];
      real gamma = theta[3];
      real delta = theta[4];
      real du_dt = (alpha - beta * v) * u;
      real dv_dt = (-gamma + delta * u) * v;
      return { du_dt, dv_dt };
    }
}
data {
  int<lower=0> N;           // num measurements
  int<lower=0> Nproj;           // projected measurements
  real seq_vector[Nproj];           // projected measurements
  real ts[N];                 // measurement times > 0
  real y_init[2];             // initial measured population
  real<lower = 0> y[N, 2];    // measured population at measurement times
}
parameters {
  real<lower = 0> theta[4];   // theta = {alpha, beta, gamma, delta}
  real<lower = 0> z_init[2];  // initial population
  real<lower = 0> sigma[2];   // error scale
}
transformed parameters {
  real z[Nproj, 2]
    = integrate_ode_rk45(dz_dt, z_init, 0, seq_vector, theta,
                         rep_array(0.0, 0), rep_array(0, 0),
                         1e-6, 1e-5, 1e3);
}
model {
  theta[{1, 3}] ~ normal(1, 0.5);
  theta[{2, 4}] ~ normal(0.05, 0.05);
  sigma ~ lognormal(-1, 1);
  z_init ~ lognormal(log(10), 1);
  for (k in 1:2) {
    y_init[k] ~ lognormal(log(z_init[k]), sigma[k]);
    y[1:20, k] ~ lognormal(log(z[1:20, k]), sigma[k]);
  }
}
generated quantities {
  real y_init_rep[2];
  real y_rep[Nproj, 2];
  for (k in 1:2) {
    y_init_rep[k] = lognormal_rng(log(z_init[k]), sigma[k]);
    for (n in 1:Nproj)
      y_rep[n, k] = lognormal_rng(log(z[n, k]), sigma[k]);
  }
}
