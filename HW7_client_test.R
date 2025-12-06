library(httr)
library(jsonlite)
library(tidyverse)

test_data <- read_csv("test_dataset.csv.gz")
test_data <- head(test_data, 20)
csv_string <- format_csv(test_data)
base_location <- "http://127.0.0.1:8080/"


# Probabilities
url_string1 <- paste0(base_location, "predict_prob/", URLencode(csv_string))
res_prob <- GET(url_string1)
fromJSON(content(res_prob, "text"))

# Binary
url_string2 <- paste0(base_location, "predict_binary/", URLencode(csv_string))
res_binary <- GET(url_string2)
fromJSON(content(res_binary, "text"))