---
title: 'MC1: Primary vs Derivative Sources'
author: 'Ng Yen Ngee'
date: '2021-07-21'
lastmod: '2021-07-25'
slug: []
cover: "/img/p_vs_s.png"
categories: []
tags: ['MITB', "MC1", 'Text Analytics']
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

We observe that articles that have a time stamp at the start of the article looks a lot like a blog post. We also observe that if the title contains the word blog, they are also considered primary sources. Let's apply this to get a definition of whether a particular article is primary or derivative. 


```r
## identify dates 
has_timestamps <- str_detect(cleaned_text$text, "^[0-2][0-9][0-5][0-9]") | str_detect(cleaned_text$text, "[0-1]?[0-9]:[0-5]{1}[0-9]{1} [AP]M")
cleaned_text$primary_type <- if_else(has_timestamps, "blog post", NULL)
cleaned_text$is_primary <- if_else(has_timestamps, "primary", "derivative")

## identify 
is_blog_post <- str_detect(cleaned_text$title,"\\bblog\\b")
cleaned_text$primary_type <- if_else(is_blog_post, "blog post", cleaned_text$primary_type)
cleaned_text$is_primary <- if_else(is_blog_post, "primary", cleaned_text$is_primary)
```

#### 2) Visualize type of articles per source_type

**Step 1**: Not all of the news article source has both primary and derivative sources. Hence, we first create the complete data frame with all of the cleaned <br>
**Step 2**: We then create `source_type_per_article` which is dataframe that counts the number of articles of type primary or derivative for each newspaper source.  <br>
**Step 3**: Unfortunately, for our visualization to be pretty, we'll need to sort it. I want to sort it by the percentile of primary articles out of the total number of articles each news source has. So this steps create `source_type_per_article_perc`.  <br>
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
##  2 Kronos Star           derivative    62        0    
##  3 Homeland Illumination primary       37        0.578
##  4 Centrum Sentinel      primary       36        1    
##  5 Tethys News           derivative    35        0    
##  6 Modern Rubicon        primary       30        1    
##  7 The Abila Post        primary       30        0.556
##  8 The Guide             derivative    28        0    
##  9 The Truth             derivative    28        0    
## 10 Worldwise             derivative    28        0    
## # ... with 48 more rows
```

Let us visualize this with a pyramid plot style. We will be using the same code for the later sections as we try to decifer with more conditions which articles are the primary and derivative sources. 

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
        axis.text.y = element_text(hjust = 0.5)) + 
  ggtitle("Derivative") + 
  coord_flip() 
  
plot_primary <- source_type_per_article %>% 
  filter(is_primary == "primary") %>%
  ggplot(aes(x=source, y=n)) +
  geom_bar(stat='identity', fill="#D55E00") +
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
## # A tibble: 79 x 5
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
## # ... with 69 more rows
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
##  1 All News Today     1 day          10
##  2 Athena Speaks      1 day           2
##  3 Central Bulletin   1 day          13
##  4 Everyday News      1 day           1
##  5 International News 1 day          10
##  6 News Online Today  1 day          63
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
         is_primary1 = is_primary, 
         primary_type = if_else(days_lagged == "0 day" & !is_primary == 'primary', 'first post', primary_type)) %>%
  replace_na(list(is_primary2 = 'unknown')) %>% 
  mutate(is_primary = ifelse(is_primary2 == "primary", "primary", is_primary1))

cleaned_text
```

```
## # A tibble: 845 x 12
##    source  article_id  text   title  location author published_date primary_type
##    <chr>   <chr>       <chr>  <chr>  <chr>    <chr>  <date>         <chr>       
##  1 All Ne~ All News T~ "  fi~ pok p~ elodis,~ <NA>   2005-04-06     <NA>        
##  2 All Ne~ All News T~ "  si~ rally~ abila, ~ <NA>   2012-04-09     first post  
##  3 All Ne~ All News T~ "  in~ lack ~ abila, ~ <NA>   1993-02-02     first post  
##  4 All Ne~ All News T~ " not~ elodi~ elodis,~ <NA>   1998-03-20     <NA>        
##  5 All Ne~ All News T~ "note~ elodi~ <NA>     <NA>   1998-05-15     <NA>        
##  6 All Ne~ All News T~ "  th~ elodi~ elodis,~ <NA>   2004-05-29     first post  
##  7 All Ne~ All News T~ "  ab~ who b~ abila, ~ <NA>   2013-06-21     <NA>        
##  8 All Ne~ All News T~ "  a ~ tax m~ abila, ~ <NA>   2001-03-22     <NA>        
##  9 All Ne~ All News T~ "  re~ pok r~ abila, ~ <NA>   1998-11-15     <NA>        
## 10 All Ne~ All News T~ "  el~ elian~ abila, ~ <NA>   2009-06-20     <NA>        
## # ... with 835 more rows, and 4 more variables: is_primary <chr>,
## #   days_lagged <chr>, is_primary2 <chr>, is_primary1 <chr>
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

### The Events We Know 

There are certain known events that occur at a specific date and time. Thus we know that articles that mention the event after the event date are considered derivative sources, while news article that reported the event on the day itself could be considered as primary sources.

Here are some of the known events from reading the articles or from literature review: 

* 18/08/1998 Juliana Vann died
* 19/6/2009 Elian Karel died in prison

#### 18/08/1998 Juliana Vann died 

The first source, by Homeland Illumination could be considered the primary source which has already been identified as primary source, we find that though this is the first article which mentioned that Julianna Vann died, it also included other information about the poisoning etc which makes it still a derivative source than a primary one. We will need to make this into a derivative source. 


```r
mentioned_event <- str_detect(cleaned_text$text, "juliana")

# the first source would be 
articles_mentioned_event <- cleaned_text %>% 
  filter(mentioned_event == TRUE)%>%
  arrange(published_date) %>%
  select(article_id, source, published_date, is_primary, title, text) 

articles_mentioned_event
```

```
## # A tibble: 76 x 6
##    article_id   source   published_date is_primary title          text          
##    <chr>        <chr>    <date>         <chr>      <chr>          <chr>         
##  1 Homeland Il~ Homelan~ 1998-08-19     primary    ten-year old ~ "earlier this~
##  2 News Online~ News On~ 1998-08-20     derivative ten-year old ~ " ten-year ol~
##  3 The Orb_275  The Orb  1998-08-20     derivative from ten year~ "ten years ol~
##  4 The Wrap_409 The Wrap 1998-08-21     derivative ten years old~ "locations:  ~
##  5 Homeland Il~ Homelan~ 1999-07-07     primary    minister of h~ "prime minist~
##  6 All News To~ All New~ 1999-07-08     derivative minister of h~ "  minister o~
##  7 The Orb_248  The Orb  1999-07-09     derivative minister for ~ "the minister~
##  8 The Wrap_740 The Wrap 1999-07-09     derivative minister of h~ "the minister~
##  9 Kronos Star~ Kronos ~ 2001-08-30     primary    activists dis~ "five young p~
## 10 Homeland Il~ Homelan~ 2001-08-31     primary    pok members a~ "government h~
## # ... with 66 more rows
```

```r
# check if there has been any articles that are already considered primary source which suggests more than 1 event: 
articles_mentioned_event %>% 
  count(is_primary)
```

```
## # A tibble: 2 x 2
##   is_primary     n
##   <chr>      <int>
## 1 derivative    55
## 2 primary       21
```

```r
## Exact text of the primary source 
articles_mentioned_event %>% 
  filter(row_number() == 1) %>% 
  pull(text)
```

```
## [1] "earlier this year a series homeland illumination published a series of articles about groundwater contamination in elodis, and how the locals are demanding a government response for what is essentially government of kronos-sponsored pollution and poisoning of citizens.  this article is an update.elodis, kronos - ten-year old juliana vann died yesterday afternoon, surrounded by her family and friends.  the cause of death was leukemia due to benzene poisoning.juliana had been sick for over a year.  initially her family didn't realize that benzene poisoning was the cause of juliana's problems.  after visits to many hospitals, a doctor associated with the international assistance organization wellness for all recommended juliana be tests for benzene poisoning.  at that point, however, the little girl's system was too damaged to recover.the residents of elodis have been pleading with the government of kronos to take action against the pollution caused by the gastech gas drilling operation just 20 km upstream from elodis.juliana's death is but one of several deaths this rural township has suffered because of toxic waste being dumped into the tiskele river by tethys corporation gastech.private funeral services will be held on august 21 in the family home."
```

```r
cleaned_text <- cleaned_text %>%
  mutate(is_primary = ifelse(article_id == 'Homeland Illumination_293', 'derivative', is_primary), 
         primary_type = ifelse(article_id == 'Homeland Illumination_293', NA, primary_type)
         # primary_type = replace(primary_type, article_id == 'Homeland Illumination_293', NA)
         )
```

#### 19/6/2009 Elian Karel died in prison

There is no article that stated this event on the day itself. 


```r
mentioned_event <- str_detect(cleaned_text$text, "elian karel") & str_detect(cleaned_text$text, "died") & !str_detect(cleaned_text$text, "juliana")

# the first source would be 
articles_mentioned_event <- cleaned_text %>% 
  filter(mentioned_event == TRUE & published_date >= "2009-06-19")%>%
  arrange(published_date) 

articles_mentioned_event
```

```
## # A tibble: 14 x 12
##    source  article_id  text   title  location author published_date primary_type
##    <chr>   <chr>       <chr>  <chr>  <chr>    <chr>  <date>         <chr>       
##  1 News O~ News Onlin~ " eli~ elian~ abila, ~ <NA>   2009-06-20     <NA>        
##  2 Daily ~ Daily Pega~ "elia~ elian~ abila, ~ <NA>   2009-06-21     <NA>        
##  3 News O~ News Onlin~ "foll~ leade~ abila, ~ <NA>   2009-06-21     <NA>        
##  4 Worldw~ Worldwise_~ "a ga~ the p~ abila, ~ <NA>   2009-06-21     <NA>        
##  5 The Ex~ The Explai~ "the ~ the s~ abila, ~ <NA>   2009-06-22     <NA>        
##  6 Everyd~ Everyday N~ "<<de~ profi~ <NA>     <NA>   2009-06-23     <NA>        
##  7 News O~ News Onlin~ " one~ in re~ abila, ~ <NA>   2010-06-19     first post  
##  8 Daily ~ Daily Pega~ "a yo~ in re~ abila, ~ <NA>   2010-06-21     <NA>        
##  9 The Gu~ The Guide_~ "the ~ prote~ abila, ~ <NA>   2010-06-22     <NA>        
## 10 Daily ~ Daily Pega~ "for ~ a gla~ abila, ~ <NA>   2011-06-21     <NA>        
## 11 News O~ News Onlin~ "two ~ a loo~ abila, ~ <NA>   2011-06-21     <NA>        
## 12 Everyd~ Everyday N~ "the ~ the p~ <NA>     <NA>   2012-06-21     <NA>        
## 13 The Ex~ The Explai~ "with~ the w~ abila, ~ <NA>   2012-08-24     <NA>        
## 14 Daily ~ Daily Pega~ "7 of~ infla~ abila, ~ <NA>   2014-03-26     <NA>        
## # ... with 4 more variables: is_primary <chr>, days_lagged <chr>,
## #   is_primary2 <chr>, is_primary1 <chr>
```

## Final cleaned text 


```r
cleaned_text <- cleaned_text %>%
  select(-is_primary1, -is_primary2)

write_rds(cleaned_text, "data/news_article_clean_primary_vs_derivative.rds")

glimpse(cleaned_text)
```

```
## Rows: 845
## Columns: 10
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ article_id     <chr> "All News Today_121", "All News Today_135", "All News T~
## $ text           <chr> "  fifteen members of the protectors of kronos (pok) ac~
## $ title          <chr> "pok protests end in arrests", "rally scheduled in supp~
## $ location       <chr> "elodis, kronos", "abila, kronos", "abila, kronos", "el~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
## $ published_date <date> 2005-04-06, 2012-04-09, 1993-02-02, 1998-03-20, 1998-0~
## $ primary_type   <chr> NA, "first post", "first post", NA, NA, "first post", N~
## $ is_primary     <chr> "derivative", "primary", "primary", "derivative", "deri~
## $ days_lagged    <chr> "1 day", "0 day", "0 day", "1 day", NA, "0 day", "1 day~
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

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_pyramid3-1.png" width="672" />

**Percentile bar plot style**

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_perc_bar3-1.png" width="672" />

