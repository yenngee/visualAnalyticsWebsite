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

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/vis/vis.css" rel="stylesheet" />

<script src="{{< blogdown/postref >}}index.en_files/vis/vis.min.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/visNetwork-binding/visNetwork.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/vis/vis.css" rel="stylesheet" />

<script src="{{< blogdown/postref >}}index.en_files/vis/vis.min.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/visNetwork-binding/visNetwork.js"></script>

# Introduction to in-class exercise 9

As part of my lesson in SMU Visual Analytics, prof teaches data visualization in R using Rmarkdown. The post below acts as both an in-class exercise for the lesson, as well as my notes.

Note to prof, if he is here: I have reorganized the in class exercise in a way that makes sense to me, but may not follow the step by step process prof went through in class. I have added additional items which I have kept as haphazard notes on my desktop. Hope this is alright\!

## Preperation

### Loading packages

Our very first step of course is to load the packages that would be useful for us especially [tidygraph](https://www.data-imaginist.com/2017/introducing-tidygraph/)

``` r
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

``` r
GAStech_edges <- read_csv("data/GAStech_email_edge-v2.csv")

#some of the data is still a little dirty, especially wrt the data type
GAStech_edges$SentDate <- dmy(GAStech_edges$SentDate) #convert to date time format 
GAStech_edges$Weekday = wday(GAStech_edges$SentDate, label=TRUE, abbr=FALSE) # extract day of week 

glimpse(GAStech_edges)
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

``` r
GAStech_edges_agg <- GAStech_edges %>%
  filter(MainSubject == "Work related") %>%
  group_by(source, target, Weekday) %>%
  summarise(Weight=n()) %>%   # counts the number of times the source sent to the target in each Weekday
  filter(source!=target) %>%  #to avoid emails being sent to themselves. 
  filter(Weight>1) %>% 
  ungroup()

glimpse(GAStech_edges_agg)
```

    ## Rows: 1,456
    ## Columns: 4
    ## $ source  <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,~
    ## $ target  <dbl> 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7,~
    ## $ Weekday <ord> Monday, Tuesday, Wednesday, Friday, Monday, Tuesday, Wednesday~
    ## $ Weight  <int> 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4, 3, 5, 8, 4,~

#### Nodes data

nodes –\> min. requirement for nodes data is ID. It is a good practice to add a label so that we put meaning.
The important thing is that the source and target columns in edge should correspond to the id in nodes

``` r
GAStech_nodes <- read_csv("data/GAStech_email_node.csv")
glimpse(GAStech_nodes)
```

    ## Rows: 54
    ## Columns: 4
    ## $ id         <dbl> 1, 2, 3, 4, 5, 6, 7, 44, 45, 46, 8, 9, 10, 11, 12, 13, 14, ~
    ## $ label      <chr> "Mat.Bramar", "Anda.Ribera", "Rachel.Pantanal", "Linda.Lago~
    ## $ Department <chr> "Administration", "Administration", "Administration", "Admi~
    ## $ Title      <chr> "Assistant to CEO", "Assistant to CFO", "Assistant to CIO",~

## Build the Network Graph

From the tidygraph, we use `tbl_graph` to create the network graph. We need to fill in 3 attributes: `nodes`, `edges` and `directed`.

``` r
GAStech_graph <- tbl_graph(nodes = GAStech_nodes, 
                          edges = GAStech_edges_agg, 
                          directed = TRUE)
GAStech_graph
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

First we need to choose the Graph Layout. Need to understand the different layout and how it is suited for what we want to show.

![](image/layout_types.JPG)<!-- -->

We can also can view the layouts in [`ggraph`](https://www.data-imaginist.com/2017/ggraph-introduction-layouts/)

Next we can choose the visual attributes.

![](image/visual_attributes.JPG)<!-- -->

### Basic Network Graph

We start off with a basic network graph, not definiting any layout nor visual attributes.

``` r
ggraph(GAStech_graph) + 
  geom_edge_link() +
  geom_node_point()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/basic-1.png" width="672" />

We can’t really get much information out of this except that we know they are connected to each other. XD

### Add theme

``` r
g <- ggraph(GAStech_graph) + 
  geom_edge_link(aes()) +
  geom_node_point(aes())

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/theme-1.png" width="672" />
\#\#\#\# Change Colour

``` r
g <- ggraph(GAStech_graph) + 
  geom_edge_link(aes(colour = 'grey50')) +
  geom_node_point(aes(colour = 'grey40'))

g + theme_graph(background = 'grey30')
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/change_colour-1.png" width="672" />

### Change Layout

we change layout within the `ggraph` function. Below we use Fruchterman and Reingold layout as an example.

``` r
g <- ggraph(GAStech_graph, 
            layout = 'fr') + 
  geom_edge_link(aes()) +
  geom_node_point(aes())

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/change_layout-1.png" width="672" />

### Modifying Nodes

we can modify the nodes using the aes() under the geom\_node\_point().

``` r
g <- ggraph(GAStech_graph, 
            layout = 'nicely') + 
  geom_edge_link(aes()) +
  geom_node_point(aes(colour = Department, size=3))

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/modify_node-1.png" width="672" />

### Modifying Edges

``` r
g <- ggraph(GAStech_graph, 
            layout = 'nicely') + 
  geom_edge_link(aes(width = Weight), 
                 alpha = 0.2) +
  scale_edge_width(range = c(0.1,5)) +
  geom_node_point(aes(colour = Department, size=3))

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/modify_edges-1.png" width="672" />

### Working with facet\_edges()

``` r
set_graph_style()

g <- ggraph(GAStech_graph, 
            layout = 'nicely') + 
  geom_edge_link(aes(width = Weight), 
                 alpha = 0.2) +
  scale_edge_width(range = c(0.1,5)) +
  geom_node_point(aes(colour = Department), size=2) +
  theme(legend.position = 'bottom')  # change legend to bottom

g + facet_edges(~Weekday) +
  th_foreground(foreground = "grey80", border = TRUE) # adding a border 
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/facet_edges-1.png" width="672" />

### Working with facet\_nodes()

``` r
set_graph_style()

g <- ggraph(GAStech_graph, 
            layout = 'nicely') + 
  geom_edge_link(aes(width = Weight), 
                 alpha = 0.2) +
  scale_edge_width(range = c(0.1,5)) +
  geom_node_point(aes(colour = Department), size=2)+
  theme(legend.position = 'bottom') 

g + facet_nodes(~Department) +
  th_foreground(foreground = "grey80", border = TRUE)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/facet_nodes-1.png" width="672" />
**Interpretation**: Interestingly, senior executive don’t really talk to each other on email. There are different levels of communication within different department. e.g. In security department, that there is one group that communicate a lot, and specifically one lone ranger that does not really communicate with the rest of the department.

## Network Metrics Analysis

### Find centrality

To obtain better interpretation of Analysis, we would need a metric for measurement.

  - in-degree/out-degree
  - betweenness: centrality measure of vertex within a graph. Importance of a particular node in connecting between various nodes. if we cut of that node, can we still connect? is it the same connection or longer connection? this measures the questions.
  - closeness: how close one node is to another in terms of connections/links.

`tidygraph` and `igraph` provides many measures of centrality.

``` r
## OLD CODE
# g <- GAStech_graph %>%
#   mutate(betweenness_centrality = centrality_betweenness()) %>% # we mutate to calculate using the centrality_betweenness 
#   ggraph(layout = 'nicely') + 
#   geom_edge_link(aes(width = Weight), 
#                  alpha = 0.2) +
#   scale_edge_width(range = c(0.1,5)) +
#   geom_node_point(aes(colour = Department, size=betweenness_centrality))+ # map the centrality_betweenness to size
#   theme(legend.position = 'bottom') 
# 
# g + theme_graph()

## NEW CODE
g <- GAStech_graph %>%
  ggraph(layout = 'nicely') + 
  geom_edge_link(aes(width = Weight), 
                 alpha = 0.2) +
  scale_edge_width(range = c(0.1,5)) +
  geom_node_point(aes(colour = Department, size=centrality_betweenness())) + # map the centrality_betweenness to size
  theme(legend.position = 'bottom') 

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/metrics_old_mthd-1.png" width="672" />

**Interpretation**: we can see the 2 guys in the middle from department administration has the highest connection within the organization.

### Find Community

``` r
## OLD CODE
g <- GAStech_graph %>%
  mutate(community = as.factor(group_edge_betweenness(weights = Weight, directed=TRUE))) %>% # we mutate to calculate using the centrality_betweenness
  ggraph(layout = 'fr') +
  geom_edge_link(aes(width = Weight),
                 alpha = 0.2) +
  scale_edge_width(range = c(0.1,5)) +
  geom_node_point(aes(colour = community)) # map the community to colour

g + theme_graph()
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/community-1.png" width="672" />

In this case, the number of communities is too high and too granular. We should explore other method to detect community.
we can also use facet\_node, to view the networks in each community. :)

## Interactive Network Graph

This section here mostly use the package [`visNetwork`](https://datastorm-open.github.io/visNetwork/). This package is also compatible to Shiny.

### Changes to the data

The data required is slightly different in that the edge must have “from” and “to” columns, ‘label’ must also be in node list.

``` r
GAStech_edges_agg_viz <- GAStech_edges %>%
  left_join(GAStech_nodes, by = c("sourceLabel" = "label")) %>%
  rename(from = id) %>%
  left_join(GAStech_nodes, by = c("targetLabel" = "label")) %>%
  rename(to = id)  %>%
  filter(MainSubject == "Work related") %>%
  group_by(from,to) %>%
  summarise(weight = n()) %>%
  filter(from!=to) %>%
  filter(weight>1) %>%
  ungroup()

glimpse(GAStech_edges_agg_viz)
```

    ## Rows: 839
    ## Columns: 3
    ## $ from   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ~
    ## $ to     <dbl> 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,~
    ## $ weight <int> 21, 21, 21, 21, 21, 21, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,~

### Basic Interactive Graph

``` r
visNetwork(GAStech_nodes, GAStech_edges_agg_viz) %>%
  visIgraphLayout(layout = "layout_with_fr")
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,44,45,46,8,9,10,11,12,13,14,15,16,21,26,17,18,19,20,39,40,41,42,43,27,28,29,47,48,49,50,22,51,52,53,54,23,24,25,30,31,32,33,34,35,36,37,38],"label":["Mat.Bramar","Anda.Ribera","Rachel.Pantanal","Linda.Lagos","Ruscella.Mies.Haber","Carla.Forluniau","Cornelia.Lais","Kanon.Herrero","Varja.Lagos","Stenig.Fusil","Marin.Onda","Axel.Calzas","Brand.Tempestad","Elsa.Orilla","Isande.Borrasca","Kare.Orilla","Felix.Balas","Lars.Azada","Lidelse.Dedos","Willem.Vasco-Pais","Bertrand.Ovan","Adra.Nubarron","Birgitta.Frente","Gustav.Cazar","Vira.Frente","Linnea.Bergen","Lucas.Alcazar","Isak.Baza","Nils.Calixto","Sven.Flecha","Emile.Arpa","Varro.Awelon","Dante.Coginian","Edvard.Vann","Hennie.Osvaldo","Isia.Vann","Minke.Mies","Sten.Sanjorge.Jr","Felix.Resumir","Hideki.Cocinaro","Inga.Ferro","Loreto.Bodrogi","Ingrid.Barranco","Ada.Campo-Corrente","Orhan.Strum","Adan.Morlun","Albina.Hafon","Benito.Hawelon","Cecilia.Morluniau","Claudio.Hawelon","Dylan.Scozzese","Henk.Mies","Irene.Nant","Valeria.Morlun"],"Department":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"Title":["Assistant to CEO","Assistant to CFO","Assistant to CIO","Assistant to COO","Assistant to Engineering Group Manager","Assistant to IT Group Manager","Assistant to Security Group Manager","Badging Office","Badging Office","Building Control","Drill Site Manager","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Engineer","Engineer","Engineering Group Manager","Environmental Safety Advisor","Facilities Group Manager","Geologist","Geologist","Hydraulic Technician","Hydraulic Technician","IT Group Manager","IT Helpdesk","IT Technician","IT Technician","IT Technician","Janitor","Janitor","Lead Janitor","Perimeter Control","Perimeter Control","Perimeter Control","Perimeter Control","President/CEO","Security Group Manager","Site Control","Site Control","Site Control","SVP/CFO","SVP/CIO","SVP/COO","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver"],"x":[-0.155759297605,-0.744502755080393,-0.606504730739017,-1,-0.0665885765890478,-0.992140132770159,-0.828896895203501,0.916383182215321,0.741544326540497,0.987678580679639,-0.421503538146874,-0.145108532983757,-0.363324591514206,-0.603652654071134,-0.204210258265221,-0.713894295667666,-0.540212457364898,-0.748021099212245,-0.347151340019704,1,0.193534286123647,-0.123229775579533,-0.689381713865103,-0.491485938009221,-0.127338140414961,-0.954029665654554,-0.013410328224309,0.478295462691274,0.691686528774199,0.316406983569627,-0.198262511455792,-0.541702084826716,0.180034285580432,0.120746296628419,0.077249487050854,0.606063325111603,0.504611990388877,0.658453718641707,0.838462058820383,0.484791507661956,0.653455035805798,0.827149004616005,0.0919398861628933,0.895466031710283,0.739620635907333,-0.171640805646187,-0.37927598825364,-0.388983881480388,0.0634034769727156,-0.173845935001217,0.00463312160801999,-0.00908266269906466,-0.447998399918874,-0.302481763400996],"y":[-0.0097142379976044,-0.00261723851765649,0.193924626781841,-0.118272139864154,0.0328132349494081,0.234766035647522,0.142955293127133,-0.404353145367922,-0.498344223692801,-0.132150632433784,-0.50473949259555,-0.934271706569888,-0.840742075725276,-0.449594291685069,-0.641848034957854,-0.707597856946875,-0.932440088677428,-0.560156320880498,-1,0.293738739201832,0.887758067504188,-0.171936049512923,-0.848430662588564,-0.724061570681492,-0.786897510417344,0.539348067043973,-0.0998982793184963,-0.977138509644202,-0.798504381272648,-0.897867050852989,0.480509271155721,0.778346592565898,0.564287437937836,-0.0975217518472661,-0.026190063603681,-0.311941384310908,-0.541248055227241,0.691565289926566,0.0235302986820476,-0.147947448012666,0.0753548219913693,-0.227226713191943,0.0707651201039825,0.47535401508381,0.476982361144284,1,0.911704066896953,0.513907380837536,0.766772401428369,0.841068588285947,0.95285386985085,0.600998153328464,0.682707375709242,0.733837218349348]},"edges":{"from":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,39,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,42,42,42,42,43,43,43,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54],"to":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,3,4,5,6,7,15,36,38,1,2,4,5,6,7,48,1,2,3,5,6,7,1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,2,3,4,5,7,28,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,27,8,10,11,12,13,14,15,16,17,18,19,20,45,8,9,11,12,13,14,15,16,17,18,19,20,8,9,10,12,13,14,15,16,17,18,19,20,32,8,9,10,11,13,14,15,16,17,18,19,20,52,8,9,10,11,12,14,15,16,17,18,19,20,8,9,10,11,12,13,15,16,17,18,19,20,2,8,9,10,11,12,13,14,16,17,18,19,20,8,9,10,11,12,13,14,15,17,18,19,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,8,9,10,11,12,13,14,15,17,19,20,8,9,10,11,12,13,14,15,16,17,18,20,8,9,10,11,12,13,14,15,16,17,18,19,50,22,23,24,25,53,21,23,24,25,36,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,5,21,22,23,25,21,22,23,24,46,27,28,29,30,31,32,33,34,35,36,37,38,8,28,29,30,31,32,33,34,35,36,37,38,40,6,26,27,29,30,31,32,33,34,35,36,37,38,1,26,27,28,30,31,32,33,34,35,36,37,38,40,51,52,26,27,28,29,31,32,33,34,35,36,37,38,3,27,28,29,30,32,33,34,35,36,37,38,11,26,27,28,29,30,31,33,34,35,36,37,38,23,26,27,28,29,30,31,32,34,35,36,37,38,27,28,29,30,31,32,33,35,36,37,38,26,27,28,29,30,31,32,33,34,36,37,38,2,22,26,27,28,29,30,31,32,33,34,35,37,38,53,26,27,28,29,30,31,32,33,34,35,36,38,27,28,29,30,31,32,34,35,36,34,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,40,42,43,40,41,43,44,40,41,42,42,45,46,47,48,49,50,51,52,53,54,44,46,47,48,49,50,51,52,53,54,44,45,47,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,49,50,51,52,53,54,3,45,46,47,48,52,54,5,20,48,49,53,54,29,44,45,46,47,48,49,50,52,53,54,7,12,29,44,45,46,47,48,49,50,51,53,5,21,36,44,45,47,48,49,50,51,52,54,5,44,45,46,47,48,49,50,51,52,53],"weight":[21,21,21,21,21,21,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,6,6,6,6,9,2,2,2,8,8,8,8,8,8,2,12,12,12,12,12,12,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,10,10,11,11,11,11,11,11,11,11,3,12,15,12,12,12,12,3,4,3,3,4,4,3,3,4,3,4,3,3,4,4,9,4,7,7,11,5,4,5,6,8,3,8,8,7,9,9,6,9,10,10,7,5,7,11,10,11,6,11,7,11,9,10,7,10,8,3,9,10,8,8,11,6,7,5,3,6,5,6,2,9,5,10,7,7,4,3,4,7,2,3,3,6,5,7,4,6,6,7,5,7,6,3,4,3,6,13,8,8,5,6,6,11,9,6,2,7,6,8,7,5,5,7,6,7,7,5,4,6,2,2,2,2,2,2,2,6,4,7,7,6,6,6,6,5,5,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,4,5,3,3,2,5,2,3,2,4,8,5,9,6,5,4,10,7,4,4,5,5,10,5,7,4,5,4,4,4,3,2,4,3,4,2,4,7,2,7,5,10,4,2,4,4,4,4,4,4,4,4,4,4,4,4,6,4,4,4,4,4,4,4,6,10,17,9,4,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,5,9,7,3,8,2,3,4,2,26,25,25,25,25,25,24,25,25,26,25,26,3,4,3,6,4,3,3,6,5,3,4,5,3,3,2,3,6,5,8,6,6,7,4,6,6,6,2,2,6,5,7,5,6,5,7,6,6,5,5,3,2,3,3,5,7,9,12,9,9,6,13,12,9,11,2,5,4,6,6,9,7,6,12,7,7,8,4,2,8,6,9,7,10,7,9,6,10,5,8,2,4,2,3,5,7,8,4,7,5,7,6,4,5,6,4,7,8,5,9,6,6,10,6,3,11,7,9,11,15,7,11,11,9,13,13,2,2,3,12,11,12,16,15,19,12,11,14,11,13,3,3,4,5,6,7,7,6,9,10,7,5,3,2,5,5,2,2,2,4,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,40,22,30,2,2,2,2,2,2,2,2,2,2,2,28,19,24,25,19,28,2,15,16,24,3,4,2,5,6,2,5,5,2,6,3,6,4,2,6,5,5,4,7,5,6,6,3,4,9,5,6,8,7,4,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,5,4,3,7,5,6,6,5,5,5,2,2,4,2,4,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,5,3,8,6,5,5,5,6,2,3,2,3,3,4,2,2,4,2,2,5,2,3,3,3,3,4,4,2,3,3,3,3,2,2,4,2,4,4,3,4,5,3,2,4,3,3,4,3,3,2,5,4,8,2,2,5,2,3,4,3,2,5,4,4,2,3,4]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false}},"groups":null,"width":null,"height":null,"idselection":{"enabled":false},"byselection":{"enabled":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"}},"evals":[],"jsHooks":[]}</script>

### Grouping Nodes

if we create a column called `group` in the node dataframe, then `visNetwork` will be able to automatically colour each category in the `group` field.

``` r
GAStech_nodes$group <- GAStech_nodes$Department

visNetwork(GAStech_nodes, GAStech_edges_agg_viz) %>%
  visIgraphLayout(layout = "layout_with_fr") %>%
  visLegend() %>%
  visLayout(randomSeed=123)
```

<div id="htmlwidget-2" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,44,45,46,8,9,10,11,12,13,14,15,16,21,26,17,18,19,20,39,40,41,42,43,27,28,29,47,48,49,50,22,51,52,53,54,23,24,25,30,31,32,33,34,35,36,37,38],"label":["Mat.Bramar","Anda.Ribera","Rachel.Pantanal","Linda.Lagos","Ruscella.Mies.Haber","Carla.Forluniau","Cornelia.Lais","Kanon.Herrero","Varja.Lagos","Stenig.Fusil","Marin.Onda","Axel.Calzas","Brand.Tempestad","Elsa.Orilla","Isande.Borrasca","Kare.Orilla","Felix.Balas","Lars.Azada","Lidelse.Dedos","Willem.Vasco-Pais","Bertrand.Ovan","Adra.Nubarron","Birgitta.Frente","Gustav.Cazar","Vira.Frente","Linnea.Bergen","Lucas.Alcazar","Isak.Baza","Nils.Calixto","Sven.Flecha","Emile.Arpa","Varro.Awelon","Dante.Coginian","Edvard.Vann","Hennie.Osvaldo","Isia.Vann","Minke.Mies","Sten.Sanjorge.Jr","Felix.Resumir","Hideki.Cocinaro","Inga.Ferro","Loreto.Bodrogi","Ingrid.Barranco","Ada.Campo-Corrente","Orhan.Strum","Adan.Morlun","Albina.Hafon","Benito.Hawelon","Cecilia.Morluniau","Claudio.Hawelon","Dylan.Scozzese","Henk.Mies","Irene.Nant","Valeria.Morlun"],"Department":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"Title":["Assistant to CEO","Assistant to CFO","Assistant to CIO","Assistant to COO","Assistant to Engineering Group Manager","Assistant to IT Group Manager","Assistant to Security Group Manager","Badging Office","Badging Office","Building Control","Drill Site Manager","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Engineer","Engineer","Engineering Group Manager","Environmental Safety Advisor","Facilities Group Manager","Geologist","Geologist","Hydraulic Technician","Hydraulic Technician","IT Group Manager","IT Helpdesk","IT Technician","IT Technician","IT Technician","Janitor","Janitor","Lead Janitor","Perimeter Control","Perimeter Control","Perimeter Control","Perimeter Control","President/CEO","Security Group Manager","Site Control","Site Control","Site Control","SVP/CFO","SVP/CIO","SVP/COO","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver"],"group":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"x":[-0.0255893384602197,0.14526194517041,0.370980085981824,0.621520291501551,0.0985108982909886,0.330684156433985,0.541877196268334,0.842114763578448,0.645019201472383,0.964166966575968,-0.468418712517863,-0.280348505235794,-0.721668461195067,-0.755406689703747,-0.266272040655707,-0.588242084634913,-0.433394746085392,-0.584321442483154,-0.632291049404075,0.976049735945217,-0.11075091447302,-0.114611367875356,-0.47487207154098,-0.787915536642083,-0.185053503189218,-1,-0.0337188320544912,0.316772948334533,0.535514712447883,0.146707997628248,-0.513464522748232,-0.269617046353687,-0.185978893105109,0.0967276455505393,0.173344790662307,0.86767268681801,0.443168163307549,0.704726447770637,0.644260954125958,0.465407603929516,0.694470826804255,0.737095639418447,0.0840586274588793,0.863892565840545,1,-0.60112847205333,-0.589005920869227,-0.683702390157967,-0.412791196466109,-0.730486213432334,-0.459242727617741,-0.0503660091549142,-0.27679542582017,-0.441404423534631],"y":[-0.119336615779705,-0.557082819626121,-0.654195537589883,-0.491037354366161,-0.0683363538153473,-0.924154764126821,-0.67832600471445,0.525475377214052,0.578551694905924,0.287336172798306,0.364633364595189,0.820825099956427,0.700046086120241,0.305079302449556,0.550211351896623,0.831207203683106,0.824023885619379,0.303638202678941,0.556187526416157,-0.417317763294597,-0.975614368034444,0.0929260298458541,0.645849700552446,0.514296251428443,0.709359204505343,-0.133494809003484,0.0167650328254851,1,0.876666477037308,0.931822621687629,-0.41581430196023,-0.992031760069513,-0.498806695648506,0.0785706567383533,0.000535028323397135,0.144429900805271,0.576935035811148,-0.796690568410168,0.132052191504387,0.261440980581424,-0.0483043774230202,0.377327709409937,-0.156014768365505,-0.571203013261949,-0.226813579416168,-0.643347769319398,-0.861968922850517,-0.474625237867431,-0.634489803495529,-0.719624607595827,-1,-0.749051511315441,-0.794488750676184,-0.826241851094078]},"edges":{"from":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,39,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,42,42,42,42,43,43,43,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54],"to":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,3,4,5,6,7,15,36,38,1,2,4,5,6,7,48,1,2,3,5,6,7,1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,2,3,4,5,7,28,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,27,8,10,11,12,13,14,15,16,17,18,19,20,45,8,9,11,12,13,14,15,16,17,18,19,20,8,9,10,12,13,14,15,16,17,18,19,20,32,8,9,10,11,13,14,15,16,17,18,19,20,52,8,9,10,11,12,14,15,16,17,18,19,20,8,9,10,11,12,13,15,16,17,18,19,20,2,8,9,10,11,12,13,14,16,17,18,19,20,8,9,10,11,12,13,14,15,17,18,19,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,8,9,10,11,12,13,14,15,17,19,20,8,9,10,11,12,13,14,15,16,17,18,20,8,9,10,11,12,13,14,15,16,17,18,19,50,22,23,24,25,53,21,23,24,25,36,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,5,21,22,23,25,21,22,23,24,46,27,28,29,30,31,32,33,34,35,36,37,38,8,28,29,30,31,32,33,34,35,36,37,38,40,6,26,27,29,30,31,32,33,34,35,36,37,38,1,26,27,28,30,31,32,33,34,35,36,37,38,40,51,52,26,27,28,29,31,32,33,34,35,36,37,38,3,27,28,29,30,32,33,34,35,36,37,38,11,26,27,28,29,30,31,33,34,35,36,37,38,23,26,27,28,29,30,31,32,34,35,36,37,38,27,28,29,30,31,32,33,35,36,37,38,26,27,28,29,30,31,32,33,34,36,37,38,2,22,26,27,28,29,30,31,32,33,34,35,37,38,53,26,27,28,29,30,31,32,33,34,35,36,38,27,28,29,30,31,32,34,35,36,34,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,40,42,43,40,41,43,44,40,41,42,42,45,46,47,48,49,50,51,52,53,54,44,46,47,48,49,50,51,52,53,54,44,45,47,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,49,50,51,52,53,54,3,45,46,47,48,52,54,5,20,48,49,53,54,29,44,45,46,47,48,49,50,52,53,54,7,12,29,44,45,46,47,48,49,50,51,53,5,21,36,44,45,47,48,49,50,51,52,54,5,44,45,46,47,48,49,50,51,52,53],"weight":[21,21,21,21,21,21,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,6,6,6,6,9,2,2,2,8,8,8,8,8,8,2,12,12,12,12,12,12,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,10,10,11,11,11,11,11,11,11,11,3,12,15,12,12,12,12,3,4,3,3,4,4,3,3,4,3,4,3,3,4,4,9,4,7,7,11,5,4,5,6,8,3,8,8,7,9,9,6,9,10,10,7,5,7,11,10,11,6,11,7,11,9,10,7,10,8,3,9,10,8,8,11,6,7,5,3,6,5,6,2,9,5,10,7,7,4,3,4,7,2,3,3,6,5,7,4,6,6,7,5,7,6,3,4,3,6,13,8,8,5,6,6,11,9,6,2,7,6,8,7,5,5,7,6,7,7,5,4,6,2,2,2,2,2,2,2,6,4,7,7,6,6,6,6,5,5,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,4,5,3,3,2,5,2,3,2,4,8,5,9,6,5,4,10,7,4,4,5,5,10,5,7,4,5,4,4,4,3,2,4,3,4,2,4,7,2,7,5,10,4,2,4,4,4,4,4,4,4,4,4,4,4,4,6,4,4,4,4,4,4,4,6,10,17,9,4,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,5,9,7,3,8,2,3,4,2,26,25,25,25,25,25,24,25,25,26,25,26,3,4,3,6,4,3,3,6,5,3,4,5,3,3,2,3,6,5,8,6,6,7,4,6,6,6,2,2,6,5,7,5,6,5,7,6,6,5,5,3,2,3,3,5,7,9,12,9,9,6,13,12,9,11,2,5,4,6,6,9,7,6,12,7,7,8,4,2,8,6,9,7,10,7,9,6,10,5,8,2,4,2,3,5,7,8,4,7,5,7,6,4,5,6,4,7,8,5,9,6,6,10,6,3,11,7,9,11,15,7,11,11,9,13,13,2,2,3,12,11,12,16,15,19,12,11,14,11,13,3,3,4,5,6,7,7,6,9,10,7,5,3,2,5,5,2,2,2,4,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,40,22,30,2,2,2,2,2,2,2,2,2,2,2,28,19,24,25,19,28,2,15,16,24,3,4,2,5,6,2,5,5,2,6,3,6,4,2,6,5,5,4,7,5,6,6,3,4,9,5,6,8,7,4,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,5,4,3,7,5,6,6,5,5,5,2,2,4,2,4,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,5,3,8,6,5,5,5,6,2,3,2,3,3,4,2,2,4,2,2,5,2,3,3,3,3,4,4,2,3,3,3,3,2,2,4,2,4,4,3,4,5,3,2,4,3,3,4,3,3,2,5,4,8,2,2,5,2,3,4,3,2,5,4,4,2,3,4]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Administration","Security","Engineering","Executive","Facilities","Information Technology"],"width":null,"height":null,"idselection":{"enabled":false},"byselection":{"enabled":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"legend":{"width":0.2,"useGroups":true,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true}},"evals":[],"jsHooks":[]}</script>
