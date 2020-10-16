

data {
  int<lower=0> n_train; // number of EAs
  int<lower=0> n_test; // number of EAs
  
  int<lower=0> people_train[n_train];
  
  vector<lower=0>[n_train] area_train; // settled area per EA

  int<lower=0> n_settlement; 
  int<lower=1,upper=n_settlement> settlement_train[n_train];
  int<lower=1,upper=n_settlement> settlement_test[n_test];


  int<lower=0> n_admin1; 
  int<lower=1, upper=n_settlement> admin1_lookup[n_admin1];

  int<lower=0> n_admin3; 
  int<lower=1,upper=n_admin3> admin3_train[n_train];
  int<lower=1,upper=n_admin3> admin3_test[n_test];
  int<lower=1, upper=n_admin1> admin3_lookup[n_admin3];
  
  int<lower=0> n_cov; 
  matrix[n_train, n_cov] cov_train;
  matrix[n_test, n_cov] cov_test;

}

parameters {
 vector<lower=0>[n_train] density_train;
 
 // national effect
 real<lower=0> alpha_national;
 real<lower=0> sigma_national;
 
  // settlement effect
 vector<lower=0>[n_settlement] u_alpha_settlement;
 real<lower=0> s_alpha_settlement;
 vector<lower=0>[n_settlement] u_sigma_settlement;
 real<lower=0> s_sigma_settlement;
 
 // admin1 effect
 vector<lower=0>[n_admin1] u_alpha_admin1;
 real<lower=0> s_alpha_admin1;
 vector<lower=0>[n_admin1] u_sigma_admin1;
 real<lower=0> s_sigma_admin1;
 
  // admin3 effect
 vector<lower=0>[n_admin3] u_alpha_admin3;
 real<lower=0> s_alpha_admin3;
 vector<lower=0>[n_admin3] u_sigma_admin3;
 real<lower=0> s_sigma_admin3;
 
 

 // rcovariates random effect
 vector[n_cov] beta_fixed;
 
}

transformed parameters {
  
  vector<lower=0>[n_settlement] alpha_settlement;
  vector<lower=0>[n_settlement] sigma_settlement;
  
  vector<lower=0>[n_admin1] alpha_admin1;
  vector<lower=0>[n_admin1] sigma_admin1;
  
  vector<lower=0>[n_admin3] alpha_admin3;
  vector<lower=0>[n_admin3] sigma_admin3;
  
  vector[n_train] mu;
  

  alpha_settlement = alpha_national + u_alpha_settlement*s_alpha_settlement;
  alpha_admin1 = alpha_settlement[admin1_lookup] + u_alpha_admin1*s_alpha_admin1;
  alpha_admin3 = alpha_admin1[admin3_lookup] + u_alpha_admin3*s_alpha_admin3;

  sigma_settlement = sigma_national + u_sigma_settlement*s_sigma_settlement;
  sigma_admin1 = sigma_settlement[admin1_lookup] + u_sigma_admin1*s_sigma_admin1;
  sigma_admin3 = sigma_admin1[admin3_lookup] + u_sigma_admin3*s_sigma_admin3;
  
  mu = cov_train * beta_fixed;

}

model {
  
  alpha_national ~ normal(11,3);
  sigma_national ~ normal(0,1);
  
  u_alpha_settlement ~ normal(0,1);
  s_alpha_settlement ~ normal(0,1);
  
  u_sigma_settlement ~ normal(0,1);
  s_sigma_settlement ~ normal(0,1);
    
  u_alpha_admin1 ~ normal(0,1);
  s_alpha_admin1 ~ normal(0,1);
  
  u_sigma_admin1 ~ normal(0,1);
  s_sigma_admin1 ~ normal(0,1);
  
  u_alpha_admin3 ~ normal(0,1);
  s_alpha_admin3 ~ normal(0,1);
  
  u_sigma_admin3 ~ normal(0,1);
  s_sigma_admin3 ~ normal(0,1);
  
  beta_fixed ~ normal(0,1);

  density_train ~ lognormal(alpha_admin3[admin3_train] + mu, sigma_admin3[admin3_train]);
  people_train ~ poisson(density_train .* area_train);
}

// Compute predicted density

generated quantities {
  real<lower=0> density_hat[n_test];
  vector[n_test] mu_test;

  mu_test = cov_test * beta_fixed;
  density_hat = lognormal_rng(alpha_admin3[admin3_test] + mu_test, sigma_admin3[admin3_test]);

}
