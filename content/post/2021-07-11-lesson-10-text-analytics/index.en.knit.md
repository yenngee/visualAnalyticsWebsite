---
title: "Lesson 10 Text Analytics"
author: "Ng Yen Ngee"
date: '2021-07-11'
slug: []
cover: "/img/text_analytics2.jpg"
categories: []
tags: ["R", 'Text Analytics', "MITB"]
output:
  blogdown::html_page: 
    toc: true

---




# Introduction to in-class exercise 10
As part of my lesson in SMU Visual Analytics, prof teaches data visualization in R using Rmarkdown. The post below acts as both an in-class exercise for the lesson, as well as my notes. 

Note to prof, if he is here: I have reorganized the in class exercise in a way that makes sense to me, but may not follow the step by step process prof went through in class. I have added additional items which I have kept as haphazard notes on my desktop.  Hope this is alright! 


## Preperation 

### Loading packages

Our very first step of course is to load the packages that would be useful for us. 


```r
library(tidyverse)
library(tidytext)
library(widyr)
library(wordcloud)
library(ggwordcloud)
library(textdata)
library(textplot)
library(DT)
library(tidygraph)
library(ggraph)
library(igraph)
#time
library(lubridate)
library(hms)
```

### Load data 


```r
news20 <- "data/20news/"

read_folder <- function(infolder) {
  tibble(file=dir(infolder, 
                  full.names=TRUE)) %>% 
    mutate(text = map(file, read_lines)) %>%
    transmute(id = basename(file), text) %>%
    unnest(text)
}

#how the function works 
news20_df <- read_folder("data/20news/alt.atheism")
glimpse(news20_df)
```

```
## Rows: 0
## Columns: 2
## $ id   <chr> 
## $ text <???>
```













