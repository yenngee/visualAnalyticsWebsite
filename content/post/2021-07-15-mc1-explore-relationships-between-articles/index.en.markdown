---
title: 'MC1: Explore relationships between Articles'
author: 'Ng Yen Ngee'
date: '2021-07-21'
lastmod: '2021-07-25'
slug: []
cover: "/img/explore_relationships.png"
categories: []
tags: ['MITB', "MC1", 'Text Analytics']
output:
  blogdown::html_page: 
    toc: true
---



# Introduction 
In this post, I will be running through the exploration of relationships between the articles for completing [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). The analysis done after preparing the data can be found [here](https://vast-challenge.github.io/2021/MC1.html). 

The final analysis done can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/).


## Preperation 

### Import packages 


```r
library(tidyverse)
library(tidytext)
library(ggraph)
library(igraph)
library(widyr)
```

### Load Data 
The data has been previously loaded, cleaned and transformed into a neat tibble dataframe [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/). 
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
The process of the tokenizing the data is written in detail [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/#tokenising). This is how the `token_words` look like. 




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


```r
articles_cors %>%
  filter(correlation > .7) %>%
  graph_from_data_frame() %>%
  ggraph(layout='fr') + 
  geom_edge_link(aes(alpha = correlation, width = correlation)) + #alpha gives the shade
  geom_node_point(size=6, color="lightblue") +
  geom_node_text(aes(label=name), color="red", repel=TRUE) + 
  theme_void()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_viz-1.png" width="672" />

## ngrams
We look at words as consecutive terms. 


```r
# bigram_counts <- bigrams_filtered  %>%
#   count(word, sort=TRUE) %>%
#   filter(n>3) 
# bigram_counts
# 
# bigram_counts %>%
#   graph_from_data_frame() %>%
#   ggraph(layout='fr') +
#   geom_edge_link() +
#   geom_node_point() +
#   geom_node_text(aes(label=name), vjust=1, hjust=1) +
#   theme_void()
# 
# a <- grid::arrow(type="closed",
#                  length=unit(.15, "inches"))
# bigram_counts %>%
#   graph_from_data_frame() %>%
#   ggraph(layout='fr') +
#   geom_edge_link( #aes(edge_alpha = n),
#                  show.legend = FALSE,
#                  arrow = a,
#                  end_cap = circle(.07, 'inches')
#                  ) +
#   geom_node_point(color = "lightblue",
#                   size=5) +
#   geom_node_text(aes(label=name), vjust=1, hjust=1) +
#   theme_void()
```
