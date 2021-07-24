---
title: 'MC1: Who is bias to whom?'
author: 'Ng Yen Ngee'
date: '2021-07-19'
lastmod: '2021-07-25'
slug: []
cover: "/img/bias.jpg"
categories: []
tags: ['MITB', 'Text Analytics', "MC1"]
output:
  blogdown::html_page: 
    toc: true
---



# Introduction 
In this post, I will be running through the thought process figuring out the biasness of the news article sources from [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html)

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
library(wordcloud)
library(tidygraph)
library(igraph)      
library(ggraph)
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

## Analysis 
### Frequency 
We want to pick out certain words and see for each articles mentions it the highest. 


```r
token_words %>%
  filter(word == "pok") %>%
  group_by(source) %>% 
  summarize(n = n()) %>%
  ungroup() %>% 
  mutate(source=fct_reorder(source,n)) %>%
  ggplot(aes(x=source, y = n)) +
  geom_bar(stat='identity') + 
  coord_flip()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_pok-1.png" width="672" />
We see Kronos Star mention pok the most, while Centrum Sentinel mentions the least. 

Let's see similar graph but including other words. 



```r
freq_of_org <- token_words %>%
  filter(word %in% c("pok", "government", "gastech")) %>%
  group_by(source) %>% 
  summarize(total = n()) %>%
  ungroup()

perc_of_org <- token_words %>%
  filter(word %in% c("pok", "government", "gastech")) %>%
  group_by(source, word) %>% 
  summarize(n = n()) %>%
  ungroup() %>% 
  left_join(freq_of_org) %>% 
  mutate(perc = n/total, 
         source=fct_reorder(source,perc))

perc_of_org %>%
  ggplot(aes(x=source, y = n, fill=word)) +
  geom_bar(stat='identity') + 
  coord_flip() +
  facet_wrap(~word)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org-1.png" width="672" />

```r
perc_of_org %>%
  ggplot(aes(x=source, y = perc, fill=word)) +
  geom_bar(stat='identity') + 
  coord_flip() +
  facet_wrap(~word)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org-2.png" width="672" />

### words association


```r
pok_words <- token_words %>%
  filter(word %in% c("pok"))

pok_count_words <- token_words %>% 
  filter(article_id %in% unique(pok_words$article_id) & !word == "pok") %>% 
  count(word, sort=TRUE) %>%
  mutate(word = fct_reorder(word, n))

pok_count_words %>%
  top_n(15) %>%
  ggplot(aes(x= word, y=n)) + 
  geom_col() +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/words_associated_with_pok-1.png" width="672" />

```r
wordcloud(words = pok_count_words$word, 
          freq = pok_count_words$n, 
          max.words = 100)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/words_associated_with_pok-2.png" width="672" />

```r
pok_words <- token_words %>%
  filter(word %in% c("pok", 'government', 'gastech'))

pok_count_words <- token_words %>% 
  filter(article_id %in% unique(pok_words$article_id)) %>% 
  count(word, sort=TRUE) %>%
  arrange(desc(n))

pok_count_words
```

```
## # A tibble: 5,922 x 2
##    word              n
##    <chr>         <int>
##  1 gastech        1179
##  2 government      830
##  3 pok             566
##  4 police          516
##  5 gas             401
##  6 sanjorge        353
##  7 international   344
##  8 people          337
##  9 karel           300
## 10 elodis          291
## # ... with 5,912 more rows
```

### sentinent analysis 


```r
token_sentiments <- token_words %>% 
  left_join(get_sentiments("bing"))

sentiment_by_grp <- token_sentiments %>%
  filter(sentiment %in% c("positive", "negative") & article_id %in% unique(pok_words$article_id)) %>%
  count(source, sentiment) %>%
  spread(sentiment,n) %>% 
  mutate(overall_sentiment = positive-negative, 
         source = fct_reorder(source, overall_sentiment))

sentiment_by_grp %>% 
  ggplot(aes(x = source, y = overall_sentiment, fill = as.factor(source))) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Overall Sentiment by Article with articles that contains POK",
    subtitle = "Words in articles",
    x = "Article",
    y = "Overall Sentiment"
    )
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/add_sentiment-1.png" width="672" />

### Network Analysis 
Let's try this. 
The source nodes are news article source and the target nodes are the words. 


```r
# creating nodes df
source_tibble <- as_tibble(unique(token_words$source), column_name = "label") %>% 
  mutate(type = 'news article')%>% 
  rename('label' = 'value')
word_tibble <- as_tibble(unique(token_words$word)) %>% 
  mutate(type = 'word') %>% 
  rename('label' = 'value')
article_nodes <- source_tibble %>% 
  bind_rows(word_tibble) %>% 
  rowid_to_column("id")

# create edges df
article_edges <- token_sentiments %>%
  rename(target_label = word, source_label = source) %>%
  left_join(article_nodes %>% select(label, id), by = c("source_label" = "label")) %>% 
  rename(source = id) %>%
  left_join(article_nodes %>% select(label, id), by = c("target_label" = "label")) %>% 
  rename(target = id) 

article_edges_agg <- article_edges %>% 
  group_by(source, target, source_label, target_label) %>%
  summarize(weight = n()) %>%
  ungroup() %>% 
  filter(weight > 20)

article_graph <- tbl_graph(nodes = article_nodes, 
                          edges = article_edges_agg, 
                          directed = TRUE)

article_edges_agg %>%
  arrange(desc(weight))
```

```
## # A tibble: 148 x 5
##    source target source_label          target_label weight
##     <int>  <int> <chr>                 <chr>         <int>
##  1     15     43 The Abila Post        gastech          88
##  2     20     43 The Light of Truth    gastech          65
##  3     23     43 The Tulip             gastech          65
##  4     18     43 The General Post      gastech          64
##  5     10     37 Kronos Star           police           63
##  6     13     43 News Online Today     gastech          60
##  7     15     83 The Abila Post        government       59
##  8      7     43 Homeland Illumination gastech          57
##  9     10     43 Kronos Star           gastech          56
## 10     13     83 News Online Today     government       56
## # ... with 138 more rows
```



```r
ggraph(article_graph) + 
  geom_edge_link() +
  geom_node_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/network-1.png" width="672" />
