set.seed(123)

library(plumber2)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(timeDate)
library(jsonlite)



#load in any data
training <- read_csv("train_dataset.csv.gz")


#Make new data variables
training_new <- training %>% 
  mutate(day_of_week = wday(appt_time, label = TRUE),
         time = format(appt_time, "%H:%M:%S"),
         weekend = ifelse(day_of_week == "Sun" | day_of_week == "Sat", 1, 0),
         minor = ifelse(age < 18, 1, 0),
         senior = ifelse(age >= 65, 1, 0),
         difftime_appt = as.numeric(difftime(appt_time, appt_made, 
                                             units = "days")))
training_new <- training_new %>%
  mutate(across(
    c(id, provider_id, address, specialty, weekend, minor, senior, no_show),
    as.factor
  ))



#Make Logistic Model
library(caret)
#Cross validation
train_control <- trainControl(method = "cv", number = 5)

#train model
model <- train(as.formula(no_show ~ provider_id + address + age + specialty + 
                            time + weekend + minor + senior + difftime_appt),
               data = training_new,
               method = "glm",
               family = binomial,
               trControl = train_control)


#* @get /predict_prob/<input>
#* @serializer json
function(input){
  input <- URLdecode(input)
  input <- read_csv(I(input))
  
  input <- input %>% 
    mutate(day_of_week = wday(appt_time, label = TRUE),
           time = format(appt_time, "%H:%M:%S"),
           weekend = ifelse(day_of_week %in% c("Sun","Sat"), 1, 0),
           minor = ifelse(age < 18, 1, 0),
           senior = ifelse(age >= 65, 1, 0),
           difftime_appt = as.numeric(difftime(appt_time, appt_made, units = "days")),
           date = as.Date(appt_time)
    )
  
  input <- input %>%
    mutate(across(
      c(id, provider_id, address, specialty, weekend, minor, senior),
      as.factor
    ))
  
  return(pull(predict(model, input, type = 'prob'), "1"))
}

#* @get /predict_binary/<input>
#* @serializer json
function(input){
  input <- URLdecode(input)
  input <- read_csv(I(input))
  
  input <- input %>% 
    mutate(day_of_week = wday(appt_time, label = TRUE),
           time = format(appt_time, "%H:%M:%S"),
           weekend = ifelse(day_of_week %in% c("Sun","Sat"), 1, 0),
           minor = ifelse(age < 18, 1, 0),
           senior = ifelse(age >= 65, 1, 0),
           difftime_appt = as.numeric(difftime(appt_time, appt_made, units = "days")),
           date = as.Date(appt_time)
    )
  
  input <- input %>%
    mutate(across(
      c(id, provider_id, address, specialty, weekend, minor, senior),
      as.factor
    ))
  
  return(as.numeric(predict(model, input, type = 'raw'))-1)
}