library(tidyverse)

ggplot(mtcars) +
  geom_point(aes(x = mpg, y = cyl))