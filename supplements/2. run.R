
rm(list=ls())
gc()
cat("\014") 
try(dev.off())

# 1. Set up ---------------------------------------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(doParallel, dplyr,  tictoc, 
               data.table,rstan, shinystan
               )


options(mc.cores = parallel::detectCores()-2)
rstan::rstan_options(auto_write = TRUE)


data <- readRDS(paste0(working_path, "DataIn/data.rds"))
variante <- "final"

set.seed(data$seed)

# Initialize parameters value for the simulation 
createInits <- function(n_chains, data){
    # empty list for initials for all chains
  inits.out <- list()
    # get parameter initials for each mcmc chain
  for (c in 1:n_chains){
        # empty list for initials for one chain
    inits.i <- list()
        # lognormal 
    inits.i$alpha_national <- runif(1, 9, 13)
        # add inits for this chain to init list
    inits.out[[c]] <- inits.i
  }
  return(inits.out)
}

inits <- createInits(3, data)

# Set parameters to monitor


if(variante == "testing") {
  monitor <- c("density_hat", "beta_fixed", 
               "alpha_admin3", "sigma_admin3",
               "alpha_admin1", "sigma_admin1",
               "alpha_national", "sigma_national",
               "alpha_settlement", "sigma_settlement")
  
}

if(variante == "final") {
  monitor <- c("alpha_admin3", "sigma_admin3","alpha_admin1", "sigma_admin1", "beta_fixed",
               "alpha_national", "sigma_national",
               "alpha_settlement", "sigma_settlement")
}

# 2. Run ------------------------------------------------------------------
tic()

fit_md <- rstan::stan(file = paste0('1. model_', variante, '.stan'), 
                      model_name = paste0("model ", variante),
                      data = data,
                      iter = 3000,
                      warmup = 1000,
                      init = inits,
                      pars = monitor,
                      seed = data$seed,
                      save_warmup = FALSE,
                      chains = 3,
                      control = list(max_treedepth = 15,adapt_delta = 0.99)
)
toc(log=T)
fit <- list()
fit$variante <- variante
fit$inits <- inits
fit$fit_md <- fit_md
fit$data <- data
fit$time <- tic.log()[[length(tic.log())]]

saveRDS(fit, paste0(working_path, "/model_", variante, "_fit.rds"))



# Bayesian Check ----------------------------------------------------------
check_treedepth(fit_md)
check_energy(fit_md)
check_div(fit_md)
