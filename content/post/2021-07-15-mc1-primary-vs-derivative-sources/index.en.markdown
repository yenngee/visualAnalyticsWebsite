---
title: 'MC1: Primary vs Derivative Sources'
author: 'Ng Yen Ngee'
date: '2021-07-15'
lastmod: '2021-07-15'
slug: []
cover: "/img/p_vs_s.png"
categories: []
tags: ['MITB', 'Text Analytics', "Kronos Kidnapping"]
output:
  blogdown::html_page: 
    toc: true
---




# Introduction 
In this post, I will be running through the thought process of answering Q1 of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html):  
Which are primary sources and which are derivative sources? What are the relationships between the primary and derivative sources? 

The final analysis done can be found [here](). 

## Preperation 
### Load Packages 
These are the packages used for this post. 

```r
library(tidyverse)
library(tidytext)
library(stringr)
library(gridExtra)
```


### Load Data 
The data has been previously loaded, cleaned and transformed into a neat tibble dataframe here. 
We load the cleaned data directly below: 


```r
cleaned_text <- read_rds("data/news_article_raw.rds")
glimpse(cleaned_text)
```

```
## Rows: 845
## Columns: 6
## $ source     <chr> "All News Today", "All News Today", "All News Today", "All ~
## $ article_id <chr> "All News Today_121", "All News Today_135", "All News Today~
## $ text       <chr> "  Fifteen members of the Protectors of Kronos (POK) activi~
## $ title      <chr> "POK PROTESTS END IN ARRESTS", "RALLY SCHEDULED IN SUPPORT ~
## $ published  <chr> "2005/04/06", "2012/04/09", "1993/02/02", "Petrus Gerhard",~
## $ location   <chr> "ELODIS, Kronos", "ABILA, Kronos", "ABILA, Kronos", "ELODIS~
```

## Primary Sources VS Derivative sources
### What are they? 
According to the [research guide from the SMU Library](https://guides.smu.edu/primarysources#:~:text=Primary%20sources%20are%20original%2C%20first%2Dhand%20testimony.&text=These%20sources%20help%20depict%20what,statistical%20data%2C%20artifacts%20or%20treaties) as well as many other resources found from good old trusty Google: 

> A **primary source** is "first-hand" information, sources as close as possible to the origin of the information or idea under study. Often these sources are created at the time when the events or conditions are occurring, but primary sources can also include autobiographies, memoirs, and oral histories recorded later.

Hence, for our cases, we can classify blogs as primary sources, or any text that contains 'time' information because it implies that it is updated 'live' as a first person account. 

On the other hand: 

> Secondary sources (**Derivative sources**) works that provide analysis, commentary, or criticism on the primary source.

Now it becomes a little bit more tricky. Our data mainly consists on news articles and news articles can be considered as both primary and secondary sources. 

There's an interesting article online by the [Hartness Library](https://hartness.vsc.edu/find/articles/newspapers/primary-sources/) that explains pretty clearly what to consider when trying to decide if the news article is a primary or derivative source. We will be using some of the guidelines to help us figure this out as well. 

### Confirm plus Chope Primary sources: blogs/live updates 
We are certain that texts that are part of live blogs. So the first step is to identify if time is in the article text. We use `str_detect` from `stringr` package to do this. 
From a visual inspection on the cleaned data, we can find two formats of time: 


```r
str_detect("2359 random text hahaha", "^[0-2][0-9][0-5][0-9]") #time starts the article 
```

```
## [1] TRUE
```

```r
str_detect("more random text 6:30 AM hahaha", "[0-1]?[0-9]:[0-5]{1}[0-9]{1} [AP]M") # is in the format 6:30 AM 
```

```
## [1] TRUE
```

```r
cleaned_text$is_primary <- str_detect(cleaned_text$text, "^[0-2][0-9][0-5][0-9]") | str_detect(cleaned_text$text, "[0-1]?[0-9]:[0-5]{1}[0-9]{1} [AP]M")
cleaned_text$is_primary <- if_else(cleaned_text$is_primary, "primary", "derivative")
```



```r
full_source_type_per_article <- expand_grid(source = unique(cleaned_text$source), 
                                             is_primary = c('primary', 'derivative')) 
full_source_type_per_article
```

```
## # A tibble: 58 x 2
##    source           is_primary
##    <chr>            <chr>     
##  1 All News Today   primary   
##  2 All News Today   derivative
##  3 Athena Speaks    primary   
##  4 Athena Speaks    derivative
##  5 Central Bulletin primary   
##  6 Central Bulletin derivative
##  7 Centrum Sentinel primary   
##  8 Centrum Sentinel derivative
##  9 Daily Pegasus    primary   
## 10 Daily Pegasus    derivative
## # ... with 48 more rows
```

```r
source_type_per_article <- cleaned_text %>%
  group_by(source, is_primary) %>%
  summarize(n = n()) %>% 
  ungroup() %>%
  right_join(full_source_type_per_article, by = c('source', 'is_primary'))# %>% 
  # pivot_wider(names_from= is_primary, values_from=n) %>%
  # replace_na(list(derivative=0L, primary=0L))
source_type_per_article
```

```
## # A tibble: 58 x 3
##    source                is_primary     n
##    <chr>                 <chr>      <int>
##  1 All News Today        derivative    18
##  2 Athena Speaks         derivative    24
##  3 Athena Speaks         primary        1
##  4 Central Bulletin      derivative    21
##  5 Centrum Sentinel      primary       36
##  6 Daily Pegasus         derivative    26
##  7 Everyday News         derivative    15
##  8 Homeland Illumination derivative    64
##  9 International News    derivative    20
## 10 International Times   derivative    14
## # ... with 48 more rows
```

```r
# source_type_per_article %>%
#   ggplot(aes(x = source, y = n, fill = is_primary)) +
#   geom_bar(stat='identity') + 
#   coord_flip()


plot_derivative <- source_type_per_article %>% 
  filter(is_primary == "derivative") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity', fill='blue') +
  scale_y_continuous('') + 
  theme(legend.position = 'none',
        axis.title.y = element_blank(),
        plot.title = element_text(size = 11.5, hjust = 0.5),
        plot.margin=unit(c(0.1,0.2,0.1,-.1),"cm"),
        axis.ticks.y = element_blank(), 
        axis.text.y = theme_bw()$axis.text.y,
        axis.text.x = element_text(hjust = 0.5))+ 
  ggtitle("Derivative") + 
  coord_flip() 
  
plot_primary <- source_type_per_article %>% 
  filter(is_primary == "primary") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity', fill='red') +
  scale_y_continuous(trans = 'reverse')+ 
  theme(legend.position = 'none',
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(), 
        plot.title = element_text(size = 11.5, hjust = 0.5),
        plot.margin=unit(c(0.1,0,0.1,0.05),"cm")) + 
  ggtitle("Primary") +
  coord_flip()

plot_sources <- source_type_per_article %>% 
  filter(is_primary == "derivative") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity')+
  geom_text(aes(y=0, label=source))+ 
  coord_flip()

grid.arrange(plot_primary, plot_derivative, 
             widths=c(0.4,0.6),
             ncol=2
)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/live_updates_viz-1.png" width="672" />
### It's all about speed.

