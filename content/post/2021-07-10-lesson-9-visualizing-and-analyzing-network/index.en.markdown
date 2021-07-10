---
title: "Lesson 9 visualizing and Analyzing Network"
author: "Ng Yen Ngee"
date: '2021-07-10'
slug: []
cover: "/img/network_analysis.png"
categories: []
tags: ["R", "network analysis", "MITB"]
output:
  blogdown::html_page: 
    toc: true
---



## Introduction to in-class exercise 9
As part of my lesson in SMU Visual Analytics, prof teaches data visualization in R using Rmarkdown. The post below acts as both an in-class exercise for the lesson, as well as my notes. 

Note to prof, if he is here: I have reorganized the in class exercise in a way that makes sense to me, but may not follow the step by step process prof went through in class. I have added additional items which I have kept as haphazard notes on my desktop.  Hope this is alright! 

## Preperation 
### Loading packages

Our very first step of course is to load the packages that would be useful for us especially [tidygraph](https://www.data-imaginist.com/2017/introducing-tidygraph/)


```r
library(tidyverse)
library(tidygraph)   # 
library(igraph)      #
library(ggraph)      #
library(visNetwork)  # support interactivity
library(lubridate)
library(clock)
```


### Loading data 

The data loaded here has been cleaned by our professor and it is already in the format required for the network analysis. Prof will run through how to create the data on another day. 

#### edges data
min. requirement for edge data is to have 2 columns: source and target. 


```r
GAStech_edges <- read_csv("data/GAStech_email_edge-v2.csv")

#some of the data is still a little dirty, especially wrt the data type
GAStech_edges$SentDate <- dmy(GAStech_edges$SentDate) #convert to date time format 
GAStech_edges$Weekday = wday(GAStech_edges$SentDate, label=TRUE, abbr=FALSE) # extract day of week 

glimpse(GAStech_edges)
```

```
## Rows: 9,063
## Columns: 9
## $ source      <dbl> 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 26, 26, 26~
## $ target      <dbl> 41, 40, 51, 52, 53, 45, 44, 46, 48, 49, 47, 54, 27, 28, 29~
## $ SentDate    <date> 2014-01-06, 2014-01-06, 2014-01-06, 2014-01-06, 2014-01-0~
## $ SentTime    <time> 08:39:00, 08:39:00, 08:58:00, 08:58:00, 08:58:00, 08:58:0~
## $ Subject     <chr> "GT-SeismicProcessorPro Bug Report", "GT-SeismicProcessorP~
## $ MainSubject <chr> "Work related", "Work related", "Work related", "Work rela~
## $ sourceLabel <chr> "Sven.Flecha", "Sven.Flecha", "Kanon.Herrero", "Kanon.Herr~
## $ targetLabel <chr> "Isak.Baza", "Lucas.Alcazar", "Felix.Resumir", "Hideki.Coc~
## $ Weekday     <ord> Monday, Monday, Monday, Monday, Monday, Monday, Monday, Mo~
```


```r
GAStech_edges_agg <- GAStech_edges %>%
  filter(MainSubject == "Work related") %>%
  group_by(source, target, Weekday) %>%
  summarise(Weight=n()) %>%   # counts the number of times the source sent to the target in each Weekday
  filter(source!=target) %>%  #to avoid emails being sent to themselves. 
  filter(Weight>1) %>% 
  ungroup()

glimpse(GAStech_edges_agg)
```

```
## Rows: 1,456
## Columns: 4
## $ source  <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,~
## $ target  <dbl> 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7,~
## $ Weekday <ord> Monday, Tuesday, Wednesday, Friday, Monday, Tuesday, Wednesday~
## $ Weight  <int> 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4,~
```

#### Nodes data

nodes --> min. requirement for nodes data is ID. It is a good practice to add a label so that we put meaning. 
The important thing is that the source and target columns in edge should correspond to the id in nodes


```r
GAStech_nodes <- read_csv("data/GAStech_email_node.csv")
glimpse(GAStech_nodes)
```

```
## Rows: 54
## Columns: 4
## $ id         <dbl> 1, 2, 3, 4, 5, 6, 7, 44, 45, 46, 8, 9, 10, 11, 12, 13, 14, ~
## $ label      <chr> "Mat.Bramar", "Anda.Ribera", "Rachel.Pantanal", "Linda.Lago~
## $ Department <chr> "Administration", "Administration", "Administration", "Admi~
## $ Title      <chr> "Assistant to CEO", "Assistant to CFO", "Assistant to CIO",~
```

## Build the Network Graph 

From the tidygraph, we use `tbl_graph` to create the network graph. We need to fill in 3 attributes: `nodes`, `edges` and `directed`. 


```r
GAStech_graph <- tbl_graph(nodes = GAStech_nodes, 
                          edges = GAStech_edges_agg, 
                          directed = TRUE)
GAStech_graph
```

```
## # A tbl_graph: 54 nodes and 1456 edges
## #
## # A directed multigraph with 1 component
## #
## # Node Data: 54 x 4 (active)
##      id label               Department     Title                                
##   <dbl> <chr>               <chr>          <chr>                                
## 1     1 Mat.Bramar          Administration Assistant to CEO                     
## 2     2 Anda.Ribera         Administration Assistant to CFO                     
## 3     3 Rachel.Pantanal     Administration Assistant to CIO                     
## 4     4 Linda.Lagos         Administration Assistant to COO                     
## 5     5 Ruscella.Mies.Haber Administration Assistant to Engineering Group Manag~
## 6     6 Carla.Forluniau     Administration Assistant to IT Group Manager        
## # ... with 48 more rows
## #
## # Edge Data: 1,456 x 4
##    from    to Weekday   Weight
##   <int> <int> <ord>      <int>
## 1     1     2 Monday         4
## 2     1     2 Tuesday        3
## 3     1     2 Wednesday      5
## # ... with 1,453 more rows
```


First we need to choose the Graph Layout. Need to understand the different layout and how it is suited for what we want to show. 

![](image/layout_types.JPG)<!-- -->
We can also can view the layouts in [`ggraph`](https://www.data-imaginist.com/2017/ggraph-introduction-layouts/)


Next we can choose the visual attributes. 

![](image/visual_attributes.JPG)<!-- -->


