---
title: 'MC1: Explore relationships between Articles'
author: 'Ng Yen Ngee'
date: '2021-07-20'
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
In this post, I will be running through part 2b of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html) which answers this question: What are the relationships between the primary and derivative sources? 

The final analysis done can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/#1b-relationshipsprimary-vs-derivative-sources).


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

words_by_articles
```

```
## # A tibble: 26,679 x 3
##    source                word           n
##    <chr>                 <chr>      <int>
##  1 The Abila Post        gastech       88
##  2 The Light of Truth    gastech       65
##  3 The Tulip             gastech       65
##  4 The General Post      gastech       64
##  5 Kronos Star           police        63
##  6 News Online Today     gastech       60
##  7 The Abila Post        government    59
##  8 Homeland Illumination gastech       57
##  9 Kronos Star           gastech       56
## 10 News Online Today     government    56
## # ... with 26,669 more rows
```

```r
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
articles_cors%>% 
  arrange(desc(correlation)) %>%
  rowid_to_column('sort') %>%
  ggplot(aes(sort, correlation)) +
  geom_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_viz-1.png" width="672" />

```r
articles_cors %>%
  filter(correlation > .65) %>%
  graph_from_data_frame() %>%
  ggraph(layout='fr') + 
  geom_edge_link(aes(alpha = correlation) , width = 1.5) + #alpha gives the shade
  geom_node_point(size=6, color="lightblue") +
  geom_node_text(aes(label=name), color="red", repel=TRUE) + 
  theme_void()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_viz-2.png" width="672" />

## ngrams
We look at words as consecutive terms. 


```r
bigrams <- cleaned_text %>%
  unnest_tokens(bigram, text, token = "ngrams", n=2)

bigrams_sep <- bigrams %>% 
  filter(bigram != 'NA') %>%
  separate(bigram, c("word1", "word2"), sep=" ")

bigrams_filtered <- bigrams_sep %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2%in% stop_words$word)%>%
  mutate(word = paste(word1, word2, sep=" "))

bigram_counts <- bigrams_filtered  %>%
  count(word, sort=TRUE) %>%
  filter(n>3)
bigram_counts
```

```
## # A tibble: 1,289 x 2
##    word                      n
##    <chr>                 <int>
##  1 sten sanjorge           184
##  2 sanjorge jr             177
##  3 police force            160
##  4 elian karel             127
##  5 gastech international   109
##  6 gastech kronos           77
##  7 ceo sten                 65
##  8 gastech employees        63
##  9 juliana vann             62
## 10 kronos pok               62
## # ... with 1,279 more rows
```

```r
bigrams_by_articles <- bigrams_filtered %>% 
  count(source, word, sort=TRUE) %>% 
  ungroup()

bigrams_by_articles
```

```
## # A tibble: 17,928 x 3
##    source                word                      n
##    <chr>                 <chr>                 <int>
##  1 Homeland Illumination jan 2014                 37
##  2 The Truth             police force             34
##  3 Worldwise             police force             34
##  4 Homeland Illumination 20 jan                   31
##  5 The Light of Truth    sanjorge jr              23
##  6 The Tulip             sanjorge jr              23
##  7 The World             gastech international    22
##  8 The Wrap              police force             21
##  9 The Orb               police force             20
## 10 The World             sanjorge jr              20
## # ... with 17,918 more rows
```

```r
articles_cors <- bigrams_by_articles %>%
  pairwise_cor(source, word,n,sort=TRUE)

articles_cors
```

```
## # A tibble: 812 x 3
##    item1               item2               correlation
##    <chr>               <chr>                     <dbl>
##  1 Who What News       The World                 0.901
##  2 The World           Who What News             0.901
##  3 International News  Kronos Star               0.763
##  4 Kronos Star         International News        0.763
##  5 Central Bulletin    The Abila Post            0.750
##  6 The Abila Post      Central Bulletin          0.750
##  7 The General Post    The Light of Truth        0.747
##  8 The Light of Truth  The General Post          0.747
##  9 World Source        International Times       0.709
## 10 International Times World Source              0.709
## # ... with 802 more rows
```

```r
articles_cors%>% 
  arrange(desc(correlation)) %>%
  rowid_to_column('sort') %>%
  ggplot(aes(sort, correlation)) +
  geom_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/bigram_viz-1.png" width="672" />

```r
articles_cors %>%
  filter(correlation > .35) %>%
  graph_from_data_frame() %>%
  ggraph(layout='fr') + 
  geom_edge_link(aes(alpha = correlation) , width = 1.5) + #alpha gives the shade
  geom_node_point(size=6, color="lightblue") +
  geom_node_text(aes(label=name), color="red", repel=TRUE) + 
  theme_void()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/bigram_viz-2.png" width="672" />
