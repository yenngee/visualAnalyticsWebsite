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
## $ text           <chr> "  Fifteen members of the Protectors of Kronos (POK) ac~
## $ title          <chr> "pok protests end in arrests", "rally scheduled in supp~
## $ location       <chr> "elodis, kronos", "abila, kronos", "abila, kronos", "el~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
## $ published_date <date> 2005-04-06, 2012-04-09, 1993-02-02, NA, 1998-05-15, 20~
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

#### 1) Identifying Primary/Derivative if 'time' is in the article

Let's apply this to get a definition of whether a particular article is primary or derivative. 


```r
cleaned_text$is_primary <- str_detect(cleaned_text$text, "^[0-2][0-9][0-5][0-9]") | str_detect(cleaned_text$text, "[0-1]?[0-9]:[0-5]{1}[0-9]{1} [AP]M")
cleaned_text$is_primary <- if_else(cleaned_text$is_primary, "primary", "derivative")
```

#### 2) Visualize type of articles per source_type

**Step 1**: Not all of the news article source has both primary and derivative sources. Hence, we first create the complete data frame with all of the cleaned 
**Step 2**: We then create `source_type_per_article` which is dataframe that counts the number of articles of type primary or derivative for each newspaper source. 
**Step 3**: Unfortunately, for our visualization to be pretty, we'll need to sort it. I want to sort it by the percentile of primary articles out of the total number of articles each news source has. So this steps create `source_type_per_article_perc`. 
**Step 4**: we do a `left_join`, and `fct_order` by the primary_perc to get the final data frame. 


```r
# Step 1 
full_source_type_per_article <- expand_grid(source = unique(cleaned_text$source), 
                                             is_primary = c('primary', 'derivative')) 

# Step 2
source_type_per_article <- cleaned_text %>%
  group_by(source, is_primary) %>%
  summarize(n = n()) %>% 
  ungroup() %>%
  right_join(full_source_type_per_article, by = c('source', 'is_primary')) %>%
  arrange(desc(n))

# Step 3 
source_type_per_article_perc <- source_type_per_article %>% 
  pivot_wider(names_from= is_primary, values_from=n) %>%
  replace_na(list(derivative=0L, primary=0L)) %>%
  mutate(primary_perc = primary/(derivative + primary), 
         source = as.character(source)) %>%
  select(source, primary_perc)

# Step 4 
source_type_per_article <- source_type_per_article %>%
  left_join(source_type_per_article_perc) %>%
  mutate(source = fct_reorder(source, primary_perc))

source_type_per_article
```

```
## # A tibble: 58 x 4
##    source                is_primary     n primary_perc
##    <fct>                 <chr>      <int>        <dbl>
##  1 News Online Today     derivative   111        0    
##  2 Homeland Illumination primary       37        0.578
##  3 Centrum Sentinel      primary       36        1    
##  4 Kronos Star           primary       34        0.548
##  5 Tethys News           primary       29        0.829
##  6 Kronos Star           derivative    28        0.548
##  7 The Guide             derivative    28        0    
##  8 The Truth             derivative    28        0    
##  9 Worldwise             derivative    28        0    
## 10 Homeland Illumination derivative    27        0.578
## # ... with 48 more rows
```

**Pyramid plot style**


```r
plot_derivative <- source_type_per_article %>% 
  filter(is_primary == "derivative") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity', fill="#0072B2") +
  scale_y_continuous('') + 
  ylim(0,120)+
  theme(legend.position = 'none',
        axis.title.y = element_blank(),
        plot.title = element_text(size = 11.5, hjust = 0.5),
        plot.margin=unit(c(0.1,0.2,0.1,-.1),"cm"),
        axis.ticks.y = element_blank(), 
        axis.text.y = element_text(hjust = 0.5)) + #theme_bw()$axis.text.y,
  ggtitle("Derivative") + 
  coord_flip() 
  
plot_primary <- source_type_per_article %>% 
  filter(is_primary == "primary") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity', fill="#D55E00") +
  # ylim(0,120)+
  scale_y_continuous(trans = 'reverse', limits=c(120,0))+ 
  theme(legend.position = 'none',
        axis.title.y = element_blank(),
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

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_pyramid-1.png" width="672" />

**Percentile bar plot style**


```r
source_type_per_article %>%
  ggplot(aes(fill=is_primary, y=n, x=source)) +
  geom_bar(position="fill", stat="identity") +
  coord_flip()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_perc_bar-1.png" width="672" />

### It's all about speed.

During exploration of data, we found that some of the titles where duplicated. This means that some articles were posted 'after' others in different sources. The assumption is that the article that posts first, is considered a primary source, while the article that posts second is then considered the derivative source. 

Some of the articles have the same title because they are part of a group of posts, e.g. "voices - a blog about what is important to the people" where all the articles are in this same category but not necessary the same 'article'. Some of the articles are posted on the same date despite the same title, unfortunately, we are unable to tell them apart then. 

Hence, we identify such duplicates with the following conditions: 

* title repeated more than once 
* more than 1 number of distinct sources with the same title
* more than 1 number of distinct published dates with the same title 


```r
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

article_titles_dup
```

```
## # A tibble: 81 x 5
##    title                       n_distinct_sour~ n_distinct_date min_date       n
##    <chr>                                  <int>           <int> <date>     <int>
##  1 profile:  elian karel                      6               2 2009-06-22     6
##  2 anniversary of protests                    5               3 2010-06-13     5
##  3 possible contamination in ~                5               3 1997-04-23     5
##  4 a look back at a life cut ~                3               2 2011-06-20     4
##  5 elodis public health fact ~                3               3 1998-05-15     4
##  6 gastech                                    4               2 2013-02-22     4
##  7 gastech adopts new logo                    4               3 2009-05-15     4
##  8 pok leader karel arrested                  3               2 2009-03-12     4
##  9 pok remembers martyred lea~                4               2 2012-06-20     4
## 10 traffic accident near elod~                4               2 2007-04-10     4
## # ... with 71 more rows
```

From there we are able to visualize the number of articles which lagged 0,1 or >=2 days from the first article appearance. 


```r
dup_articles <- cleaned_text %>%
  filter(title %in% unique(article_titles_dup$title)) %>%
  arrange(desc(title), desc(source)) %>%
  left_join(article_titles_dup %>% select(title, min_date)) %>%
  drop_na(published_date, min_date) %>%
  mutate(days_lagged = published_date - min_date) %>%
  mutate(days_lagged = ifelse(days_lagged >=2, '>=2 days', paste(days_lagged, 'day'))) 

dup_articles_by_sources <- dup_articles %>%
  group_by(source, days_lagged) %>%
  summarize(n = n()) %>%
  ungroup() %>% 
  arrange(desc(days_lagged)) 
dup_articles_by_sources
```

```
## # A tibble: 36 x 3
##    source             days_lagged     n
##    <chr>              <chr>       <int>
##  1 All News Today     1 day           9
##  2 Athena Speaks      1 day           2
##  3 Central Bulletin   1 day          13
##  4 Everyday News      1 day           1
##  5 International News 1 day          10
##  6 News Online Today  1 day          61
##  7 The Continent      1 day           1
##  8 The Explainer      1 day           2
##  9 The General Post   1 day           1
## 10 The Orb            1 day           1
## # ... with 26 more rows
```

```r
dup_articles_by_sources %>%
  mutate(days_lagged = factor(days_lagged, levels = c('0 day', '1 day', '>=2 days')), 
         source = fct_reorder(source,n)) %>%
  # pivot_wider(names_from = days_lagged, values_from = n) %>%
  # replace_na(list('>=_2_days' = 0L, '0_day' = 0L, '1_day' = 0L)) %>%
  ggplot(aes(x=source, y = n, fill = days_lagged)) +
  geom_bar(stat = 'identity') + 
  coord_flip() + 
  facet_wrap(~days_lagged)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/dup_aritcles_by_sources-1.png" width="672" />

Let's visualize it. 


```r
dup_articles %>%
  mutate(date_day = day(published_date), 
         title = fct_reorder(title, date_day) ) %>%
  ggplot(aes(x=date_day, y=title)) +
  geom_line(size=2) 
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-1-1.png" width="672" />


This is adds on to the number of primary articles that we can identify. We create new is_primary columns to track. 

* is_primary1 : original is_primary column
* is_primary2 : status derived from the duplicated article titles and their dates 
* is_primary  : if is_primary2 = 'primary', then 'primary. else is_primary_1


```r
cleaned_text <- cleaned_text %>% 
  left_join(dup_articles %>% select(article_id, days_lagged)) %>%
  mutate(is_primary2 = ifelse( days_lagged == "0 day", "primary", "derivative"), 
         is_primary1 = is_primary) %>%
  replace_na(list(is_primary2 = 'unknown')) %>% 
  mutate(is_primary = ifelse(is_primary2 == "primary", "primary", is_primary1))

cleaned_text
```

```
## # A tibble: 845 x 11
##    source  article_id  text    title   location author published_date is_primary
##    <chr>   <chr>       <chr>   <chr>   <chr>    <chr>  <date>         <chr>     
##  1 All Ne~ All News T~ "  Fif~ pok pr~ elodis,~ <NA>   2005-04-06     derivative
##  2 All Ne~ All News T~ "  Sil~ rally ~ abila, ~ <NA>   2012-04-09     primary   
##  3 All Ne~ All News T~ "  In ~ lack o~ abila, ~ <NA>   1993-02-02     primary   
##  4 All Ne~ All News T~ " NOTE~ elodis~ elodis,~ <NA>   NA             derivative
##  5 All Ne~ All News T~ "NOTE:~ elodis~ <NA>     <NA>   1998-05-15     derivative
##  6 All Ne~ All News T~ "  The~ elodis~ elodis,~ <NA>   2004-05-29     primary   
##  7 All Ne~ All News T~ "  ABI~ who br~ abila, ~ <NA>   2013-06-21     derivative
##  8 All Ne~ All News T~ "  A m~ tax me~ abila, ~ <NA>   2001-03-22     derivative
##  9 All Ne~ All News T~ "  Rep~ pok re~ abila, ~ <NA>   1998-11-15     derivative
## 10 All Ne~ All News T~ "  Eli~ elian ~ abila, ~ <NA>   2009-06-20     derivative
## # ... with 835 more rows, and 3 more variables: days_lagged <chr>,
## #   is_primary2 <chr>, is_primary1 <chr>
```


```r
# Step 2
source_type_per_article <- cleaned_text %>%
  group_by(source, is_primary) %>%
  summarize(n = n()) %>% 
  ungroup() %>%
  right_join(full_source_type_per_article, by = c('source', 'is_primary')) %>%
  arrange(desc(n))

# Step 3 
source_type_per_article_perc <- source_type_per_article %>% 
  pivot_wider(names_from= is_primary, values_from=n) %>%
  replace_na(list(derivative=0L, primary=0L)) %>%
  mutate(primary_perc = primary/(derivative + primary), 
         source = as.character(source)) %>%
  select(source, primary_perc)

# Step 4 
source_type_per_article <- source_type_per_article %>%
  left_join(source_type_per_article_perc) %>%
  mutate(source = fct_reorder(source, primary_perc))
```


**Pyramid plot style**

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_pyramid2-1.png" width="672" />

**Percentile bar plot style**

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_perc_bar2-1.png" width="672" />

