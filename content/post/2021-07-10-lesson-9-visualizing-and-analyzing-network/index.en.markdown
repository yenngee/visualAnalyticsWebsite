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
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,44,45,46,8,9,10,11,12,13,14,15,16,21,26,17,18,19,20,39,40,41,42,43,27,28,29,47,48,49,50,22,51,52,53,54,23,24,25,30,31,32,33,34,35,36,37,38],"label":["Mat.Bramar","Anda.Ribera","Rachel.Pantanal","Linda.Lagos","Ruscella.Mies.Haber","Carla.Forluniau","Cornelia.Lais","Kanon.Herrero","Varja.Lagos","Stenig.Fusil","Marin.Onda","Axel.Calzas","Brand.Tempestad","Elsa.Orilla","Isande.Borrasca","Kare.Orilla","Felix.Balas","Lars.Azada","Lidelse.Dedos","Willem.Vasco-Pais","Bertrand.Ovan","Adra.Nubarron","Birgitta.Frente","Gustav.Cazar","Vira.Frente","Linnea.Bergen","Lucas.Alcazar","Isak.Baza","Nils.Calixto","Sven.Flecha","Emile.Arpa","Varro.Awelon","Dante.Coginian","Edvard.Vann","Hennie.Osvaldo","Isia.Vann","Minke.Mies","Sten.Sanjorge.Jr","Felix.Resumir","Hideki.Cocinaro","Inga.Ferro","Loreto.Bodrogi","Ingrid.Barranco","Ada.Campo-Corrente","Orhan.Strum","Adan.Morlun","Albina.Hafon","Benito.Hawelon","Cecilia.Morluniau","Claudio.Hawelon","Dylan.Scozzese","Henk.Mies","Irene.Nant","Valeria.Morlun"],"Department":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"Title":["Assistant to CEO","Assistant to CFO","Assistant to CIO","Assistant to COO","Assistant to Engineering Group Manager","Assistant to IT Group Manager","Assistant to Security Group Manager","Badging Office","Badging Office","Building Control","Drill Site Manager","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Engineer","Engineer","Engineering Group Manager","Environmental Safety Advisor","Facilities Group Manager","Geologist","Geologist","Hydraulic Technician","Hydraulic Technician","IT Group Manager","IT Helpdesk","IT Technician","IT Technician","IT Technician","Janitor","Janitor","Lead Janitor","Perimeter Control","Perimeter Control","Perimeter Control","Perimeter Control","President/CEO","Security Group Manager","Site Control","Site Control","Site Control","SVP/CFO","SVP/CIO","SVP/COO","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver"],"x":[-0.115839036315006,-0.112313653079851,0.33352478255125,-0.0198002390918947,0.0335251313497571,0.057155519132702,0.287218220886743,0.798075593193945,0.443268233743974,0.87540347167797,-0.91989057373548,-0.642659393119555,-0.976774521203783,-0.785595535333833,-0.50610239274926,-0.705304677836568,-0.675161879785378,-0.542744575384351,-0.807904993251898,0.861661557543208,0.0304775086682356,-0.204866644344392,-0.933373911309899,-0.823685696343315,-0.430084152750585,-1,-0.0618955588827799,0.220458081652292,0.602364646002024,0.453194350492779,-0.628006716062963,-0.288937588638409,-0.000104901948896785,0.0413129747133463,-0.00330121615975332,0.703381480465857,0.518788282672493,0.747514343386158,0.547295352729289,0.390899897032201,0.619492208330783,0.721001328969288,0.0756146663883479,0.759553369138278,1,-0.185414274186232,-0.226193487718301,-0.50071518784213,-0.316625633037964,-0.586996553147082,-0.169100524911447,-0.00799063603278072,-0.443258937716068,-0.482862815454632],"y":[0.00518542167814662,-0.518597047788296,-0.412635125259119,-0.889553973945805,-0.115485447205371,-0.612141983542027,-0.70062888688769,0.0792554101805172,0.484668151949394,0.306500622898954,-0.14898410644441,-0.210271066329606,-0.332947378031455,-0.0963478544824623,-0.340206326587095,-0.733223994226803,-0.525839794521026,-0.715604252814372,-0.374449358546218,-0.353269471422471,0.936713156230505,-0.0868663095647286,-0.51152808990678,-0.624454447646252,-0.546516901677396,0.376942959344047,-0.0772772687392341,-1,-0.693560400950335,-0.913452481737064,0.559051819454215,0.48529461520208,0.718275874884405,0.117729931447232,0.0576127379422426,0.526143402495994,-0.0748170792763834,-0.147366931828992,0.651480259463263,0.246639235454326,0.212537061469464,0.370699107140569,-0.0117096035167048,-0.530671326579484,-0.194404632468256,0.852192485982384,0.667730297275829,0.672688979166946,0.929006616271264,0.811441020721223,1,0.505941776716683,0.892467070228034,0.480901978918055]},"edges":{"from":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,39,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,42,42,42,42,43,43,43,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54],"to":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,3,4,5,6,7,15,36,38,1,2,4,5,6,7,48,1,2,3,5,6,7,1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,2,3,4,5,7,28,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,27,8,10,11,12,13,14,15,16,17,18,19,20,45,8,9,11,12,13,14,15,16,17,18,19,20,8,9,10,12,13,14,15,16,17,18,19,20,32,8,9,10,11,13,14,15,16,17,18,19,20,52,8,9,10,11,12,14,15,16,17,18,19,20,8,9,10,11,12,13,15,16,17,18,19,20,2,8,9,10,11,12,13,14,16,17,18,19,20,8,9,10,11,12,13,14,15,17,18,19,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,8,9,10,11,12,13,14,15,17,19,20,8,9,10,11,12,13,14,15,16,17,18,20,8,9,10,11,12,13,14,15,16,17,18,19,50,22,23,24,25,53,21,23,24,25,36,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,5,21,22,23,25,21,22,23,24,46,27,28,29,30,31,32,33,34,35,36,37,38,8,28,29,30,31,32,33,34,35,36,37,38,40,6,26,27,29,30,31,32,33,34,35,36,37,38,1,26,27,28,30,31,32,33,34,35,36,37,38,40,51,52,26,27,28,29,31,32,33,34,35,36,37,38,3,27,28,29,30,32,33,34,35,36,37,38,11,26,27,28,29,30,31,33,34,35,36,37,38,23,26,27,28,29,30,31,32,34,35,36,37,38,27,28,29,30,31,32,33,35,36,37,38,26,27,28,29,30,31,32,33,34,36,37,38,2,22,26,27,28,29,30,31,32,33,34,35,37,38,53,26,27,28,29,30,31,32,33,34,35,36,38,27,28,29,30,31,32,34,35,36,34,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,40,42,43,40,41,43,44,40,41,42,42,45,46,47,48,49,50,51,52,53,54,44,46,47,48,49,50,51,52,53,54,44,45,47,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,49,50,51,52,53,54,3,45,46,47,48,52,54,5,20,48,49,53,54,29,44,45,46,47,48,49,50,52,53,54,7,12,29,44,45,46,47,48,49,50,51,53,5,21,36,44,45,47,48,49,50,51,52,54,5,44,45,46,47,48,49,50,51,52,53],"weight":[21,21,21,21,21,21,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,6,6,6,6,9,2,2,2,8,8,8,8,8,8,2,12,12,12,12,12,12,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,10,10,11,11,11,11,11,11,11,11,3,12,15,12,12,12,12,3,4,3,3,4,4,3,3,4,3,4,3,3,4,4,9,4,7,7,11,5,4,5,6,8,3,8,8,7,9,9,6,9,10,10,7,5,7,11,10,11,6,11,7,11,9,10,7,10,8,3,9,10,8,8,11,6,7,5,3,6,5,6,2,9,5,10,7,7,4,3,4,7,2,3,3,6,5,7,4,6,6,7,5,7,6,3,4,3,6,13,8,8,5,6,6,11,9,6,2,7,6,8,7,5,5,7,6,7,7,5,4,6,2,2,2,2,2,2,2,6,4,7,7,6,6,6,6,5,5,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,4,5,3,3,2,5,2,3,2,4,8,5,9,6,5,4,10,7,4,4,5,5,10,5,7,4,5,4,4,4,3,2,4,3,4,2,4,7,2,7,5,10,4,2,4,4,4,4,4,4,4,4,4,4,4,4,6,4,4,4,4,4,4,4,6,10,17,9,4,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,5,9,7,3,8,2,3,4,2,26,25,25,25,25,25,24,25,25,26,25,26,3,4,3,6,4,3,3,6,5,3,4,5,3,3,2,3,6,5,8,6,6,7,4,6,6,6,2,2,6,5,7,5,6,5,7,6,6,5,5,3,2,3,3,5,7,9,12,9,9,6,13,12,9,11,2,5,4,6,6,9,7,6,12,7,7,8,4,2,8,6,9,7,10,7,9,6,10,5,8,2,4,2,3,5,7,8,4,7,5,7,6,4,5,6,4,7,8,5,9,6,6,10,6,3,11,7,9,11,15,7,11,11,9,13,13,2,2,3,12,11,12,16,15,19,12,11,14,11,13,3,3,4,5,6,7,7,6,9,10,7,5,3,2,5,5,2,2,2,4,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,40,22,30,2,2,2,2,2,2,2,2,2,2,2,28,19,24,25,19,28,2,15,16,24,3,4,2,5,6,2,5,5,2,6,3,6,4,2,6,5,5,4,7,5,6,6,3,4,9,5,6,8,7,4,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,5,4,3,7,5,6,6,5,5,5,2,2,4,2,4,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,5,3,8,6,5,5,5,6,2,3,2,3,3,4,2,2,4,2,2,5,2,3,3,3,3,4,4,2,3,3,3,3,2,2,4,2,4,4,3,4,5,3,2,4,3,3,4,3,3,2,5,4,8,2,2,5,2,3,4,3,2,5,4,4,2,3,4]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false}},"groups":null,"width":null,"height":null,"idselection":{"enabled":false},"byselection":{"enabled":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"}},"evals":[],"jsHooks":[]}</script>

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
<script type="application/json" data-for="htmlwidget-2">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,44,45,46,8,9,10,11,12,13,14,15,16,21,26,17,18,19,20,39,40,41,42,43,27,28,29,47,48,49,50,22,51,52,53,54,23,24,25,30,31,32,33,34,35,36,37,38],"label":["Mat.Bramar","Anda.Ribera","Rachel.Pantanal","Linda.Lagos","Ruscella.Mies.Haber","Carla.Forluniau","Cornelia.Lais","Kanon.Herrero","Varja.Lagos","Stenig.Fusil","Marin.Onda","Axel.Calzas","Brand.Tempestad","Elsa.Orilla","Isande.Borrasca","Kare.Orilla","Felix.Balas","Lars.Azada","Lidelse.Dedos","Willem.Vasco-Pais","Bertrand.Ovan","Adra.Nubarron","Birgitta.Frente","Gustav.Cazar","Vira.Frente","Linnea.Bergen","Lucas.Alcazar","Isak.Baza","Nils.Calixto","Sven.Flecha","Emile.Arpa","Varro.Awelon","Dante.Coginian","Edvard.Vann","Hennie.Osvaldo","Isia.Vann","Minke.Mies","Sten.Sanjorge.Jr","Felix.Resumir","Hideki.Cocinaro","Inga.Ferro","Loreto.Bodrogi","Ingrid.Barranco","Ada.Campo-Corrente","Orhan.Strum","Adan.Morlun","Albina.Hafon","Benito.Hawelon","Cecilia.Morluniau","Claudio.Hawelon","Dylan.Scozzese","Henk.Mies","Irene.Nant","Valeria.Morlun"],"Department":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"Title":["Assistant to CEO","Assistant to CFO","Assistant to CIO","Assistant to COO","Assistant to Engineering Group Manager","Assistant to IT Group Manager","Assistant to Security Group Manager","Badging Office","Badging Office","Building Control","Drill Site Manager","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Engineer","Engineer","Engineering Group Manager","Environmental Safety Advisor","Facilities Group Manager","Geologist","Geologist","Hydraulic Technician","Hydraulic Technician","IT Group Manager","IT Helpdesk","IT Technician","IT Technician","IT Technician","Janitor","Janitor","Lead Janitor","Perimeter Control","Perimeter Control","Perimeter Control","Perimeter Control","President/CEO","Security Group Manager","Site Control","Site Control","Site Control","SVP/CFO","SVP/CIO","SVP/COO","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver"],"group":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"x":[0.00388352315991658,-0.202099436713744,-0.0471233921469544,-0.362255364521995,0.0873784950603933,-0.514254154973816,-0.131943434092571,0.621016193663019,0.968847213962191,0.772755291349242,0.357814705254139,1,0.784697313455812,0.462393425576727,0.740170555675915,0.496438677235973,0.904574732773508,0.557328860455397,0.933045308853908,-0.0592441142780943,-1,0.173439663027009,0.637037040886928,0.678920336467365,0.854753383004185,-0.671866856534673,0.00474336732927005,0.491677592058479,0.287890857259426,0.0681351903741108,-0.594553508547423,-0.854778752538252,-0.485752327622858,0.197786805077096,0.165150857386869,0.890498335426471,0.962028146138913,-0.390800758173927,0.398482873400111,0.506332230745562,0.531441076310172,0.771718514533854,-0.0337423830265494,-0.203993654361389,0.0520151834252902,-0.806209893342529,-0.732623641455548,-0.538551001040212,-0.745652640844809,-0.947662768683093,-0.978773648509555,-0.508534752476332,-0.950282818674017,-0.728594119018151],"y":[0.0726578005623302,-0.433033068067579,-0.635146687105452,-0.787515044274583,0.030446071699618,-0.632631479419606,-0.808213950103976,-0.585415053294408,-0.290129237434023,-0.190471857609598,0.763748861505464,0.505139767009482,0.855611109335976,0.625393175161774,0.438086124575583,0.901789468537484,0.385251964472949,0.417920929261242,0.748022682841777,0.739114617618277,-0.122505101553936,0.227377031404463,0.933876878955826,0.720589814731395,0.587802131038798,0.862794456099533,-0.0376365663073811,-0.917518411592686,-0.912770634772204,-1,0.423949165591904,-0.202145182453267,-0.163203365228848,0.0555598547743841,-0.0507599282460256,-0.477688660229172,-0.067897329555433,0.828146284504667,-0.546988638455248,-0.348750015890872,-0.0961143209484303,-0.562261423911101,0.171770047609421,1,0.958743927094668,0.359274096513722,-0.0688109033278517,0.279681618944893,0.154076382673562,0.182145837558344,0.0353676106681595,0.0769641674223576,0.330617438635218,-0.28387179803574]},"edges":{"from":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,39,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,42,42,42,42,43,43,43,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54],"to":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,3,4,5,6,7,15,36,38,1,2,4,5,6,7,48,1,2,3,5,6,7,1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,2,3,4,5,7,28,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,27,8,10,11,12,13,14,15,16,17,18,19,20,45,8,9,11,12,13,14,15,16,17,18,19,20,8,9,10,12,13,14,15,16,17,18,19,20,32,8,9,10,11,13,14,15,16,17,18,19,20,52,8,9,10,11,12,14,15,16,17,18,19,20,8,9,10,11,12,13,15,16,17,18,19,20,2,8,9,10,11,12,13,14,16,17,18,19,20,8,9,10,11,12,13,14,15,17,18,19,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,8,9,10,11,12,13,14,15,17,19,20,8,9,10,11,12,13,14,15,16,17,18,20,8,9,10,11,12,13,14,15,16,17,18,19,50,22,23,24,25,53,21,23,24,25,36,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,5,21,22,23,25,21,22,23,24,46,27,28,29,30,31,32,33,34,35,36,37,38,8,28,29,30,31,32,33,34,35,36,37,38,40,6,26,27,29,30,31,32,33,34,35,36,37,38,1,26,27,28,30,31,32,33,34,35,36,37,38,40,51,52,26,27,28,29,31,32,33,34,35,36,37,38,3,27,28,29,30,32,33,34,35,36,37,38,11,26,27,28,29,30,31,33,34,35,36,37,38,23,26,27,28,29,30,31,32,34,35,36,37,38,27,28,29,30,31,32,33,35,36,37,38,26,27,28,29,30,31,32,33,34,36,37,38,2,22,26,27,28,29,30,31,32,33,34,35,37,38,53,26,27,28,29,30,31,32,33,34,35,36,38,27,28,29,30,31,32,34,35,36,34,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,40,42,43,40,41,43,44,40,41,42,42,45,46,47,48,49,50,51,52,53,54,44,46,47,48,49,50,51,52,53,54,44,45,47,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,49,50,51,52,53,54,3,45,46,47,48,52,54,5,20,48,49,53,54,29,44,45,46,47,48,49,50,52,53,54,7,12,29,44,45,46,47,48,49,50,51,53,5,21,36,44,45,47,48,49,50,51,52,54,5,44,45,46,47,48,49,50,51,52,53],"weight":[21,21,21,21,21,21,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,6,6,6,6,9,2,2,2,8,8,8,8,8,8,2,12,12,12,12,12,12,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,10,10,11,11,11,11,11,11,11,11,3,12,15,12,12,12,12,3,4,3,3,4,4,3,3,4,3,4,3,3,4,4,9,4,7,7,11,5,4,5,6,8,3,8,8,7,9,9,6,9,10,10,7,5,7,11,10,11,6,11,7,11,9,10,7,10,8,3,9,10,8,8,11,6,7,5,3,6,5,6,2,9,5,10,7,7,4,3,4,7,2,3,3,6,5,7,4,6,6,7,5,7,6,3,4,3,6,13,8,8,5,6,6,11,9,6,2,7,6,8,7,5,5,7,6,7,7,5,4,6,2,2,2,2,2,2,2,6,4,7,7,6,6,6,6,5,5,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,4,5,3,3,2,5,2,3,2,4,8,5,9,6,5,4,10,7,4,4,5,5,10,5,7,4,5,4,4,4,3,2,4,3,4,2,4,7,2,7,5,10,4,2,4,4,4,4,4,4,4,4,4,4,4,4,6,4,4,4,4,4,4,4,6,10,17,9,4,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,5,9,7,3,8,2,3,4,2,26,25,25,25,25,25,24,25,25,26,25,26,3,4,3,6,4,3,3,6,5,3,4,5,3,3,2,3,6,5,8,6,6,7,4,6,6,6,2,2,6,5,7,5,6,5,7,6,6,5,5,3,2,3,3,5,7,9,12,9,9,6,13,12,9,11,2,5,4,6,6,9,7,6,12,7,7,8,4,2,8,6,9,7,10,7,9,6,10,5,8,2,4,2,3,5,7,8,4,7,5,7,6,4,5,6,4,7,8,5,9,6,6,10,6,3,11,7,9,11,15,7,11,11,9,13,13,2,2,3,12,11,12,16,15,19,12,11,14,11,13,3,3,4,5,6,7,7,6,9,10,7,5,3,2,5,5,2,2,2,4,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,40,22,30,2,2,2,2,2,2,2,2,2,2,2,28,19,24,25,19,28,2,15,16,24,3,4,2,5,6,2,5,5,2,6,3,6,4,2,6,5,5,4,7,5,6,6,3,4,9,5,6,8,7,4,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,5,4,3,7,5,6,6,5,5,5,2,2,4,2,4,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,5,3,8,6,5,5,5,6,2,3,2,3,3,4,2,2,4,2,2,5,2,3,3,3,3,4,4,2,3,3,3,3,2,2,4,2,4,4,3,4,5,3,2,4,3,3,4,3,3,2,5,4,8,2,2,5,2,3,4,3,2,5,4,4,2,3,4]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Administration","Security","Engineering","Executive","Facilities","Information Technology"],"width":null,"height":null,"idselection":{"enabled":false},"byselection":{"enabled":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"legend":{"width":0.2,"useGroups":true,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true}},"evals":[],"jsHooks":[]}</script>

### Additional Interactivity

We use `visOptions` to add on interactivity.

``` r
visNetwork(GAStech_nodes, GAStech_edges_agg_viz) %>%
  visIgraphLayout(layout = "layout_with_fr") %>%
  visOptions(highlightNearest=TRUE, 
             nodesIdSelection=TRUE) %>%
  visLegend() %>%
  visLayout(randomSeed=123)
```

<div id="htmlwidget-3" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,44,45,46,8,9,10,11,12,13,14,15,16,21,26,17,18,19,20,39,40,41,42,43,27,28,29,47,48,49,50,22,51,52,53,54,23,24,25,30,31,32,33,34,35,36,37,38],"label":["Mat.Bramar","Anda.Ribera","Rachel.Pantanal","Linda.Lagos","Ruscella.Mies.Haber","Carla.Forluniau","Cornelia.Lais","Kanon.Herrero","Varja.Lagos","Stenig.Fusil","Marin.Onda","Axel.Calzas","Brand.Tempestad","Elsa.Orilla","Isande.Borrasca","Kare.Orilla","Felix.Balas","Lars.Azada","Lidelse.Dedos","Willem.Vasco-Pais","Bertrand.Ovan","Adra.Nubarron","Birgitta.Frente","Gustav.Cazar","Vira.Frente","Linnea.Bergen","Lucas.Alcazar","Isak.Baza","Nils.Calixto","Sven.Flecha","Emile.Arpa","Varro.Awelon","Dante.Coginian","Edvard.Vann","Hennie.Osvaldo","Isia.Vann","Minke.Mies","Sten.Sanjorge.Jr","Felix.Resumir","Hideki.Cocinaro","Inga.Ferro","Loreto.Bodrogi","Ingrid.Barranco","Ada.Campo-Corrente","Orhan.Strum","Adan.Morlun","Albina.Hafon","Benito.Hawelon","Cecilia.Morluniau","Claudio.Hawelon","Dylan.Scozzese","Henk.Mies","Irene.Nant","Valeria.Morlun"],"Department":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"Title":["Assistant to CEO","Assistant to CFO","Assistant to CIO","Assistant to COO","Assistant to Engineering Group Manager","Assistant to IT Group Manager","Assistant to Security Group Manager","Badging Office","Badging Office","Building Control","Drill Site Manager","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Drill Technician","Engineer","Engineer","Engineering Group Manager","Environmental Safety Advisor","Facilities Group Manager","Geologist","Geologist","Hydraulic Technician","Hydraulic Technician","IT Group Manager","IT Helpdesk","IT Technician","IT Technician","IT Technician","Janitor","Janitor","Lead Janitor","Perimeter Control","Perimeter Control","Perimeter Control","Perimeter Control","President/CEO","Security Group Manager","Site Control","Site Control","Site Control","SVP/CFO","SVP/CIO","SVP/COO","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver","Truck Driver"],"group":["Administration","Administration","Administration","Administration","Administration","Administration","Administration","Security","Security","Security","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Engineering","Executive","Facilities","Engineering","Engineering","Engineering","Engineering","Information Technology","Information Technology","Information Technology","Information Technology","Information Technology","Facilities","Facilities","Facilities","Security","Security","Security","Security","Executive","Security","Security","Security","Security","Executive","Executive","Executive","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities","Facilities"],"x":[0.0777480146218559,0.548512842778684,0.35132709284673,0.600244380105724,-0.0268110575914267,0.743632991381652,0.366574959592952,-0.957317488025177,-1,-0.888430559858156,-0.0444921497704147,-0.690381934680478,-0.318151630489292,-0.174361699326069,-0.405128999007129,-0.170771114358246,-0.314512804157223,-0.0262686624510484,-0.534376365127416,-0.676869408713005,0.888332040275369,-0.0826167365415433,-0.480086733054073,-0.529774753907347,-0.68609553162334,1,0.017488507812254,-0.0246554207364394,-0.367102229620423,0.144033624205797,0.620869304261592,0.920087367077665,0.308270472405355,-0.169581181711341,-0.164707965370415,-0.778819465344609,-0.956320159990889,-0.141113434367779,-0.668788443068401,-0.584762407588801,-0.532287604082641,-0.845252040653813,-0.0635720566132679,-0.364986409066077,-0.585344997163155,0.656880133567731,0.761506437673684,0.534245595667465,0.598395800647474,0.946662962370369,0.780363142534947,0.397281276008079,0.563597114228284,0.784325270610527],"y":[0.0799749772518863,0.402392327185181,0.500448425578097,0.723275528547394,0.0688742130242332,0.490335354840461,0.728737889096484,-0.304412605574094,-0.0407752303203262,-0.421159928440593,0.707216977892811,0.595035033367119,0.805222615786256,0.601668623897037,0.576732855604578,0.949204088336495,1,0.867451545829999,0.634170559515556,-0.687924308335364,-0.464013046870094,0.178620572392824,0.957936649690621,0.828108585982179,0.750205399652014,0.357834928302968,-0.0619334584521223,-1,-0.874827201759226,-0.882645079809285,0.00701789742788561,-0.0840286017596333,-0.352244158491497,-0.0498618427466115,0.0316934882124089,0.113648076748119,0.188580738399042,-0.801111888911814,-0.392241350415686,-0.0124659447493576,-0.316047977788428,-0.135901910098233,-0.110240125270004,-0.669929622606173,-0.85696927840241,-0.515989838655178,-0.283164819450597,-0.142041071042608,-0.37301811363945,-0.282797549505261,-0.597889705694336,-0.472886992222089,-0.652680603749624,-0.103922859114633]},"edges":{"from":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,39,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,42,42,42,42,43,43,43,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54],"to":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,3,4,5,6,7,15,36,38,1,2,4,5,6,7,48,1,2,3,5,6,7,1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,1,2,3,4,5,7,28,1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,27,8,10,11,12,13,14,15,16,17,18,19,20,45,8,9,11,12,13,14,15,16,17,18,19,20,8,9,10,12,13,14,15,16,17,18,19,20,32,8,9,10,11,13,14,15,16,17,18,19,20,52,8,9,10,11,12,14,15,16,17,18,19,20,8,9,10,11,12,13,15,16,17,18,19,20,2,8,9,10,11,12,13,14,16,17,18,19,20,8,9,10,11,12,13,14,15,17,18,19,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,8,9,10,11,12,13,14,15,17,19,20,8,9,10,11,12,13,14,15,16,17,18,20,8,9,10,11,12,13,14,15,16,17,18,19,50,22,23,24,25,53,21,23,24,25,36,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,5,21,22,23,25,21,22,23,24,46,27,28,29,30,31,32,33,34,35,36,37,38,8,28,29,30,31,32,33,34,35,36,37,38,40,6,26,27,29,30,31,32,33,34,35,36,37,38,1,26,27,28,30,31,32,33,34,35,36,37,38,40,51,52,26,27,28,29,31,32,33,34,35,36,37,38,3,27,28,29,30,32,33,34,35,36,37,38,11,26,27,28,29,30,31,33,34,35,36,37,38,23,26,27,28,29,30,31,32,34,35,36,37,38,27,28,29,30,31,32,33,35,36,37,38,26,27,28,29,30,31,32,33,34,36,37,38,2,22,26,27,28,29,30,31,32,33,34,35,37,38,53,26,27,28,29,30,31,32,33,34,35,36,38,27,28,29,30,31,32,34,35,36,34,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,40,42,43,40,41,43,44,40,41,42,42,45,46,47,48,49,50,51,52,53,54,44,46,47,48,49,50,51,52,53,54,44,45,47,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,49,50,51,52,53,54,3,45,46,47,48,52,54,5,20,48,49,53,54,29,44,45,46,47,48,49,50,52,53,54,7,12,29,44,45,46,47,48,49,50,51,53,5,21,36,44,45,47,48,49,50,51,52,54,5,44,45,46,47,48,49,50,51,52,53],"weight":[21,21,21,21,21,21,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,6,6,6,6,6,9,2,2,2,8,8,8,8,8,8,2,12,12,12,12,12,12,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,10,10,11,11,11,11,11,11,11,11,3,12,15,12,12,12,12,3,4,3,3,4,4,3,3,4,3,4,3,3,4,4,9,4,7,7,11,5,4,5,6,8,3,8,8,7,9,9,6,9,10,10,7,5,7,11,10,11,6,11,7,11,9,10,7,10,8,3,9,10,8,8,11,6,7,5,3,6,5,6,2,9,5,10,7,7,4,3,4,7,2,3,3,6,5,7,4,6,6,7,5,7,6,3,4,3,6,13,8,8,5,6,6,11,9,6,2,7,6,8,7,5,5,7,6,7,7,5,4,6,2,2,2,2,2,2,2,6,4,7,7,6,6,6,6,5,5,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,4,5,3,3,2,5,2,3,2,4,8,5,9,6,5,4,10,7,4,4,5,5,10,5,7,4,5,4,4,4,3,2,4,3,4,2,4,7,2,7,5,10,4,2,4,4,4,4,4,4,4,4,4,4,4,4,6,4,4,4,4,4,4,4,6,10,17,9,4,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,5,9,7,3,8,2,3,4,2,26,25,25,25,25,25,24,25,25,26,25,26,3,4,3,6,4,3,3,6,5,3,4,5,3,3,2,3,6,5,8,6,6,7,4,6,6,6,2,2,6,5,7,5,6,5,7,6,6,5,5,3,2,3,3,5,7,9,12,9,9,6,13,12,9,11,2,5,4,6,6,9,7,6,12,7,7,8,4,2,8,6,9,7,10,7,9,6,10,5,8,2,4,2,3,5,7,8,4,7,5,7,6,4,5,6,4,7,8,5,9,6,6,10,6,3,11,7,9,11,15,7,11,11,9,13,13,2,2,3,12,11,12,16,15,19,12,11,14,11,13,3,3,4,5,6,7,7,6,9,10,7,5,3,2,5,5,2,2,2,4,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,2,2,2,2,2,40,22,30,2,2,2,2,2,2,2,2,2,2,2,28,19,24,25,19,28,2,15,16,24,3,4,2,5,6,2,5,5,2,6,3,6,4,2,6,5,5,4,7,5,6,6,3,4,9,5,6,8,7,4,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,5,4,3,7,5,6,6,5,5,5,2,2,4,2,4,2,2,2,2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,5,3,8,6,5,5,5,6,2,3,2,3,3,4,2,2,4,2,2,5,2,3,3,3,3,4,4,2,3,3,3,3,2,2,4,2,4,4,3,4,5,3,2,4,3,3,4,3,3,2,5,4,8,2,2,5,2,3,4,3,2,5,4,4,2,3,4]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Administration","Security","Engineering","Executive","Facilities","Information Technology"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"},"legend":{"width":0.2,"useGroups":true,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true}},"evals":[],"jsHooks":[]}</script>

We can select by using the drop down or clicking on a single node. The nodes which is connected to the selected node will be highlighted.

–end–
