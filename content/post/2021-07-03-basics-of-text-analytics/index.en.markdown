---
title: "Basics of Text Analytics"
author: Ng Yen Ngee
date: '2021-06-23'
lastmod: '2021-07-03'
slug: []
cover: "/img/text_analytics.jpg"
categories: []
tags: ['Kronos Kidnapping', 'assignment', 'MITB', 'Text Analytics']
output:
  blogdown::html_page: 
    toc: true
---







# Why am I doing this? 
I am a student studying Masters of IT in Business 
Unfortunately I am not a pro in text analytics and have to learn everything from scratch. Fortunately, our lovely prof gave us access to Datacamp.com which is a pretty cool way to learn this. 

So the objective of this post is to apply everything that I have to learn, documenting each step, explaining the reasons behind each step onto the dataset that I actually need to analyse for my assignment, so that I can kill two birds with one stone. :)  

Thus the following disclaimer: 
The following methods used are learn from datacamp.com and obviously I don't own it. 

Let's start! 

## Preperation 

### Loading packages

Our very first step of course is to load the packages that would be useful for us. 


```r
library(tidyverse)
library(tidytext)
library(textdata)
```

* tidyverse: there are many reasons why this is such an awesome package which you can easily find online. Meanwhile, trust that we need to use this for text analytics 


### Import data 

This set of data is obtained by scrapping through 845 text files. I will run through how I did it here (which will be updated in the future hahaha).


```r
articles_data <- read_csv(new_article_conn)
articles_data$published_date <- as.Date(articles_data$published_date, "%d/%m/%Y")
articles_data <- articles_data %>% 
  dplyr::select(source, published_date, location, title, author, text)

glimpse(articles_data)
```

```
## Rows: 845
## Columns: 6
## $ source         <chr> "All News Today", "All News Today", "All News Today", "~
## $ published_date <date> 2005-04-06, 2012-04-09, 1993-02-02, 1998-03-20, 1998-0~
## $ location       <chr> "ELODIS, Kronos", "ABILA, Kronos", "ABILA, Kronos", "EL~
## $ title          <chr> "POK PROTESTS END IN ARRESTS", "RALLY SCHEDULED IN SUPP~
## $ author         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
## $ text           <chr> "Fifteen members of the Protectors of Kronos (POK) acti~
```

 We made it into a structure with the following features: 

* source: newspaper brand 
* index: text file number 
* published_date: published date of the article 
* location: some of the articles stated a location, though there are mostly null values in this column 
* title: title of the article 
* text: text of the article itself of varying length 
* author: author of the article. Not all articles have this information 

As with all data analysis, it would be prudent to run some exploratory data analysis, to understand the data and know which columns would be useful and which would not be. 

### Simple exploration of data
Let's take a look at each columns breakdown using `count` function: 



```r
articles_data %>% count(source, sort=TRUE)
```

```
## # A tibble: 29 x 2
##    source                    n
##    <chr>                 <int>
##  1 News Online Today       111
##  2 Homeland Illumination    64
##  3 Kronos Star              62
##  4 The Abila Post           54
##  5 Centrum Sentinel         36
##  6 Tethys News              35
##  7 Modern Rubicon           30
##  8 The Guide                28
##  9 The Truth                28
## 10 Worldwise                28
## # ... with 19 more rows
```

```r
articles_data %>% count(location, sort=TRUE)
```

```
## # A tibble: 20 x 2
##    location                                                                    n
##    <chr>                                                                   <int>
##  1 "ABILA, Kronos"                                                           408
##  2  <NA>                                                                     298
##  3 "ELODIS, Kronos"                                                           66
##  4 "CENTRUM, Tethys"                                                          50
##  5 "Abila, Kronos"                                                             6
##  6 "DAVOS, Switzerland"                                                        3
##  7 "\"Today we gather to remember Elian Karel,\" Silvia Marek told the ra~     1
##  8 "POK have denied the cause are of the attack, and the government Krono~     1
##  9 "SALANIAU, FERDINAND / DOB: 2/17/1982 / Time of Arrest: 0832 hrs / Acc~     1
## 10 "SALANIAU, FERDINAND/DOB: 2/17/1982/Tiempo of the halting: 0832 hours/~     1
## 11 "The post of Abila will send Haneson Ngohebo, ignited writer of the Bl~     1
## 12 "This Article is the second of  three"                                      1
## 13 "This is the first confirmation that today's events surrounding GAStec~     1
## 14 "TITLE: Abila police break up sit"                                          1
## 15 "TITLE: ARREST BLOTTER OF THE POLICE FORCE KRONOS"                          1
## 16 "TITLE: GOVERNMENT STANDS UP ANTI"                                          1
## 17 "TITLE: GRAND OPENING GASTECH"                                              1
## 18 "TITLE: KRONOS POLICE ARREST BLOTTER"                                       1
## 19 "TITLE: Multi"                                                              1
## 20 "TITLE: The movement of the block"                                          1
```

```r
articles_data %>% count(author, sort=TRUE)
```

```
## # A tibble: 9 x 2
##   author                             n
##   <chr>                          <int>
## 1 <NA>                             719
## 2 Maha Salo                         46
## 3 Cato Rossini, Marcella Trapani    35
## 4 Petrus Gerhard                    18
## 5 Marcella Trapani                  13
## 6 Donato Petri                       5
## 7 Eva Thayer                         5
## 8 Lelio Masin                        3
## 9 Cato Rossini                       1
```

```r
summary(articles_data$published_date)
```

```
##         Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
## "1982-10-02" "2000-10-04" "2011-07-28" "2007-11-15" "2014-01-20" "2014-03-26"
```

However, we are unable to see the columns breakdown for "title" or "text" column since each row is unique. This is because it is considered as unstructured data. Part of the text analytics is to turn unstructured data to a structured one. 

## Basics of Text analytics 
### Tokenizing and cleaning
Concept of Tokenizing, creating a bag of words: 
* in a text, each unique word is a term 
* each occurrence of a term is a token 
* want to count the number of occurrences of a term --> hence creating bag of words 


```r
#### Step 1: tokenize the column 
text_tokens <- articles_data %>% 
  unnest_tokens(word, text) 
# the first input must be word to tokenize word. second input is the column name we want to tokenize.

#### Step 2: let's count it 
text_tokens %>%
  count(word) %>%
  arrange(desc(n))
```

```
## # A tibble: 6,495 x 2
##    word        n
##    <chr>   <int>
##  1 the     11549
##  2 of       7912
##  3 to       3816
##  4 and      3031
##  5 in       2539
##  6 a        2374
##  7 that     1403
##  8 kronos   1282
##  9 gastech  1206
## 10 for      1103
## # ... with 6,485 more rows
```

However, we can see a lot of common words like 'the', 'of', 'and' which does not give us any important information. These are called stop words. Fortunately, our lovely package actually has a variable called `stop_words` which is a tibble that contains all these words. Now let's remove these stop words from our own tibble. 


```r
#### Step 1: tokenize + remove stop words using anti-join
text_tokens <- articles_data %>% 
  unnest_tokens(word, text) %>%
  anti_join(stop_words)
# the first input must be word to tokenize word. second input is the column name we want to tokenize.

#### Step 2: let's count it again
text_word_count <- text_tokens %>%
  count(word) %>%
  arrange(desc(n))

#### step 3: let's visualize it! 
text_word_count %>%
  filter(n>300) %>%
  mutate(word = fct_reorder(word,n)) %>%
  ggplot(aes(x = word, y=n)) +
  geom_col() + 
  coord_flip() + 
  ggtitle("Article Text Word Count")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/token no stopwords-1.png" width="672" />

Which tells us a lot more information. 


```r
#### Step 0: create new stop words
custom_stop_words <- tribble(
  ~word, ~lexicon,
  "kronos", "CUSTOM",
  "abila",  "CUSTOM"
)
stop_words2 <- stop_words %>%
  bind_rows(custom_stop_words)

#### Step 1: tokenize + remove stop words using anti-join
text_tokens <- articles_data %>% 
  unnest_tokens(word, text) %>%
  anti_join(stop_words2)
# the first input must be word to tokenize word. second input is the column name we want to tokenize.

#### Step 2: let's count it again
text_word_count <- text_tokens %>%
  count(word) %>%
  arrange(desc(n))

#### step 3: let's visualize it! 
text_word_count %>%
  filter(n>300) %>%
  mutate(word = fct_reorder(word,n)) %>%
  ggplot(aes(x = word, y=n)) +
  geom_col() + 
  coord_flip() + 
  ggtitle("Article Text Word Count")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/token custom stopwords-1.png" width="672" />

```r
text_tokens %>%
  count(word, source) %>%
  group_by(source) %>%
  top_n(10,n) %>%
  ungroup() %>%
  mutate(word = fct_reorder(word,n)) %>%
  ggplot(aes(x = word, y=n, fill=source)) +
  geom_col(show.legend = FALSE) + 
  facet_wrap( ~ source, scales = "free_y") +
  coord_flip() + 
  ggtitle("Article Text Word Count by each Source")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/token custom stopwords-2.png" width="672" />

We can also visualize this using `wordcloud()`


```r
library(wordcloud)

word_counts <- text_tokens %>%
  count(word)

wordcloud(words = word_counts$word, 
          freq = word_counts$n, 
          max.words = 30)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/wordcloud-1.png" width="672" />

### Sentiment Analysis

Sentiment Analysis is done by defining a particular sentiment to words. Thankfully, we have are in-built dictionaries in `tidytext` package. 

#### Sentiment dictionary 

There are 4 dictionaries with different definitions of sentiments. 


```r
## bing dictionary
# assigns words into positive and negative categories
get_sentiments("bing")
```

```
## # A tibble: 6,786 x 2
##    word        sentiment
##    <chr>       <chr>    
##  1 2-faces     negative 
##  2 abnormal    negative 
##  3 abolish     negative 
##  4 abominable  negative 
##  5 abominably  negative 
##  6 abominate   negative 
##  7 abomination negative 
##  8 abort       negative 
##  9 aborted     negative 
## 10 aborts      negative 
## # ... with 6,776 more rows
```

```r
get_sentiments("bing") %>% count(sentiment)
```

```
## # A tibble: 2 x 2
##   sentiment     n
##   <chr>     <int>
## 1 negative   4781
## 2 positive   2005
```

```r
## Afinn dictionary 
# assigns words with a score that runs between -5 and 5, with negative scores indicating negative sentiment and positive scores indicating positive sentiment
get_sentiments("afinn")
```

```
## # A tibble: 2,477 x 2
##    word       value
##    <chr>      <dbl>
##  1 abandon       -2
##  2 abandoned     -2
##  3 abandons      -2
##  4 abducted      -2
##  5 abduction     -2
##  6 abductions    -2
##  7 abhor         -3
##  8 abhorred      -3
##  9 abhorrent     -3
## 10 abhors        -3
## # ... with 2,467 more rows
```

```r
get_sentiments("afinn") %>% summarize(min=min(value), max=max(value))
```

```
## # A tibble: 1 x 2
##     min   max
##   <dbl> <dbl>
## 1    -5     5
```

```r
## NRC dictionary 
# assigns words into one or more of the following ten categories: positive, negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust
get_sentiments("nrc")
```

```
## # A tibble: 13,901 x 2
##    word        sentiment
##    <chr>       <chr>    
##  1 abacus      trust    
##  2 abandon     fear     
##  3 abandon     negative 
##  4 abandon     sadness  
##  5 abandoned   anger    
##  6 abandoned   fear     
##  7 abandoned   negative 
##  8 abandoned   sadness  
##  9 abandonment anger    
## 10 abandonment fear     
## # ... with 13,891 more rows
```

```r
get_sentiments("nrc") %>% count(sentiment)
```

```
## # A tibble: 10 x 2
##    sentiment        n
##    <chr>        <int>
##  1 anger         1247
##  2 anticipation   839
##  3 disgust       1058
##  4 fear          1476
##  5 joy            689
##  6 negative      3324
##  7 positive      2312
##  8 sadness       1191
##  9 surprise       534
## 10 trust         1231
```

```r
#Loughran dictionary
get_sentiments("loughran")
```

```
## # A tibble: 4,150 x 2
##    word         sentiment
##    <chr>        <chr>    
##  1 abandon      negative 
##  2 abandoned    negative 
##  3 abandoning   negative 
##  4 abandonment  negative 
##  5 abandonments negative 
##  6 abandons     negative 
##  7 abdicated    negative 
##  8 abdicates    negative 
##  9 abdicating   negative 
## 10 abdication   negative 
## # ... with 4,140 more rows
```

```r
get_sentiments("loughran") %>% count(sentiment)
```

```
## # A tibble: 6 x 2
##   sentiment        n
##   <chr>        <int>
## 1 constraining   184
## 2 litigious      904
## 3 negative      2355
## 4 positive       354
## 5 superfluous     56
## 6 uncertainty    297
```

#### Appending Sentiments 
We need to join the sentiments dictionary to our `text_tokens` dataframe. If we count or find the distribution of the sentiment/value, we would be able to understand what is the general sentiment of each category, in this case, each article. 


```r
sentiment_review <- text_tokens %>% 
  inner_join(get_sentiments("bing"))

sentiment_review %>% 
  count(sentiment) 
```

```
## # A tibble: 2 x 2
##   sentiment     n
##   <chr>     <int>
## 1 negative   3733
## 2 positive   1753
```

```r
sentiment_review <- text_tokens %>% 
  inner_join(get_sentiments("afinn"))

sentiment_review %>% 
  count(value)
```

```
## # A tibble: 8 x 2
##   value     n
##   <dbl> <int>
## 1    -4     9
## 2    -3   882
## 3    -2  2190
## 4    -1   922
## 5     1   797
## 6     2  1086
## 7     3   193
## 8     4    21
```

```r
sentiment_review <- text_tokens %>% 
  inner_join(get_sentiments("nrc"))

sentiment_review %>% 
  count(sentiment)
```

```
## # A tibble: 10 x 2
##    sentiment        n
##    <chr>        <int>
##  1 anger         2247
##  2 anticipation  2382
##  3 disgust       1452
##  4 fear          4606
##  5 joy           1377
##  6 negative      5744
##  7 positive      6414
##  8 sadness       2217
##  9 surprise      1311
## 10 trust         4397
```

```r
sentiment_review <- text_tokens %>% 
  inner_join(get_sentiments("loughran"))

sentiment_review %>% 
  count(sentiment)
```

```
## # A tibble: 6 x 2
##   sentiment        n
##   <chr>        <int>
## 1 constraining   159
## 2 litigious      468
## 3 negative      3609
## 4 positive       611
## 5 superfluous      1
## 6 uncertainty    359
```

code to visualize using graph:


```r
word_counts <- sentiment_review %>%
  filter(sentiment %in% c("positive", "negative")) %>% 
  count(word, sentiment) %>%
  group_by(sentiment) %>%
  top_n(10, n) %>%
  ungroup() %>%
  mutate(word = fct_reorder(word, n))

ggplot(word_counts, aes(x = word, y = n, fill = sentiment)) +
geom_col(show.legend = FALSE) +
facet_wrap(~ sentiment, scales = "free") +
coord_flip() +
labs(
title = "Sentiment Word Counts",
x = "Words"
)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/visualize_sentiment-1.png" width="672" />

#### comparing sentiments across groups in data 


```r
sentiment_by_grp <- sentiment_review %>%
  filter(sentiment %in% c("positive", "negative")) %>%
  count(source, sentiment) %>%
  spread(sentiment,n) %>% 
  mutate(overall_sentiment = positive-negative, 
         source = fct_reorder(source, overall_sentiment))
sentiment_by_grp
```

```
## # A tibble: 29 x 4
##    source                negative positive overall_sentiment
##    <fct>                    <int>    <int>             <int>
##  1 All News Today              71       14               -57
##  2 Athena Speaks              179        8              -171
##  3 Central Bulletin           143        7              -136
##  4 Centrum Sentinel            24        5               -19
##  5 Daily Pegasus              140       42               -98
##  6 Everyday News              156       36              -120
##  7 Homeland Illumination      205       43              -162
##  8 International News          86        9               -77
##  9 International Times        133       27              -106
## 10 Kronos Star                172       25              -147
## # ... with 19 more rows
```


```r
sentiment_by_grp %>% 
  ggplot(aes(x = source, y = overall_sentiment, fill = as.factor(source))) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Overall Sentiment by Article",
    subtitle = "Words in articles",
    x = "Article",
    y = "Overall Sentiment"
    )
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/sentiment_by_group_viz-1.png" width="672" />

  
