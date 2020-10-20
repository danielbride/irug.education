# Before you write any code:
# ¿Where are we? (Where on the computer are we?)
#   - We'll care about this when we can't find anything!
getwd()

# Try to find something:
file.exists("data")

# You don't want to continually type out things like this:
#   "C:/Users/auser/projects/data/final_data_finally.data"

# So, PUT YOUR WORK IN A BOX - an RStudio project
file.exists("data")

# If all you have is a hammer, everything looks like a nail.
# R has a package system that makes it more like a Swiss Army knife.
# We'll start with a collection of packages called the tidyverse:
library(tidyverse)


# We'll download some air quality data and explore it.
# In the function below, we tell R where to find the file we want [url = ...]
# and then we tell R where to save that file [destfile = ...]. Since we're working
# inside an RStudio project (folder), we don't have to say 
# destfile = "C:/Users/auser/Desktop/some-folder/big long name/aq-2020.zip"
download.file(url = "https://aqs.epa.gov/aqsweb/airdata/daily_aqi_by_county_2020.zip",
              destfile = "data/aq-2020.zip")

# And we can easily find the file we downloaded when we need it:
file.exists("data/aq-2020.zip")

# Our data is on our computer. 
# ¿How do we open it? We use the can opener on R's Swiss Army knife. 
# It's called the readr package, and it includes the read_csv() function below:
aq <- read_csv(file = "data/aq-2020.zip")

aq <- read_csv(file = "data/aq-2020.zip") %>% 
  rename_all(str_replace_all, pattern = " ", replacement = ".")
  
# Let's look more closely at our data.


# Objective: narrow the data down to just Utah ----------------------------


# Objective: visualize AQI across the year --------------------------------



# Maybe just vizualize PM2.5 ----------------------------------------------


# Objective: animate the AQI over time ------------------------------------

library(gganimate)



