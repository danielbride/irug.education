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
library(lubridate)


# We'll download some air quality data and explore it.
# In the function below, we tell R where to find the file we want [url = ...]
# and then we tell R where to save that file [destfile = ...]. Since we're working
# inside an RStudio project (folder), we don't have to say 
# destfile = "C:/Users/auser/Desktop/some-folder/big long name/aq-2020.zip"
download.file(url = "https://aqs.epa.gov/aqsweb/airdata/daily_aqi_by_county_2020.zip",
              destfile = "data/aq-2020.zip")

# Oops, that folder doesn't exist yet. Let's create it:
dir.create("data")

# And try again:
download.file(url = "https://aqs.epa.gov/aqsweb/airdata/daily_aqi_by_county_2020.zip",
              destfile = "data/aq-2020.zip")

# I'll throw in 2019 too:
download.file(url = "https://aqs.epa.gov/aqsweb/airdata/daily_aqi_by_county_2019.zip",
              destfile = "data/aq-2019.zip")

# And we can easily find the file we downloaded when we need it:
file.exists("data/aq-2020.zip")

# Our data is on our computer. 
# ¿How do we open it? We use the can opener on R's Swiss Army knife. 
# It's called the readr package, and it includes the read_csv() function below:
aq_2019 <- read_csv(file = "data/aq-2019.zip")

# To keep things a bit tidier, I want to change the names of the columns slightly
# and I'd like to do this in the same step as importing the data. So:
aq_2019 <- read_csv(file = "data/aq-2019.zip") %>% 
  rename_all(str_replace_all, pattern = " ", replacement = ".")

# Then let's do the same thing for 2020 data:
aq_2020 <- read_csv(file = "data/aq-2020.zip") %>% 
  rename_all(str_replace_all, pattern = " ", replacement = ".")

# Now let's combine those datasets. Since they have the same columns, we can do this:
aq <- bind_rows(aq_2019, aq_2020)

# Let's look more closely at our data.
summarize(.data = aq, 
          missing_states = any(is.na(State.Name)),
          missing_counties = any(is.na(county.Name)),
          mean_aqi = mean(AQI))

aq %>% 
  filter(State.Name == "Utah") %>% 
  group_by(county.Name) %>% 
  summarize(mean = mean(AQI)) %>% 
  arrange(desc(mean))

#Other functions that could be useful within summary():
# median()
# sd()
# sum()

is.na(aq$State.Name)

summarize_all(.tbl = aq,
              ~any(is.na(.)))


# Objective: narrow the data down to just Utah ----------------------------
ut_aq <- filter(.data = aq, State.Name == "Utah")

ggplot(data = aq, mapping = aes(x = Date, y = AQI)) +
  geom_point()

# That's a blotchy mess, so let's try again
ggplot(data = aq, mapping = aes(x = Date, y = AQI)) +
  geom_point(alpha = 0.3)

# Maybe a little better. It's a pain to keep typing all that, so let's save the first part and just add to it later:
base_plot_aqi <- ggplot(aq, mapping = aes(x = Date, y = AQI))

base_plot_aqi +
  geom_point(mapping = aes(color = Defining.Parameter), alpha = 0.3)

# So maybe we want to filtr down to just PM2.5
fun_plot_aqi <- aq %>% 
  filter(str_detect(string = State.Name, pattern = "Utah"), 
         str_detect(string = Defining.Parameter, pattern = "PM2.5")) %>% 
  ggplot(mapping = aes(x = mday(Date), y = AQI)) +
  geom_point(mapping = aes(color = county.Name))


fun_plot_aqi


# Objective: animate the AQI over time ------------------------------------
#There's a package for that:
library(gganimate)

# It works as an extension to the ggplot2 package. You just add special layers
# that allow particular ways of animating your data.
animated <- fun_plot_aqi +
  transition_states(paste(month(Date, label = TRUE),
                          year(Date))) +
  ggtitle("{closest_state}")

animate(animated)

# Fun, but not useful. We can do better. Here's the result of LOTS of experimentation
# and trial and error:
aqi_daily_2019 <- aq %>% 
  filter(str_detect(string = State.Name, pattern = "Utah"),
         str_detect(string = Defining.Parameter, pattern = "PM2.5"),
         year(Date) == 2019) %>% 
  mutate(county.Name = fct_reorder(.f = county.Name, .x = AQI, 
                                   .fun = mean, .desc = TRUE),
         bg_xmin = min(Date), bg_xmax = max(Date),
         bg_ymin = 0, bg_ymax = max(AQI) + 5,
         aq_label = str_glue("AQI: {round(AQI, 2)} ({Category})")) %>% 
  group_by(county.Name) %>% 
  filter(n() > 30) %>% ungroup()

aqi_breaks <- c(0, 50, 100, 200, 300)
scaled_aqi_breaks <- scales::rescale(x = aqi_breaks)

aqi_colors = c("#5DC863FF",
               "#FDE725FF",
               "#ED6925FF", 
               "#D64B40FF", 
               "#440154FF")

ani_2019 <- aqi_daily_2019 %>% 
  ggplot() +
  geom_line(mapping = aes(x = Date, y = AQI)) +
  geom_point(mapping = aes(x = Date, y = AQI, group = Date, color = AQI), size = 0.9) +
  geom_label(mapping = aes(x = Date + 1, y = AQI, 
                           label = aq_label, 
                           group = county.Name), hjust = 0) +
  geom_text(mapping = aes(x = max(Date) + 3, y = 75, label = county.Name),
            hjust = 0.85, vjust = -0.65) +
  facet_grid(rows = vars(county.Name), scales = "free_y") +
  ggtitle("Air Quality Index by County", "AQI on {format(as.Date(frame_along, origin = lubridate::origin), format = '%b %d')}") +
  scale_color_gradientn(name = "AQI Categories", colors = aqi_colors,
                        labels = c("Good", "Moderate", "Unhealthy For\nSensitive Groups",
                                   "Unhealthy", "Very Unhealthy"),
                        values = scaled_aqi_breaks, 
                        guide = guide_legend(direction = "horizontal", nrow = 2,
                                             title.position = "top",
                                             size = 10),
                        breaks = c(0, 50, 100, 200, 300),
                        limits = c(-1, 500)) +
  scale_y_continuous(position = "right") +
  labs(x = NULL, y = NULL) +
  coord_cartesian(ylim = c(0, 200), clip = "off") +
  theme_bw() +
  theme(strip.background = element_blank(), strip.text = element_blank(),
        legend.position = "top", plot.margin = margin(10, 50, 10, 50),
        legend.text = element_text(color = "darkgrey", size = rel(0.75)), 
        legend.background = element_rect(fill = "ivory")) +
  transition_reveal(along = Date)

# It will take a little while to create all the frames and put them together:
animate(ani_2019, res = 144, width = 600, height = 750)

# Could use some polish, but kinda fun and hopefully gets you thinking about 
# what you could do.

# Inspiration:
# https://gganimate.com/ - main package website
# https://goodekat.github.io/presentations/2019-isugg-gganimate-spooky/
#   - really excellent walkthrough/demo
# https://slides.mitchelloharawild.com/wombat-gganimate
