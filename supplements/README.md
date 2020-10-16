# Bottom-up population estimates - Scripts

This folder contains scripts and model outputs intented at estimating the population in areas not covered by Burkina Faso 2019 census.

The modelling approach is a hierarchical Bayesian model estimated using the Stan software:
- `1. model_final.stan` is the stan description of the final model
- `1. model_testing.stan`is the stan description of the model used for testing purpose, ie training the model on 70% of the data and predicting on 30% of the data
- `2. run.R` is the R script that calls stan model for execution.

The folder `traceplots.zip` contains estimated distributions for every parameter also known as trace plots. Covariate effects are also included.
