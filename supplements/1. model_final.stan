

data {
  int<lower=0> n; // number of EAs

  int<lower=0> people[n];
  
  vector<lower=0>[n] area; // settled area per EA

  int<lower=0> n_settlement; 
  int<lower=1,upper=n_settlement> settlement[n];

  int<lower=0> n_admin1; 
  int<lower=1, upper=n_settlement> admin1_lookup[n_admin1];

  int<lower=0> n_admin3; 
  int<lower=1,upper=n_admin3> admin3[n];
  int<lower=1, upper=n_admin1> admin3_lookup[n_admin3];
  
  int<lower=0> n_cov; 
  matrix[n, n_cov] cov;

}

parameters {
 vector<lower=0>[n] density;
 
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
  
  vector[n] mu;
  

  alpha_settlement = alpha_national + u_alpha_settlement*s_alpha_settlement;
  alpha_admin1 = alpha_settlement[admin1_lookup] + u_alpha_admin1*s_alpha_admin1;
  alpha_admin3 = alpha_admin1[admin3_lookup] + u_alpha_admin3*s_alpha_admin3;

  sigma_settlement = sigma_national + u_sigma_settlement*s_sigma_settlement;
  sigma_admin1 = sigma_settlement[admin1_lookup] + u_sigma_admin1*s_sigma_admin1;
  sigma_admin3 = sigma_admin1[admin3_lookup] + u_sigma_admin3*s_sigma_admin3;
  
  mu = cov * beta_fixed;

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

  density ~ lognormal(alpha_admin3[admin3] + mu, sigma_admin3[admin3]);
  people ~ poisson(density .* area);
}

