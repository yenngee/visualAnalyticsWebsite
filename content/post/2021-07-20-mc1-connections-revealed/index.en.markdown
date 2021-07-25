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
---

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/vis/vis.css" rel="stylesheet" />

<script src="{{< blogdown/postref >}}index.en_files/vis/vis.min.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/visNetwork-binding/visNetwork.js"></script>

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

#### View connections by Email Headers

<iframe src="https://yenngee-dataviz.shinyapps.io/email_headers/" width="700" height="500&quot;">

</iframe>

We make the following observations (some of them may be relevant to our assignment, some may not)

  - There are some typical work related emails that the admin/IT sends to everyone such as
      - “Good morning, GasTech\!”
      - “Daily morning announcements”
      - "Upcoming birthdays
  - What’s interesting is that the Facilities tend to send many emails to each other like “Don’t text and drive\!”, “Traffic advisory for today”, “Safety First\!”, “Be Careful\!”, however, there are some emails which they leave out certain people \* Left out Varro Awelon, Janittor: “Funny\!\!”
      - Left out Betrand Ovan, Facilities Group Manager with “Route suggestion for next shift”
      - Left out Claudio Hawelon, Truck Driver, Union Meeting
      - Left out 4 people who are male, but the email header is “Guys night out - sorry, ladies”
  - Each department have their own communications
      - Engineering: “Field work rotation schedule”, “Wellhead flow rate data”
      - Security: “Inspection request for site”
      - Administration: “Training opportunity”, “Catering?\!?\!”
      - Executive: “Impact of local politics on profit margin”, “Yearly numbers looking good”
  - Non-work related
      - sent within Administration dept: “Babysitting recommendations” , “Too funy - you have to see this…”, “Does anyone have…”, “Coupon club”, “Craft night”
  - Some suspicious

### Connection Amongst People

The data preparation for this can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/#people-relationships)

``` r
# Nodes 
people_nodes <- read_rds("data/people_nodes.rds") %>% 
  rename(label = name)
people_nodes
```

    ## # A tibble: 69 x 5
    ##       id FirstName LastName       group   label                 
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

``` r
#Edges

people_edges <- read_rds("data/people_edges.rds") %>%
    mutate(smooth = TRUE) # Additional terms for the visualization
people_edges 
```

    ## # A tibble: 23 x 8
    ## # Groups:   LastName [9]
    ##    from_label         LastName to_label            from    to label sum   smooth
    ##    <chr>              <chr>    <chr>              <int> <int> <chr> <chr> <lgl> 
    ##  1 "Loreto Bodrogi  " Bodrogi  "Henk Bodrogi  "      38    55 fami~ 93    TRUE  
    ##  2 "Birgitta Frente ~ Frente   "Vira Frente  "        9    53 fami~ 62    TRUE  
    ##  3 "Benito Hawelon  " Hawelon  "Claudio Hawelon ~     7    13 fami~ 20    TRUE  
    ##  4 "Linda Lagos  "    Lagos    "Varja Lagos  "       36    51 fami~ 87    TRUE  
    ##  5 "Henk Mies  "      Mies     "Minke Mies  "        23    42 fami~ 65    TRUE  
    ##  6 "Adan Morlun  "    Morlun   "Valeria Morlun  "     2    50 fami~ 52    TRUE  
    ##  7 "Elsa Orilla  "    Orilla   "Kare Orilla  "       18    33 fami~ 51    TRUE  
    ##  8 "Hennie Osvaldo  " Osvaldo  "Carmine Osvaldo ~    24    56 fami~ 80    TRUE  
    ##  9 "Edvard Vann  "    Vann     "Isia Vann  "         17    31 fami~ 48    TRUE  
    ## 10 "Edvard Vann  "    Vann     "Mandor Vann  "       17    59 fami~ 76    TRUE  
    ## # ... with 13 more rows

We can see the network visualization here.

``` r
visNetwork(people_nodes %>% filter(id %in% c(people_edges$from, people_edges$to)), people_edges) %>%
  visIgraphLayout(layout = "layout_with_fr")%>%
  visOptions(highlightNearest=TRUE, 
             nodesIdSelection=TRUE)%>%
  visLayout(randomSeed=123)
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[2,7,9,13,17,18,23,24,31,33,36,38,42,50,51,53,55,56,59,67,68,69],"FirstName":["Adan","Benito","Birgitta","Claudio","Edvard","Elsa","Henk","Hennie","Isia","Kare","Linda","Loreto","Minke","Valeria","Varja","Vira","Henk","Carmine","Mandor","Lemual","Neske","Juliana"],"LastName":["Morlun","Hawelon","Frente","Hawelon","Vann","Orilla","Mies","Osvaldo","Vann","Orilla","Lagos","Bodrogi","Mies","Morlun","Lagos","Frente","Bodrogi","Osvaldo","Vann","Vann","Vann","Vann"],"group":["GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","POK","POK","POK","Public","Public","Public"],"label":["Adan Morlun  ","Benito Hawelon  ","Birgitta Frente  ","Claudio Hawelon  ","Edvard Vann  ","Elsa Orilla  ","Henk Mies  ","Hennie Osvaldo  ","Isia Vann  ","Kare Orilla  ","Linda Lagos  ","Loreto Bodrogi  ","Minke Mies  ","Valeria Morlun  ","Varja Lagos  ","Vira Frente  ","Henk Bodrogi  ","Carmine Osvaldo  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  "],"x":[0.968456986070093,-0.441400152359699,0.452258199325338,-0.387818614466412,-0.694317643657744,-1,0.13243473030557,0.373928140132715,-0.537859954909693,-0.915734136674226,0.887090614001545,0.34374508874898,0.403675561108874,1,0.953280142121253,0.297300684016847,0.0991356857191659,0.111129095240452,-0.856191067875633,-0.858943849536692,-0.701641601335733,-0.544680152102978],"y":[-0.446480321556667,0.903972371395941,-0.490890977954853,0.654666616308148,-0.292565810414165,0.368198424047197,-1,0.935618604940904,-0.562268861242328,0.601801933991713,0.54112733963661,0.393992111279822,-0.970912563147888,-0.193286939823975,0.296260982575926,-0.283129867387025,0.285656536292004,1,-0.543448933620163,-0.369679847422966,-0.63733483355934,-0.389380243045301]},"edges":{"from_label":["Loreto Bodrogi  ","Birgitta Frente  ","Benito Hawelon  ","Linda Lagos  ","Henk Mies  ","Adan Morlun  ","Elsa Orilla  ","Hennie Osvaldo  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Isia Vann  ","Isia Vann  ","Isia Vann  ","Isia Vann  ","Mandor Vann  ","Mandor Vann  ","Mandor Vann  ","Lemual Vann  ","Lemual Vann  ","Neske Vann  "],"LastName":["Bodrogi","Frente","Hawelon","Lagos","Mies","Morlun","Orilla","Osvaldo","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann"],"to_label":["Henk Bodrogi  ","Vira Frente  ","Claudio Hawelon  ","Varja Lagos  ","Minke Mies  ","Valeria Morlun  ","Kare Orilla  ","Carmine Osvaldo  ","Isia Vann  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Neske Vann  ","Juliana Vann  ","Juliana Vann  "],"from":[38,9,7,36,23,2,18,24,17,17,17,17,17,31,31,31,31,59,59,59,67,67,68],"to":[55,53,13,51,42,50,33,56,31,59,67,68,69,59,67,68,69,67,68,69,68,69,69],"label":["family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family"],"sum":["93","62","20","87","65","52","51","80","48","76","84","85","86","90","98","99","100","126","127","128","135","136","137"],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["GASTech","POK","Public"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"}},"evals":[],"jsHooks":[]}</script>
