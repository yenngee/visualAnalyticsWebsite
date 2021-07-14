---
title: 'MC1: Data Preperation'
author: "Ng Yen Ngee"
date: '2021-07-11'
lastmod: '2021-07-15'
slug: []
cover: "/img/data_preperation.jpg"
categories: []
tags: ['MITB', 'Text Analytics', "Kronos Kidnapping"]
output:
  blogdown::html_page: 
    toc: true
---





# Introduction 
In this post, I will be running through the Data Preparation for completing [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). The analysis done after preparing the data can be found [here](). 
The data preparation for the news articles will be done by 2 parts. 

1. Loading all text articles into 1 dataframe 
2. Tokenizing the text and cleaning the text tokens. 

## Import packages 


```r
library(tidyverse)
library(tidytext)
library(lubridate)
library(naniar)
library(wordcloud)
library(ggwordcloud)
```

## Preparing News Articles 
### Understanding the Data 

In our News Articles folder, we have 29 folders. Each representing a single type of news article. 

![](image/news_article_folder.JPG)<!-- -->

When we click into one of the folders, we can see text documents. Each text document represent a single article. 

![](image/news_article_articles.JPG)<!-- -->

This is how a single article look like: 

![](image/news_article_single.JPG)<!-- -->

With a quick check of some of the articles, we can see that they generally follow a template. The articles usually consist of: 

*SOURCE: which is the news article name
*TITLE: title of article
*PUBLISHED: usually date of article. Though in some articles it is the author of the article 
*LOCATION: usually location. Sometimes the title of the article is duplicated. 
*text: this is the actual body of the article. Sometimes the date can be found at the start of the text body. 

With this in mind, we set out to read the data and clean them into a dataframe. 

### Reading the Data

We first create a function that reads all 

The second chunk of code, loads all of the news articles by folder 

```r
read_folder <- function(infolder) {
  tibble(file=dir(infolder, 
                  full.names=TRUE)) %>% 
    mutate(text = map(file, read_lines)) %>%
    transmute(id = basename(file), text) %>%
    unnest(text)%>% 
    group_by(id) %>% 
    summarize(text = paste(text, collapse="NEWLINE")) %>%
    ungroup() %>% 
    # Extract information from the text column
    mutate(source = str_match(text, "SOURCE:\\s*(.*?)\\s*NEWLINE")[,2], 
           title = str_match(text, "TITLE:\\s*(.*?)\\s*NEWLINE")[,2], 
           published = str_match(text, "PUBLISHED:\\s*(.*?)\\s*NEWLINE")[,2], 
           location = str_match(text, "LOCATION:\\s*(.*?)\\s*NEWLINE")[,2]) %>% 
    # Remove the information from the text column 
    mutate(text = str_replace(text, "SOURCE:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "TITLE:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "PUBLISHED:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "LOCATION:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace_all(text, "NEWLINE", ""))
}

raw_text <- tibble(folder = dir(new_article_folder, full.names=TRUE)) %>%
  mutate(folder_out = map(folder, read_folder)) %>%
  unnest(cols = c(folder_out)) %>%
  mutate(article_id = paste(source, str_match(id, "[0-9]+"), sep="_")) %>%
  transmute(source, article_id, text, title, published, location) 

#output a rds file to read them easily. 
write_rds(raw_text, "data/news_article_raw.rds")
```



```r
raw_text <- read_rds("data/news_article_raw.rds")
glimpse(raw_text)
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

```r
# unique(raw_text$published)
```

### Clean data 
We know that the most problematic column is the date column. There are several formats of dates within the column, at the same time, some of the dates can only be extracted from the main text. Hence we will need to clean them. 


```r
date_a <- as.Date(raw_text$published,format="%Y/%m/%d")
date_b <- as.Date(raw_text$published,format="%d %B %Y")
date_c <- as.Date(raw_text$published,format="%B %d, %Y")
date_d <- as.Date(str_match(raw_text$text, "^[0-9]{4}/[0-9]{2}/[0-9]{2}"), format="%Y/%m/%d")
date_e <- as.Date(str_match(raw_text$text, "^[0-9]{2} [A-Za-z]+ [0-9]{4}"), format="%d %B %Y")
                  
date_a[is.na(date_a)] <- date_b[is.na(date_a)]
date_a[is.na(date_a)] <- date_c[is.na(date_a)]
date_a[is.na(date_a)] <- date_d[is.na(date_a)]
date_a[is.na(date_a)] <- date_e[is.na(date_a)]

raw_text$published_date <- date_a

cleaned_text <- raw_text %>%
  select(-published) %>%
  mutate(location = tolower(location)) # %>%
  # replace_with_na(replace = list(location = c("elodis, kronos", "abila, kronos" , "centrum, tethys" , "davos, switzerland")))

write_rds(cleaned_text, "data/news_article_clean.rds")

glimpse(cleaned_text)
```

```
## Rows: 845
## Columns: 6
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ article_id     <chr> "All News Today_121", "All News Today_135", "All News T~
## $ text           <chr> "  Fifteen members of the Protectors of Kronos (POK) ac~
## $ title          <chr> "POK PROTESTS END IN ARRESTS", "RALLY SCHEDULED IN SUPP~
## $ location       <chr> "elodis, kronos", "abila, kronos", "abila, kronos", "el~
## $ published_date <date> 2005-04-06, 2012-04-09, 1993-02-02, 1998-03-20, 1998-0~
```


```r
cleaned_text <- read_rds("data/news_article_raw.rds")
```

### Tokenising 


```r
custom_stop_words <- tribble(
  ~word, ~lexicon,
  "kronos", "CUSTOM",
  "abila",  "CUSTOM"
)
stop_words2 <- stop_words %>%
  bind_rows(custom_stop_words)

token_words <- cleaned_text %>% 
  unnest_tokens(word, text) %>%
  filter(str_detect(word, "[a-z']$"), # only keep words. exclude all numeric. 
         !word %in% stop_words2$word) # to remove stop words 

write_rds(token_words, "data/news_article_token_words.rds")

glimpse(token_words)
```

```
## Rows: 55,014
## Columns: 6
## $ source     <chr> "All News Today", "All News Today", "All News Today", "All ~
## $ article_id <chr> "All News Today_121", "All News Today_121", "All News Today~
## $ title      <chr> "POK PROTESTS END IN ARRESTS", "POK PROTESTS END IN ARRESTS~
## $ published  <chr> "2005/04/06", "2005/04/06", "2005/04/06", "2005/04/06", "20~
## $ location   <chr> "ELODIS, Kronos", "ELODIS, Kronos", "ELODIS, Kronos", "ELOD~
## $ word       <chr> "fifteen", "protectors", "pok", "activist", "organization",~
```


```r
count_words <- token_words %>% 
  count(word, sort=TRUE)

wordcloud(words = count_words$word, 
          freq = count_words$n, 
          max.words = 50)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/visualize_words-1.png" width="672" />


```r
set.seed(1234)

words_by_articles <- token_words %>% 
  count(source, word, sort=TRUE) %>% 
  ungroup()

words_by_articles %>%
  filter(n>20) %>%
  ggplot(aes(label=word, size = n)) + 
  geom_text_wordcloud() + 
  theme_minimal() + 
  facet_wrap(~source)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/words_for_each_article-1.png" width="672" />

### bigrams 


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

write_rds(token_words, "data/news_article_bigrams.rds")

bigrams_filtered
```

```
## # A tibble: 22,573 x 8
##    source   article_id   title       published  location   word1 word2  word    
##    <chr>    <chr>        <chr>       <chr>      <chr>      <chr> <chr>  <chr>   
##  1 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ kron~ pok    kronos ~
##  2 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ pok   activ~ pok act~
##  3 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ acti~ organ~ activis~
##  4 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ kron~ feder~ kronos ~
##  5 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ fede~ police federal~
##  6 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ poli~ yeste~ police ~
##  7 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ tisk~ bend   tiskele~
##  8 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ bend  gaste~ bend ga~
##  9 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ gast~ facil~ gastech~
## 10 All New~ All News To~ POK PROTES~ 2005/04/06 ELODIS, K~ faci~ swayi~ facilit~
## # ... with 22,563 more rows
```

