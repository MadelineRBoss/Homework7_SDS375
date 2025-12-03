## Run API end point

library(plumber2)

## Run the API server using api() and api_run()
pa <- api("HW7_api_endpoint.R", port = 8080)
srv <- api_run(pa, background = TRUE)