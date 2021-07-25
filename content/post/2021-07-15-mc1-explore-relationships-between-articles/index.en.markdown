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

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/vis/vis.css" rel="stylesheet" />

<script src="{{< blogdown/postref >}}index.en_files/vis/vis.min.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/visNetwork-binding/visNetwork.js"></script>

# Introduction

In this post, I will be running through part 2b of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html) which answers this question: What are the relationships between the primary and derivative sources?

The final analysis done can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/#1b-relationshipsprimary-vs-derivative-sources).

## Preperation

### Import packages

``` r
library(tidyverse)
library(tidytext)
library(tidygraph)
library(lubridate)
library(ggraph)
library(igraph)
library(widyr)
library(visNetwork)
```

### Load Data

The data has been previously loaded, cleaned and transformed into a neat tibble dataframe [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/).
We load the cleaned data directly below:

``` r
cleaned_text <- read_rds("data/news_article_clean.rds")
cleaned_text <- cleaned_text %>%
  mutate(title = tolower(title))
glimpse(cleaned_text)
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

### Tokenize Data

The process of the tokenizing the data is written in detail [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/#tokenising). This is how the `token_words` look like.

``` r
glimpse(token_words)
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

## Explore relationships

### “Correlations” between articles

we want to know which newsgroup is more similar based on the words they use. We can find the correlation between articles based on the words they use below:

``` r
words_by_articles <- token_words %>% 
  count(source, word, sort=TRUE) %>% 
  ungroup()

words_by_articles
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

``` r
articles_cors <- words_by_articles %>%
  pairwise_cor(source, word,n,sort=TRUE) %>% 
  distinct(correlation, .keep_all = TRUE)

articles_cors
```

    ## # A tibble: 406 x 3
    ##    item1            item2               correlation
    ##    <chr>            <chr>                     <dbl>
    ##  1 The World        Who What News             0.941
    ##  2 The General Post The Light of Truth        0.919
    ##  3 The World        The Light of Truth        0.912
    ##  4 The World        The General Post          0.909
    ##  5 The General Post The Tulip                 0.903
    ##  6 The Tulip        The Light of Truth        0.900
    ##  7 Who What News    The Light of Truth        0.894
    ##  8 The World        The Tulip                 0.887
    ##  9 Who What News    The General Post          0.887
    ## 10 World Source     International Times       0.880
    ## # ... with 396 more rows

From here each pair of source is assigned a correlation. Many pairs of the articles have quite a high
We see the value correlation in relation to its percentile of the position out of all the combinations possible. From here we can choose a break off point to filter the `article_cors` to show the network graph. The first break is where correlation is approximately 0.85. However this would give a graph that has limited connections. Another spot we can observe is where correlation is approximately 0.65, there is a small break. Churning out the network graph, we can see a reasonable visualization for our analysis.

``` r
articles_cors%>% 
  arrange(desc(correlation)) %>%
  rowid_to_column('sort') %>%
  mutate(rank = percent_rank(correlation)) %>%
  ggplot(aes(rank, correlation)) +
  geom_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_viz-1.png" width="672" />

We get the network graph below. We can see the various groups news articles.

There is one group (GROUP A) with:

  - The Light of Truth
  - The General Post
  - Who What News
  - The Tulip
  - The World

One group (GROUP B) with

  - World Journal
  - Everday News
  - The Continent
  - World Source
  - International Times

One group (GROUP C) with

  - All News Today
  - The Wrap
  - Daily Pegasus
  - The Orb
  - Homeland Illumination

One group (GROUP D) with

  - International News
  - Worldwise
  - The Truth
  - The Guide
  - Krono Stars

One group (Group E) with

  - News Desk
  - The Explainer
  - Athena Speaks
  - Central Bulletin
  - The Abila Post

Then we have News Online Today, that seemed to be reporting similar content across 4 groups.

Then we have some straddlers:

  - Modern Rubicon (slightly similar with Centrum Sentinel)
  - Centrum Sentinel (slightly similar with Modern Rubicon)
  - Tethys News (slightly similar to Kronos Star)

<!-- end list -->

``` r
news_article_groups <- tribble(
  ~source, ~group, ~is_primary,
  "The Light of Truth", "A", 'Derivative', 
  "The General Post",   "A", 'Derivative', 
  "Who What News",      "A", 'Derivative', 
  "The Tulip",          "A", 'Derivative', 
  "The World",          "A", 'Primary', 
  "World Journal",      "B", 'Derivative', 
  "Everyday News",      "B", 'Derivative', 
  "The Continent",      "B", 'Derivative', 
  "World Source",       "B", 'Derivative', 
  "International Times","B", 'Primary', 
  "All News Today",     "C", 'Derivative', 
  "The Wrap",           "C", 'Derivative', 
  "Daily Pegasus",      "C", 'Derivative', 
  "The Orb",            "C", 'Derivative', 
  "Homeland Illumination", "C", 'Primary', 
  "International News", "D", 'Derivative', 
  "Worldwise",          "D", 'Derivative', 
  "The Truth",          "D", 'Derivative', 
  "The Guide",          "D", 'Derivative', 
  "Kronos Star",        "D", 'Derivative', 
  "News Desk",          "E", 'Derivative', 
  "The Explainer",      "E", 'Derivative', 
  "Athena Speaks",      "E", 'Derivative', 
  "Central Bulletin",   "E", 'Derivative', 
  "The Abila Post",     "E", 'Primary', 
  "News Online Today",  "Others", 'Derivative', 
  "Modern Rubicon",     "Others", 'Primary', 
  "Centrum Sentinel",   "Others", 'Primary', 
  "Tethys News",        "Others",  'Derivative'
)

news_article_groups
```

    ## # A tibble: 29 x 3
    ##    source              group is_primary
    ##    <chr>               <chr> <chr>     
    ##  1 The Light of Truth  A     Derivative
    ##  2 The General Post    A     Derivative
    ##  3 Who What News       A     Derivative
    ##  4 The Tulip           A     Derivative
    ##  5 The World           A     Primary   
    ##  6 World Journal       B     Derivative
    ##  7 Everyday News       B     Derivative
    ##  8 The Continent       B     Derivative
    ##  9 World Source        B     Derivative
    ## 10 International Times B     Primary   
    ## # ... with 19 more rows

``` r
articles_cors %>%
  filter(correlation > .65) %>% 
  graph_from_data_frame() %>%
  ggraph(layout='fr') + 
  geom_edge_link(aes(alpha = correlation) , width = 1.5) + #alpha gives the shade
  geom_node_point(size=6, color="lightblue") +
  geom_node_text(aes(label=name), color="red", repel=TRUE) + 
  theme_void()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_network_viz-1.png" width="672" />

### bigram

We repeat the same procedure but looking at look at words as 2 consecutive terms.

``` r
# To get the bigrams 
bigrams_sep <- cleaned_text %>%
  unnest_tokens(bigram, text, token = "ngrams", n=2) %>% 
  filter(bigram != 'NA') %>%
  separate(bigram, c("word1", "word2"), sep=" ")
bigrams_sep
```

    ## # A tibble: 124,549 x 8
    ##    source   article_id   title     location  author published_date word1  word2 
    ##    <chr>    <chr>        <chr>     <chr>     <chr>  <date>         <chr>  <chr> 
    ##  1 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     fifte~ membe~
    ##  2 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     membe~ of    
    ##  3 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     of     the   
    ##  4 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     the    prote~
    ##  5 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     prote~ of    
    ##  6 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     of     kronos
    ##  7 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     kronos pok   
    ##  8 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     pok    activ~
    ##  9 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     activ~ organ~
    ## 10 All New~ All News To~ pok prot~ elodis, ~ <NA>   2005-04-06     organ~ were  
    ## # ... with 124,539 more rows

``` r
# filter out items with stopwords 
bigrams_filtered <- bigrams_sep %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2%in% stop_words$word)%>%
  mutate(word = paste(word1, word2, sep=" "))
bigrams_filtered
```

    ## # A tibble: 22,153 x 9
    ##    source  article_id  title   location author published_date word1 word2 word  
    ##    <chr>   <chr>       <chr>   <chr>    <chr>  <date>         <chr> <chr> <chr> 
    ##  1 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     kron~ pok   krono~
    ##  2 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     pok   acti~ pok a~
    ##  3 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     acti~ orga~ activ~
    ##  4 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     kron~ fede~ krono~
    ##  5 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     fede~ poli~ feder~
    ##  6 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     poli~ yest~ polic~
    ##  7 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     tisk~ bend  tiske~
    ##  8 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     bend  gast~ bend ~
    ##  9 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     gast~ faci~ gaste~
    ## 10 All Ne~ All News T~ pok pr~ elodis,~ <NA>   2005-04-06     faci~ sway~ facil~
    ## # ... with 22,143 more rows

``` r
# Next we count the words
bigram_counts <- bigrams_filtered  %>%
  count(word, sort=TRUE) %>%
  filter(n>1)
bigram_counts
```

    ## # A tibble: 3,781 x 2
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
    ## # ... with 3,771 more rows

``` r
# we count the words by articles 
bigrams_by_articles <- bigrams_filtered %>% 
  count(source, word, sort=TRUE) %>% 
  ungroup()
bigrams_by_articles
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

``` r
# Obtain the  correlation between articles based on the bigrams
articles_cors <- bigrams_by_articles %>%
  pairwise_cor(source, word,n,sort=TRUE) %>% 
  distinct(correlation, .keep_all = TRUE)

# 
articles_cors%>% 
  arrange(desc(correlation)) %>%
  rowid_to_column('sort') %>%
  mutate(rank = percent_rank(correlation)) %>%
  ggplot(aes(rank, correlation)) +
  geom_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/bigram_viz-1.png" width="672" />

``` r
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

### Duplicated articles

From the [previous part](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-primary-vs-derivative-sources/)

``` r
article_titles_dup <- cleaned_text %>%
  group_by(title) %>%
  add_count(source) %>% 
  summarize(n_distinct_source = n_distinct(source), 
            n_distinct_date = n_distinct(published_date), 
            min_date = min(published_date),
            n = n()) %>%
  ungroup() %>%
  filter(n>1 & n_distinct_source>1 & n_distinct_date > 1) %>%
  arrange(desc(n))

dup_articles <- cleaned_text %>%
  filter(title %in% unique(article_titles_dup$title)) %>%
  arrange(desc(title), desc(source)) %>%
  left_join(article_titles_dup %>% select(title, min_date)) %>%
  drop_na(published_date, min_date) %>%
  mutate(days_lagged = published_date - min_date) %>%
  mutate(days_lagged = ifelse(days_lagged >=2, '>=2 days', paste(days_lagged, 'day'))) 

dup_articles 
```

    ## # A tibble: 228 x 9
    ##    source  article_id  text     title  location author published_date min_date  
    ##    <chr>   <chr>       <chr>    <chr>  <chr>    <chr>  <date>         <date>    
    ##  1 Homela~ Homeland I~ "yester~ who b~ abila, ~ Petru~ 2013-06-20     2013-06-20
    ##  2 All Ne~ All News T~ "  abil~ who b~ abila, ~ <NA>   2013-06-21     2013-06-20
    ##  3 The Ab~ The Abila ~ "with t~ who a~ abila, ~ <NA>   2012-08-22     2012-08-22
    ##  4 News O~ News Onlin~ " with ~ who a~ abila, ~ <NA>   2012-08-22     2012-08-22
    ##  5 Centra~ Central Bu~ " abila~ who a~ abila, ~ <NA>   2012-08-23     2012-08-22
    ##  6 Athena~ Athena Spe~ "with t~ who a~ abila, ~ <NA>   2012-08-24     2012-08-22
    ##  7 The Ab~ The Abila ~ "the in~ welln~ elodis,~ <NA>   1998-11-15     1998-11-15
    ##  8 News O~ News Onlin~ " the i~ welln~ elodis,~ <NA>   1998-11-15     1998-11-15
    ##  9 Centra~ Central Bu~ "the in~ welln~ elodis,~ <NA>   1998-11-16     1998-11-15
    ## 10 Who Wh~ Who What N~ "  abil~ welln~ abila, ~ <NA>   1998-11-14     1998-11-13
    ## # ... with 218 more rows, and 1 more variable: days_lagged <chr>

``` r
lag_nodes <- tibble(unique(cleaned_text$source), .name_repair = ~c("label")) %>%
  rowid_to_column('id')

lag_nodes
```

    ## # A tibble: 29 x 2
    ##       id label                
    ##    <int> <chr>                
    ##  1     1 All News Today       
    ##  2     2 Athena Speaks        
    ##  3     3 Central Bulletin     
    ##  4     4 Centrum Sentinel     
    ##  5     5 Daily Pegasus        
    ##  6     6 Everyday News        
    ##  7     7 Homeland Illumination
    ##  8     8 International News   
    ##  9     9 International Times  
    ## 10    10 Kronos Star          
    ## # ... with 19 more rows

``` r
no_lag <- dup_articles %>% 
  filter(days_lagged == "0 day") %>%
  select(source, title)

with_lag <- dup_articles %>% 
  filter(days_lagged != "0 day") %>%
  select(source, title, days_lagged)

lag_edges <- right_join(no_lag, with_lag, by= "title") %>%
  rename(source_label = source.x,
         target_label = source.y) %>%
  left_join(lag_nodes %>% select(label, id), by = c("source_label" = "label")) %>% 
  rename(from = id) %>%
  left_join(lag_nodes %>% select(label, id), by = c("target_label" = "label")) %>% 
  rename(to = id) 


# lag_graph <- tbl_graph(nodes = lag_nodes, 
#                           edges = lag_edges_agg, 
#                           directed = TRUE)
```

``` r
lag_edges_agg <- lag_edges %>% 
  mutate(arrows = "from") %>%
  group_by(from, to, source_label, target_label, arrows) %>%
  summarize(value = n()) %>%
  ungroup() %>% 
  mutate(smooth = TRUE) %>%
  arrange(desc(value))

lag_edges_agg
```

    ## # A tibble: 39 x 7
    ##     from    to source_label          target_label       arrows value smooth
    ##    <int> <int> <chr>                 <chr>              <chr>  <int> <lgl> 
    ##  1     7    13 Homeland Illumination News Online Today  from      20 TRUE  
    ##  2    10    13 Kronos Star           News Online Today  from      19 TRUE  
    ##  3    15     3 The Abila Post        Central Bulletin   from      13 TRUE  
    ##  4     7     1 Homeland Illumination All News Today     from      11 TRUE  
    ##  5    15    13 The Abila Post        News Online Today  from      11 TRUE  
    ##  6    10     8 Kronos Star           International News from      10 TRUE  
    ##  7    24    13 The World             News Online Today  from      10 TRUE  
    ##  8    24    26 The World             Who What News      from       9 TRUE  
    ##  9     9    13 International Times   News Online Today  from       6 TRUE  
    ## 10     1    13 All News Today        News Online Today  from       4 TRUE  
    ## # ... with 29 more rows

``` r
visNetwork(lag_nodes, lag_edges_agg) %>%
  visIgraphLayout(layout = "layout_with_fr")%>%
  visOptions(highlightNearest=TRUE, 
             nodesIdSelection=TRUE)%>%
  visLayout(randomSeed=123)
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],"label":["All News Today","Athena Speaks","Central Bulletin","Centrum Sentinel","Daily Pegasus","Everyday News","Homeland Illumination","International News","International Times","Kronos Star","Modern Rubicon","News Desk","News Online Today","Tethys News","The Abila Post","The Continent","The Explainer","The General Post","The Guide","The Light of Truth","The Orb","The Truth","The Tulip","The World","The Wrap","Who What News","World Journal","World Source","Worldwise"],"x":[-0.592481984545989,-0.211363480778659,-0.351287820175224,-0.653620016722416,-0.739881467721341,-0.464987758386761,-0.713376543588619,0.0970503184095033,-0.291256355567287,0.181785891272146,0.940844481717623,-0.119486952611256,-0.258005847318064,0.994876124523623,-0.210485626617811,-0.511963322669755,-0.406097966785676,0.767635449544757,0.265320708595458,0.522271342790562,-1,0.586706330292711,-0.155369746684387,0.204803455941307,1,0.00449224878562515,-0.0994174398529333,-0.308100164454804,0.660336121825007],"y":[-0.379869498241485,-0.0712985796546953,-0.14726055951947,0.807353330510193,-0.249648025407982,-0.991295148575693,-0.518455056587002,-0.226496069693043,-1,-0.399329942959785,0.393875667478062,0.485791211391675,-0.503544913089484,-0.490262931294615,0.0960507387804905,-0.802151979896899,0.199127318695377,-0.983967130672276,0.905838437487177,-0.947313248191839,0.00119082232215062,0.724524540692157,1,-0.771948776926319,-0.0833658879611897,-0.628882275047512,-0.946503675736612,-0.836109243015978,0.260197211918051]},"edges":{"from":[7,10,15,7,15,10,24,24,9,1,13,13,15,7,8,9,9,9,13,15,28,1,3,3,3,5,9,13,13,13,13,15,17,20,24,26,28,28,28],"to":[13,13,3,1,13,8,13,26,13,13,3,26,17,5,13,6,16,27,5,2,13,5,2,13,17,21,28,2,6,16,27,12,2,18,20,13,6,16,27],"source_label":["Homeland Illumination","Kronos Star","The Abila Post","Homeland Illumination","The Abila Post","Kronos Star","The World","The World","International Times","All News Today","News Online Today","News Online Today","The Abila Post","Homeland Illumination","International News","International Times","International Times","International Times","News Online Today","The Abila Post","World Source","All News Today","Central Bulletin","Central Bulletin","Central Bulletin","Daily Pegasus","International Times","News Online Today","News Online Today","News Online Today","News Online Today","The Abila Post","The Explainer","The Light of Truth","The World","Who What News","World Source","World Source","World Source"],"target_label":["News Online Today","News Online Today","Central Bulletin","All News Today","News Online Today","International News","News Online Today","Who What News","News Online Today","News Online Today","Central Bulletin","Who What News","The Explainer","Daily Pegasus","News Online Today","Everyday News","The Continent","World Journal","Daily Pegasus","Athena Speaks","News Online Today","Daily Pegasus","Athena Speaks","News Online Today","The Explainer","The Orb","World Source","Athena Speaks","Everyday News","The Continent","World Journal","News Desk","Athena Speaks","The General Post","The Light of Truth","News Online Today","Everyday News","The Continent","World Journal"],"arrows":["from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from"],"value":[20,19,13,11,11,10,10,9,6,4,4,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":null,"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"}},"evals":[],"jsHooks":[]}</script>
