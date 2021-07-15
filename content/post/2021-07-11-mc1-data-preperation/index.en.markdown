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
           location = str_match(text, "LOCATION:\\s*(.*?)\\s*NEWLINE")[,2], 
           author = str_match(text, "AUTHOR:\\s*(.*?)\\s*NEWLINE")[,2]) %>% 
    # Remove the information from the text column 
    mutate(text = str_replace(text, "SOURCE:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "TITLE:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "PUBLISHED:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "LOCATION:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace(text, "AUTHOR:\\s*(.*?)\\s*NEWLINE", "")) %>% 
    mutate(text = str_replace_all(text, "NEWLINE", ""))
}

raw_text <- tibble(folder = dir(new_article_folder, full.names=TRUE)) %>%
  mutate(folder_out = map(folder, read_folder)) %>%
  unnest(cols = c(folder_out)) %>%
  mutate(article_id = paste(source, str_match(id, "[0-9]+"), sep="_")) %>%
  transmute(source, article_id, text, title, published, location, author) 

#output a rds file to read them easily. 
write_rds(raw_text, "data/news_article_raw.rds")
```



```r
raw_text <- read_rds("data/news_article_raw.rds")
glimpse(raw_text)
```

```
## Rows: 845
## Columns: 7
## $ source     <chr> "All News Today", "All News Today", "All News Today", "All ~
## $ article_id <chr> "All News Today_121", "All News Today_135", "All News Today~
## $ text       <chr> "  Fifteen members of the Protectors of Kronos (POK) activi~
## $ title      <chr> "POK PROTESTS END IN ARRESTS", "RALLY SCHEDULED IN SUPPORT ~
## $ published  <chr> "2005/04/06", "2012/04/09", "1993/02/02", "Petrus Gerhard",~
## $ location   <chr> "ELODIS, Kronos", "ABILA, Kronos", "ABILA, Kronos", "ELODIS~
## $ author     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
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

raw_text$text <- str_replace(raw_text$text, "^[0-9]{4}/[0-9]{2}/[0-9]{2}", "")
raw_text$text <- str_replace(raw_text$text, "^[0-9]{2} [A-Za-z]+ [0-9]{4}", "")
                  
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
## Columns: 7
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ article_id     <chr> "All News Today_121", "All News Today_135", "All News T~
## $ text           <chr> "  Fifteen members of the Protectors of Kronos (POK) ac~
## $ title          <chr> "POK PROTESTS END IN ARRESTS", "RALLY SCHEDULED IN SUPP~
## $ location       <chr> "elodis, kronos", "abila, kronos", "abila, kronos", "el~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
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
## Rows: 54,658
## Columns: 7
## $ source     <chr> "All News Today", "All News Today", "All News Today", "All ~
## $ article_id <chr> "All News Today_121", "All News Today_121", "All News Today~
## $ title      <chr> "POK PROTESTS END IN ARRESTS", "POK PROTESTS END IN ARRESTS~
## $ published  <chr> "2005/04/06", "2005/04/06", "2005/04/06", "2005/04/06", "20~
## $ location   <chr> "ELODIS, Kronos", "ELODIS, Kronos", "ELODIS, Kronos", "ELOD~
## $ author     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
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
## # A tibble: 22,235 x 9
##    source   article_id   title     published location author word1 word2 word   
##    <chr>    <chr>        <chr>     <chr>     <chr>    <chr>  <chr> <chr> <chr>  
##  1 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   kron~ pok   kronos~
##  2 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   pok   acti~ pok ac~
##  3 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   acti~ orga~ activi~
##  4 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   kron~ fede~ kronos~
##  5 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   fede~ poli~ federa~
##  6 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   poli~ yest~ police~
##  7 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   tisk~ bend  tiskel~
##  8 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   bend  gast~ bend g~
##  9 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   gast~ faci~ gastec~
## 10 All New~ All News To~ POK PROT~ 2005/04/~ ELODIS,~ <NA>   faci~ sway~ facili~
## # ... with 22,225 more rows
```


```r
cleaned_text %>% 
  group_by(title) %>%
  filter(n()>1) %>% 
  summarize(n=n()) %>%
  arrange(desc(n))
```

```
## # A tibble: 115 x 2
##    title                                                                       n
##    <chr>                                                                   <int>
##  1 VOICES - a blog about what is important to the people                      37
##  2 Breaking: Emergency at GAStech Headquarters Building [Updates]             35
##  3 VOICES - a blog on what is important to people                             32
##  4 ON SCENE BLOG                                                              30
##  5 ON THE SCENE BLOG                                                          30
##  6 To break off itself: The emergency to GAStech quarters construction [u~    28
##  7 Profile:  Elian Karel                                                       6
##  8 ANNIVERSARY OF PROTESTS                                                     5
##  9 POSSIBLE CONTAMINATION IN ELODIS                                            5
## 10 A LOOK BACK AT A LIFE CUT TRAGICAL SHORT: ELIAN KAREL                       4
## # ... with 105 more rows
```


```r
cleaned_text %>%
  group_by(title) %>%
  add_count(source) %>%
  ungroup() %>%
  # filter(n()>1) %>% 
  arrange(desc(n)) %>%
  select(source, title, article_id)
```

```
## # A tibble: 845 x 3
##    source            title                                  article_id          
##    <chr>             <chr>                                  <chr>               
##  1 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  2 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  3 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  4 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  5 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  6 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  7 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  8 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
##  9 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
## 10 Homeland Illumin~ VOICES - a blog about what is importa~ Homeland Illuminati~
## # ... with 835 more rows
```
