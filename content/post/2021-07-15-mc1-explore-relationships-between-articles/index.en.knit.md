---
title: 'MC1: Explore relationships between Articles'
author: 'Ng Yen Ngee'
date: '2021-07-15'
lastmod: '2021-07-15'
slug: []
cover: "/img/explore_relationships.png"
categories: []
tags: ['MITB', 'Text Analytics', "Kronos Kidnapping"]
output:
  blogdown::html_page: 
    toc: true
---



# Introduction 
In this post, I will be running through the Data Preparation for completing [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). The analysis done after preparing the data can be found [here](). 

## Preperation 
## Import packages 


```r
library(tidyverse)
library(tidytext)
library(widyr)
```

## Load Data 

```r
token_words <- read_rds("data/news_article_token_words.rds")
token_bigrams <- read_rds("data/news_article_bigrams.rds")
```

## Explore relationships 

### "Correlations" between articles
we want to know which newsgroup is more similar based on the words they use. 


```r
words_by_articles <- token_words %>% 
  count(source, word, sort=TRUE) %>% 
  ungroup()

articles_cors <- words_by_articles %>%
  pairwise_cor(source, word,n,sort=TRUE)

articles_cors
```

```
## # A tibble: 812 x 3
##    item1              item2              correlation
##    <chr>              <chr>                    <dbl>
##  1 The World          Who What News            0.941
##  2 Who What News      The World                0.941
##  3 The General Post   The Light of Truth       0.919
##  4 The Light of Truth The General Post         0.919
##  5 The World          The Light of Truth       0.912
##  6 The Light of Truth The World                0.912
##  7 The World          The General Post         0.909
##  8 The General Post   The World                0.909
##  9 The General Post   The Tulip                0.903
## 10 The Tulip          The General Post         0.903
## # ... with 802 more rows
```




