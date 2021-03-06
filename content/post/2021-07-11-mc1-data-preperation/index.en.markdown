---
title: 'MC1: Data Preperation'
author: "Ng Yen Ngee"
date: '2021-07-22'
lastmod: '2021-07-25'
slug: []
cover: "/img/data_preperation.jpg"
categories: []
tags: ['MITB', 'Text Analytics', "MC1"]
output:
  blogdown::html_page: 
    toc: true
---





# Introduction 
In this post, I will be running through the Data Preparation for completing [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). The analysis done after preparing the data can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/). 

The data preparation for the news articles will be done in different parts: 

1. Loading all text articles into 1 dataframe then cleaning the data frame. 
2. Loading Email headers and GAS tech employees 
3. Creating people_record tibble that summarizes the people and relationships in this scenario

## Import packages 


```r
library(tidyverse)
library(readxl)
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
After loading the data, the next step is to clean the data.

* **clean date**: We know that the most problematic column is the date column. There are several formats of dates within the column, at the same time, some of the dates can only be extracted from the main text. Hence we will need to clean them. Below are some of the steps we take. 
* **set lowercase**: we want to be a little more consistent 
* **replace nouns**: we know that there are certain words that makes sense when they are put together but when we tokenize the text, these words become butchered and lose their meaning. E.g. Protectors of Kronos, when tokenize becomes protectors, kronos, the of disappears because it is a stop word. kronos is the place and thus removes the meaning from it. protectors on its own do not mean much. 


```r
# clean date 
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

# set lower case 
cleaned_text <- raw_text %>%
  select(-published) %>%
  mutate(location = tolower(location), 
         title = tolower(title), 
         text = tolower(text))

# replace nouns 
raw_text$text <- str_replace(raw_text$text, "protectors of kronos", "pok")
raw_text$text <- str_replace(raw_text$text, "elian karel", "elian_karel")
raw_text$text <- str_replace(raw_text$text, "elian ", "elian_karel")
raw_text$text <- str_replace(raw_text$text, " karel", "elian_karel")


# output to .rds file for future use in other posts. 
write_rds(cleaned_text, "data/news_article_clean.rds")

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
  filter(word == 'pok') %>%
  arrange(source)
```

```
## # A tibble: 28 x 3
##    source                word      n
##    <chr>                 <chr> <int>
##  1 All News Today        pok      13
##  2 Athena Speaks         pok      29
##  3 Central Bulletin      pok      20
##  4 Centrum Sentinel      pok       1
##  5 Daily Pegasus         pok      26
##  6 Everyday News         pok      18
##  7 Homeland Illumination pok      30
##  8 International News    pok      27
##  9 International Times   pok      18
## 10 Kronos Star           pok      41
## # ... with 18 more rows
```

```r
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
count_words <- bigrams_filtered%>% 
  count(word, sort=TRUE)

wordcloud(words = count_words$word, 
          freq = count_words$n, 
          max.words = 50)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/visualize_bigrams-1.png" width="672" />

## email 

* Load GASTech Employees. 
* Cleaned up the dates 
* Created id, label from `EmailAddress`such that it can also be used as nodes in network analysis 


```r
gastech_employee <- read_excel('data/EmployeeRecords.xlsx', sheet = "Employee Records")
gastech_employee <- gastech_employee %>%
  mutate(label = str_replace(str_extract(EmailAddress, "[^@]+"), '[.]', ' '), 
         Birthdate = as.Date(BirthDate, format="%Y-%m-%d"),
         PassportIssueDate = as.Date(PassportIssueDate, format="%Y-%m-%d") ) %>%
  arrange(label)%>% 
  rowid_to_column("id")

write_rds(gastech_employee, "data/gastech_employees.rds") 

gastech_employee %>%
  arrange(LastName)
```

```
## # A tibble: 54 x 21
##       id LastName FirstName BirthDate           BirthCountry Gender
##    <int> <chr>    <chr>     <dttm>              <chr>        <chr> 
##  1    39 Alcazar  Lucas     1990-04-17 00:00:00 Tethys       Male  
##  2    19 Arpa     Emile     1992-10-01 00:00:00 Kronos       Male  
##  3    52 Awelon   Varro     1986-05-05 00:00:00 Kronos       Male  
##  4    34 Azada    Lars      1973-04-30 00:00:00 Tethys       Male  
##  5    20 Balas    Felix     1960-03-04 00:00:00 Tethys       Male  
##  6    27 Barranco Ingrid    1961-10-26 00:00:00 Tethys       Female
##  7    29 Baza     Isak      1979-02-12 00:00:00 Tethys       Male  
##  8    37 Bergen   Linnea    1969-07-10 00:00:00 Tethys       Female
##  9    38 Bodrogi  Loreto    1989-04-17 00:00:00 Kronos       Male  
## 10    30 Borrasca Isande    1979-10-22 00:00:00 Tethys       Female
## # ... with 44 more rows, and 15 more variables: CitizenshipCountry <chr>,
## #   CitizenshipBasis <chr>, CitizenshipStartDate <dttm>, PassportCountry <chr>,
## #   PassportIssueDate <date>, PassportExpirationDate <dttm>,
## #   CurrentEmploymentType <chr>, CurrentEmploymentTitle <chr>,
## #   CurrentEmploymentStartDate <dttm>, EmailAddress <chr>,
## #   MilitaryServiceBranch <chr>, MilitaryDischargeType <chr>,
## #   MilitaryDischargeDate <dttm>, label <chr>, Birthdate <date>
```

* Load their emails headers 
* cleaned the dates
* added source and target using id from the `gastech_employee` dataframe



```r
raw_email_df <- read_csv('data/email headers.csv')
# raw_email_df

email_df <- raw_email_df %>% 
  separate_rows("To", sep=", ") %>%
  filter(From != To) %>% 
  mutate(From = str_replace(str_extract(From, "[^@]+"), '[.]', ' '),
         To = str_replace(str_extract(To, "[^@]+"), '[.]', ' '),
         Date = as.Date(Date, format="%d/%m/%Y"),
         Subject = str_replace(Subject, "RE: ", "")) %>%
  left_join(gastech_employee %>% select(label, id), by = c("From" = "label")) %>%
  rename(source = id) %>%
  left_join(gastech_employee %>% select(label, id), by = c("To" = "label")) %>% 
  rename(target = id) 

email_df
```

```
## # A tibble: 8,185 x 6
##    From          To           Date       Subject                   source target
##    <chr>         <chr>        <date>     <chr>                      <int>  <int>
##  1 Varja Lagos   Hennie Osva~ 2014-06-01 Patrol schedule changes       51     24
##  2 Varja Lagos   Loreto Bodr~ 2014-06-01 Patrol schedule changes       51     38
##  3 Varja Lagos   Inga Ferro   2014-06-01 Patrol schedule changes       51     26
##  4 Brand Tempes~ Birgitta Fr~ 2014-06-01 Wellhead flow rate data       10      9
##  5 Brand Tempes~ Lars Azada   2014-06-01 Wellhead flow rate data       10     34
##  6 Brand Tempes~ Felix Balas  2014-06-01 Wellhead flow rate data       10     20
##  7 Isak Baza     Lucas Alcaz~ 2014-06-01 GT-SeismicProcessorPro B~     29     39
##  8 Lucas Alcazar Isak Baza    2014-06-01 GT-SeismicProcessorPro B~     39     29
##  9 Linnea Bergen Rachel Pant~ 2014-06-01 Upcoming birthdays            37     45
## 10 Linnea Bergen Lars Azada   2014-06-01 Upcoming birthdays            37     34
## # ... with 8,175 more rows
```

```r
write_rds(email_df, "data/gastech_emails.rds") 
```


## people relationships 

We start off from the gastech employees, because we have the entire name list. 


```r
people_df <- gastech_employee  %>% 
  select(FirstName, LastName) %>% 
  mutate(organization = 'GASTech')

glimpse(people_df)
```

```
## Rows: 54
## Columns: 3
## $ FirstName    <chr> "Ada", "Adan", "Adra", "Albina", "Anda", "Axel", "Benito"~
## $ LastName     <chr> "Campo-Corrente", "Morlun", "Nubarron", "Hafon", "Ribera"~
## $ organization <chr> "GASTech", "GASTech", "GASTech", "GASTech", "GASTech", "G~
```

Next from the literature review, we are able to extract some names and their organizations. 


```r
other_people <- tribble(
  ~FirstName, ~LastName, ~organization,
  "Henk", "Bodrogi", 'POK',
  "Carmine",  "Osvaldo", 'POK',
  'Elian', 'Karel', 'POK',
  'Silvia', 'Marek', 'POK', 
  'Mandor', 'Vann', 'POK', 
  'Petrus', 'Gerhard', 'Homeland Illumination',
  'Lorenzo Di', 'Stefano', 'Public',
  'Kyrla', 'Halford', 'Public', 
  'Fredrick N.', 'Wagner', 'Public', 
  'Westly B.', 'Andrews', 'Public',
  'Hank', 'Fluss', 'GASTech', 
  'Cesare', 'Nespola', 'Government', 
  'Lemual', 'Vann', 'Public', 
  'Neske', 'Vann', 'Public', 
  'Juliana', 'Vann', 'Public', 
)
other_people
```

```
## # A tibble: 15 x 3
##    FirstName   LastName organization         
##    <chr>       <chr>    <chr>                
##  1 Henk        Bodrogi  POK                  
##  2 Carmine     Osvaldo  POK                  
##  3 Elian       Karel    POK                  
##  4 Silvia      Marek    POK                  
##  5 Mandor      Vann     POK                  
##  6 Petrus      Gerhard  Homeland Illumination
##  7 Lorenzo Di  Stefano  Public               
##  8 Kyrla       Halford  Public               
##  9 Fredrick N. Wagner   Public               
## 10 Westly B.   Andrews  Public               
## 11 Hank        Fluss    GASTech              
## 12 Cesare      Nespola  Government           
## 13 Lemual      Vann     Public               
## 14 Neske       Vann     Public               
## 15 Juliana     Vann     Public
```

We combine the data frames together below: 


```r
people_df <- people_df %>%
  bind_rows(other_people) %>%
  mutate(name = paste(FirstName, LastName, ' ')) %>% 
  rowid_to_column('id') %>%
  rename(group=organization)

write_rds(people_df, "data/people_nodes.rds")

people_df
```

```
## # A tibble: 69 x 5
##       id FirstName LastName       group   name                  
##    <int> <chr>     <chr>          <chr>   <chr>                 
##  1     1 Ada       Campo-Corrente GASTech "Ada Campo-Corrente  "
##  2     2 Adan      Morlun         GASTech "Adan Morlun  "       
##  3     3 Adra      Nubarron       GASTech "Adra Nubarron  "     
##  4     4 Albina    Hafon          GASTech "Albina Hafon  "      
##  5     5 Anda      Ribera         GASTech "Anda Ribera  "       
##  6     6 Axel      Calzas         GASTech "Axel Calzas  "       
##  7     7 Benito    Hawelon        GASTech "Benito Hawelon  "    
##  8     8 Bertrand  Ovan           GASTech "Bertrand Ovan  "     
##  9     9 Birgitta  Frente         GASTech "Birgitta Frente  "   
## 10    10 Brand     Tempestad      GASTech "Brand Tempestad  "   
## # ... with 59 more rows
```




```r
family_df <- people_df %>% 
  group_by(LastName) %>% 
  filter(n()>1) %>%
  arrange(LastName)

family_df <- family_df %>%
  select(name, LastName) %>%
  left_join(family_df %>% select(name, LastName), by = "LastName") %>%
  filter(name.x != name.y) %>%
  rename(from_label = name.x, to_label = name.y) %>%
  
  mutate(label = "family")

write_rds(family_df, "data/people_edges.rds")

family_df
```

```
## # A tibble: 46 x 4
## # Groups:   LastName [9]
##    from_label          LastName to_label            label 
##    <chr>               <chr>    <chr>               <chr> 
##  1 "Loreto Bodrogi  "  Bodrogi  "Henk Bodrogi  "    family
##  2 "Henk Bodrogi  "    Bodrogi  "Loreto Bodrogi  "  family
##  3 "Birgitta Frente  " Frente   "Vira Frente  "     family
##  4 "Vira Frente  "     Frente   "Birgitta Frente  " family
##  5 "Benito Hawelon  "  Hawelon  "Claudio Hawelon  " family
##  6 "Claudio Hawelon  " Hawelon  "Benito Hawelon  "  family
##  7 "Linda Lagos  "     Lagos    "Varja Lagos  "     family
##  8 "Varja Lagos  "     Lagos    "Linda Lagos  "     family
##  9 "Henk Mies  "       Mies     "Minke Mies  "      family
## 10 "Minke Mies  "      Mies     "Henk Mies  "       family
## # ... with 36 more rows
```
