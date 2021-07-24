---
title: 'MC1: Connections Revealed'
author: 'Ng Yen Ngee'
date: '2021-07-18'
lastmod: '2021-07-25'
slug: []
cover: "/img/connections.jpg"
categories: []
tags: ['MITB', 'Text Analytics', "MC1"]
output:
  blogdown::html_page: 
    toc: true
runtime: shiny
---

# Introduction

In this post, I will be running through the revaluation of connections as part of completing [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). The analysis done after preparing the data can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/).

Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. Include both personal relationships and shared goals and objectives.

## Preperation

### Import packages

``` r
library(tidyverse)
library(tidygraph)   # for tbl_graph
library(igraph)      # network viz
library(ggraph)      # network viz
library(visNetwork)  # support interactivity
library(shiny)       # for the inbuilt shinyApp
```

### Load Data

The data has been previously loaded, cleaned and transformed into a neat tibble dataframe [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/).
We load the cleaned data directly below:

``` r
# Nodes 
gastech_employees <- read_rds("data/gastech_employees.rds") %>% 
  rename(department = CurrentEmploymentType, 
         title = CurrentEmploymentTitle, 
         citizenship = CitizenshipCountry) %>% 
  select(id, label, department, title, citizenship)
gastech_employees 
```

    ## # A tibble: 54 x 5
    ##       id label              department     title                    citizenship
    ##    <int> <chr>              <chr>          <chr>                    <chr>      
    ##  1     1 Ada Campo-Corrente Executive      SVP/CIO                  Tethys     
    ##  2     2 Adan Morlun        Facilities     Truck Driver             Kronos     
    ##  3     3 Adra Nubarron      Engineering    Geologist                Tethys     
    ##  4     4 Albina Hafon       Facilities     Truck Driver             Kronos     
    ##  5     5 Anda Ribera        Administration Assistant to CFO         Tethys     
    ##  6     6 Axel Calzas        Engineering    Drill Technician         Tethys     
    ##  7     7 Benito Hawelon     Facilities     Truck Driver             Kronos     
    ##  8     8 Bertrand Ovan      Facilities     Facilities Group Manager Tethys     
    ##  9     9 Birgitta Frente    Engineering    Geologist                Tethys     
    ## 10    10 Brand Tempestad    Engineering    Drill Technician         Tethys     
    ## # ... with 44 more rows

``` r
# Edges 
gastech_emails <- read_rds("data/gastech_emails.rds")
gastech_emails
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

``` r
gastech_edges <- gastech_emails %>% 
  group_by(source, target) %>% 
  summarize(weight=n()) %>%
  filter(weight>1) %>%
  ungroup() %>% 
  mutate(from = source, to = target)

gastech_edges
```

    ## # A tibble: 1,264 x 5
    ##    source target weight  from    to
    ##     <int>  <int>  <int> <int> <int>
    ##  1      1      2      2     1     2
    ##  2      1      3      2     1     3
    ##  3      1      4      2     1     4
    ##  4      1      5      2     1     5
    ##  5      1      6      2     1     6
    ##  6      1      7      2     1     7
    ##  7      1      8      2     1     8
    ##  8      1      9      2     1     9
    ##  9      1     10      2     1    10
    ## 10      1     11      2     1    11
    ## # ... with 1,254 more rows

``` r
gastech_graph <- tbl_graph(nodes = gastech_employees, 
                           edges = gastech_edges, 
                           directed = TRUE)
gastech_graph
```

    ## # A tbl_graph: 54 nodes and 1264 edges
    ## #
    ## # A directed simple graph with 1 component
    ## #
    ## # Node Data: 54 x 5 (active)
    ##      id label              department     title            citizenship
    ##   <int> <chr>              <chr>          <chr>            <chr>      
    ## 1     1 Ada Campo-Corrente Executive      SVP/CIO          Tethys     
    ## 2     2 Adan Morlun        Facilities     Truck Driver     Kronos     
    ## 3     3 Adra Nubarron      Engineering    Geologist        Tethys     
    ## 4     4 Albina Hafon       Facilities     Truck Driver     Kronos     
    ## 5     5 Anda Ribera        Administration Assistant to CFO Tethys     
    ## 6     6 Axel Calzas        Engineering    Drill Technician Tethys     
    ## # ... with 48 more rows
    ## #
    ## # Edge Data: 1,264 x 5
    ##    from    to source target weight
    ##   <int> <int>  <int>  <int>  <int>
    ## 1     1     2      1      2      2
    ## 2     1     3      1      3      2
    ## 3     1     4      1      4      2
    ## # ... with 1,261 more rows

## Analyze Connections

### Let’s visualize it

``` r
g <- ggraph(gastech_graph, layout = 'nicely') + 
  geom_edge_link() +
  geom_node_point(aes(colour = department))

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/employees_emails-1.png" width="672" />

#### Shiny app

<iframe data-deferred-src="appe4bd19e8fe92aef0ce5634325e2ac8fa/?w=&amp;__subapp__=1" width="100%" height="500" class="shiny-frame shiny-frame-deferred"></iframe>

### Let’s pick out the subjects

``` r
length(unique(gastech_emails$Subject))
```

    ## [1] 158

``` r
gastech_emails %>%
  group_by(Subject, Date) %>%
  summarize(n())
```

    ## # A tibble: 242 x 3
    ## # Groups:   Subject [158]
    ##    Subject                                              Date       `n()`
    ##    <chr>                                                <date>     <int>
    ##  1 2497-00 Initial flow rates                           NA             6
    ##  2 2497-00 Perforation                                  NA            22
    ##  3 2516-00 openhole logging results                     2014-10-01    12
    ##  4 2516-00 openhole logging results                     NA            41
    ##  5 Action: Review network logs                          NA            18
    ##  6 Action: Virus detected on your system                NA            57
    ##  7 All staff announcement                               2014-06-01    53
    ##  8 Anyone have a spare monitor?                         2014-08-01    10
    ##  9 Anyone have time to help on a project?               NA            24
    ## 10 Anyone have time to help troubleshoot some software? 2014-10-01     8
    ## # ... with 232 more rows
