---
title: "Extra Lesson Text Analytics by Prof Kam"
author: "Ng Yen Ngee"
date: '2021-07-11'
slug: []
cover: "/img/text_analytics2.jpg"
categories: []
tags: ['MITB', 'Text Analytics']
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
# library(hms)
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

# how the function works 
# alt.atheism_df <- read_folder("data/20news/alt.atheism")
```


```r
# raw_text <- tibble(folder = dir(news20, full.names=TRUE)) %>%
#   mutate(folder_out = map(folder, read_folder)) %>%
#   unnest(cols = c(folder_out)) %>%
#   transmute(newsgroup = basename(folder), id, text)
# 
# write_rds(raw_text, "data/rds/news20.rds")

raw_text <- read_rds("data/rds/news20.rds")
glimpse(raw_text)
```

```
## Rows: 7,601
## Columns: 3
## $ newsgroup <chr> "alt.atheism", "alt.atheism", "alt.atheism", "alt.atheism", ~
## $ id        <chr> "54256", "54256", "54256", "54256", "54256", "54256", "54256~
## $ text      <chr> "From: salem@pangea.Stanford.EDU (Bruce Salem)", "Subject: R~
```

To check if there is the correct number of 


```r
raw_text %>%
  group_by(newsgroup) %>%
  summarize(messages=n_distinct(id)) %>%
  ggplot(aes(messages, newsgroup)) +
  geom_col(fill="lightblue") + 
  labs(y=NULL)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/initial_eda-1.png" width="672" />

### Clean Data 


```r
cleaned_text <- raw_text %>%
  group_by(newsgroup, id) %>%
  filter(cumsum(text == "") >0, 
         cumsum(str_detect(text, "^--")) == 0) %>%
  ungroup()

cleaned_text 
```

```
## # A tibble: 5,870 x 3
##    newsgroup   id    text                                                       
##    <chr>       <chr> <chr>                                                      
##  1 alt.atheism 54256 ""                                                         
##  2 alt.atheism 54256 "In article <C5u7Bq.J43@news.cso.uiuc.edu> cobb@alexia.lis~
##  3 alt.atheism 54256 ">As per various threads on science and creationism, I've ~
##  4 alt.atheism 54256 ">book called Christianity and the Nature of Science by JP~
##  5 alt.atheism 54256 ""                                                         
##  6 alt.atheism 54256 "\tAs I don't know this book, I will use your heresay."    
##  7 alt.atheism 54256 ""                                                         
##  8 alt.atheism 54256 "> A question"                                             
##  9 alt.atheism 54256 ">that I had come from one of his comments.  He stated tha~
## 10 alt.atheism 54256 ">necessarily a religious term, but could be used as other~
## # ... with 5,860 more rows
```

```r
cleaned_text <- cleaned_text %>% 
  filter(str_detect(text, "^[^>]+[A-Za-z\\d]") | text == "", 
         !str_detect(text, "writes(:|\\.\\.\\.)$"),
         !str_detect(text, "^In article <"))

cleaned_text 
```

```
## # A tibble: 4,449 x 3
##    newsgroup   id    text                                                       
##    <chr>       <chr> <chr>                                                      
##  1 alt.atheism 54256 ""                                                         
##  2 alt.atheism 54256 ""                                                         
##  3 alt.atheism 54256 "\tAs I don't know this book, I will use your heresay."    
##  4 alt.atheism 54256 ""                                                         
##  5 alt.atheism 54256 ""                                                         
##  6 alt.atheism 54256 "\tIt depends on how he defines God. The way I understand ~
##  7 alt.atheism 54256 "of that term preclues it being used in a useful way in sc~
##  8 alt.atheism 54256 "from an understanding that God is supernatural precludes ~
##  9 alt.atheism 54256 "scientific assertions that can be falsified, that is, whe~
## 10 alt.atheism 54256 "that they are true or false within the terms of we use an~
## # ... with 4,439 more rows
```

## Get a bag of words 

### Tokenize 

```r
# usenet_words_own <- cleaned_text %>% 
#   unnest_tokens(word, text) %>%
#   anti_join(stop_words) # to remove stop words 
# 
# usenet_words_own

usenet_words <- cleaned_text %>% 
  unnest_tokens(word, text) %>%
  filter(str_detect(word, "[a-z']$"), # only keep words. exclude all numeric. 
         !word %in% stop_words$word) # to remove stop words 

usenet_words 
```

```
## # A tibble: 11,825 x 3
##    newsgroup   id    word      
##    <chr>       <chr> <chr>     
##  1 alt.atheism 54256 book      
##  2 alt.atheism 54256 heresay   
##  3 alt.atheism 54256 depends   
##  4 alt.atheism 54256 defines   
##  5 alt.atheism 54256 god       
##  6 alt.atheism 54256 understand
##  7 alt.atheism 54256 meaning   
##  8 alt.atheism 54256 term      
##  9 alt.atheism 54256 preclues  
## 10 alt.atheism 54256 science   
## # ... with 11,815 more rows
```

### visualize 


```r
usenet_words %>% 
  count(word, sort=TRUE)
```

```
## # A tibble: 5,542 x 2
##    word           n
##    <chr>      <int>
##  1 people        57
##  2 time          50
##  3 jesus         47
##  4 god           44
##  5 message       40
##  6 br            27
##  7 bible         23
##  8 drive         23
##  9 homosexual    23
## 10 read          22
## # ... with 5,532 more rows
```

```r
words_by_newsgroup <- usenet_words %>% 
  count(newsgroup, word, sort=TRUE) %>% 
  ungroup()

words_by_newsgroup
```

```
## # A tibble: 8,124 x 3
##    newsgroup          word            n
##    <chr>              <chr>       <int>
##  1 alt.atheism        jesus          39
##  2 sci.crypt          message        31
##  3 alt.atheism        br             27
##  4 alt.atheism        rh             21
##  5 sci.crypt          pad            20
##  6 talk.politics.misc homosexual     20
##  7 talk.politics.misc homosexuals    19
##  8 comp.windows.x     widget         18
##  9 misc.forsale       comics         17
## 10 rec.sport.hockey   pts            17
## # ... with 8,114 more rows
```

To visualize the words, we can use word cloud 


```r
wordcloud(words = words_by_newsgroup$word, 
          freq = words_by_newsgroup$n, 
          max.words = 50)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/wordcloud-1.png" width="672" />


```r
set.seed(1234)

words_by_newsgroup %>%
  filter(n>5) %>%
  ggplot(aes(label=word, size = n)) + 
  geom_text_wordcloud() + 
  theme_minimal() + 
  facet_wrap(~newsgroup)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/ggwordcloud-1.png" width="672" />


## TF-IDF



```r
tf_idf <- words_by_newsgroup %>% 
  bind_tf_idf(word, newsgroup, n) %>%
  arrange(desc(tf_idf))

glimpse(tf_idf)
```

```
## Rows: 8,124
## Columns: 6
## $ newsgroup <chr> "rec.autos", "sci.crypt", "comp.sys.ibm.pc.hardware", "rec.s~
## $ word      <chr> "car", "pad", "cpu", "pts", "homosexuals", "widget", "messag~
## $ n         <int> 11, 20, 11, 17, 19, 18, 31, 12, 13, 15, 16, 20, 8, 27, 9, 13~
## $ tf        <dbl> 0.04150943, 0.03115265, 0.03005464, 0.02698413, 0.02613480, ~
## $ idf       <dbl> 2.302585, 2.995732, 2.995732, 2.995732, 2.995732, 2.995732, ~
## $ tf_idf    <dbl> 0.09557900, 0.09332499, 0.09003567, 0.08083722, 0.07829287, ~
```



```r
tf_idf %>%
  filter(str_detect(newsgroup, "^sci\\.")) %>%
  group_by(newsgroup) %>%
  slice_max(tf_idf, n=12) %>%
  ungroup() %>%
  mutate(word = reorder(word,tf_idf)) %>%
  ggplot(aes(tf_idf, word, fill=newsgroup)) +
  geom_col(show.legend = FALSE) + 
  facet_wrap(~newsgroup, scales = "free") + 
  labs(x="tf-idf", 
       y=NULL)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/tfidf_viz-1.png" width="672" />

we want to know which newsgroup is more similar based on the words they use. 


```r
newsgroup_cors <- words_by_newsgroup %>%
  pairwise_cor(newsgroup, word,n,sort=TRUE)

newsgroup_cors
```

```
## # A tibble: 380 x 3
##    item1                    item2                    correlation
##    <chr>                    <chr>                          <dbl>
##  1 talk.religion.misc       soc.religion.christian         0.258
##  2 soc.religion.christian   talk.religion.misc             0.258
##  3 soc.religion.christian   alt.atheism                    0.207
##  4 alt.atheism              soc.religion.christian         0.207
##  5 comp.sys.ibm.pc.hardware comp.sys.mac.hardware          0.204
##  6 comp.sys.mac.hardware    comp.sys.ibm.pc.hardware       0.204
##  7 talk.religion.misc       alt.atheism                    0.170
##  8 alt.atheism              talk.religion.misc             0.170
##  9 comp.graphics            comp.os.ms-windows.misc        0.149
## 10 comp.os.ms-windows.misc  comp.graphics                  0.149
## # ... with 370 more rows
```



