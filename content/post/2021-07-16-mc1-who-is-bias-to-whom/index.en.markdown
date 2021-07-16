---
title: 'MC1: Who is bias to whom?'
author: 'Ng Yen Ngee'
date: '2021-07-16'
lastmod: '2021-07-16'
slug: []
cover: "/img/bias.jpg"
categories: []
tags: ['MITB', 'Text Analytics', "MC1"]
output:
  blogdown::html_page: 
    toc: true
---



# Introduction 
In this post, I will be running through the thought process of answering Q1 of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html):  
Which are primary sources and which are derivative sources? What are the relationships between the primary and derivative sources? 

The final analysis done can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/).

## Preperation 
### Load Packages 
These are the packages used for this post. 

```r
library(tidyverse)
library(tidytext)
library(stringr)
library(gridExtra)
library(lubridate)
```

### Load Data 
The data has been previously loaded, cleaned and transformed into a neat tibble dataframe here. 
We load the cleaned data directly below: 


```r
cleaned_text <- read_rds("data/news_article_clean.rds")
cleaned_text <- cleaned_text %>%
  mutate(title = tolower(title))
glimpse(cleaned_text)
```

```
## Rows: 845
## Columns: 7
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ article_id     <chr> "All News Today_121", "All News Today_135", "All News T~
## $ text           <chr> "  fifteen members of the protectors of kronos (pok) ac~
## $ title          <chr> "pok protests end in arrests", "rally scheduled in supp~
## $ location       <chr> "elodis, kronos", "abila, kronos", "abila, kronos", "el~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
## $ published_date <date> 2005-04-06, 2012-04-09, 1993-02-02, 1998-03-20, 1998-0~
```

### Tokenize Data




```r
glimpse(token_words)
```

```
## Rows: 54,624
## Columns: 7
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ article_id     <chr> "All News Today_121", "All News Today_121", "All News T~
## $ title          <chr> "pok protests end in arrests", "pok protests end in arr~
## $ location       <chr> "elodis, kronos", "elodis, kronos", "elodis, kronos", "~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
## $ published_date <date> 2005-04-06, 2005-04-06, 2005-04-06, 2005-04-06, 2005-0~
## $ word           <chr> "fifteen", "protectors", "pok", "activist", "organizati~
```

