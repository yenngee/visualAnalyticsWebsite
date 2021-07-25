---
title: 'MC1: Findings and Discoveries'
author: "Ng Yen Ngee"
date: '2021-07-24'
lastmod: '2021-07-25'
slug: []
cover: "/img/data_discovery.png"
categories: []
tags: ["MC1", 'MITB', 'Text Analytics']
output:
  blogdown::html_page: 
    toc: true
---

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/vis/vis.css" rel="stylesheet" />

<script src="{{< blogdown/postref >}}index.en_files/vis/vis.min.js"></script>

<script src="{{< blogdown/postref >}}index.en_files/visNetwork-binding/visNetwork.js"></script>

# Introduction

In this post, I will be running through the findings and analysis of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). This will be my main page and answer to my class [assignment](https://isss608.netlify.app/assignment.html).

The objective of this assignment is identify the complex relationships between the people, organizations, news articles given the data that we have.

## Content of all Posts

Below and the table of content on the left is how we can navigate through the posts and analysis. Each section has a full post dedicated which runs through explanations, codes and actual visualizations. As analyzing in R and the data set is new to me, some of the posts are documented in a step by step manner with a run through of how I managed to arrive at the last visualization for my analysis below. Hence, some of the posts are quite lengthy. If you want to skip to the analysis bit, please scroll down to the analysis section of this post.

  - Literature Review [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-17-mc1-literature-review/)
  - Data Preparation [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/)
  - Analysis
      - 1a Primary Vs Derivative Sources [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-primary-vs-derivative-sources/)
      - 1b Relationships:Primary vs Derivative Sources [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-explore-relationships-between-articles/)
      - 2 Who is biased? [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-who-is-bias-to-whom/)
      - 3 Connections and Relationships [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-20-mc1-connections-revealed/)

## Literature Review

## Data Preperation

The complete **Data Preparation process** can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/). The data preparation has included a step by step description of understanding the data and transforming unstructured text such as the news articles into a structured dataframe. For this portion of the post, I will be starting from a cleaned data source.

## Analysis

### 1a) Primary Vs Derivative Sources

This section will answer part 1a of the challenge: Which are primary sources and which are derivative sources?

Primary Sources is “first-hand” information, while secondary sources provide analysis, commentary or criticism on the Primary source. In terms of data, we’ve defined primary source as the following:
\- article text start with a time format
\- article title contains the word blog
\- duplicated article titles that is printed first

We have the following output:

**Primary VS Derivative of each source**

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_pyramid3-1.png" width="672" />

**Percentile of Primary VS Derivative of each source**

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_perc_bar-1.png" width="672" />

<img src="{{< blogdown/postref >}}index.en_files/figure-html/plot_breakdown_primary_type-1.png" width="672" />

ANALYSIS WRITE HERE

We can see that “Modern Rubicon” and “Centrum Sentinel” are fully

    ## # A tibble: 29 x 2
    ##    source              is_primary       
    ##    <chr>               <chr>            
    ##  1 The Light of Truth  Derivative       
    ##  2 The General Post    Derivative       
    ##  3 Who What News       Derivative       
    ##  4 The Tulip           Derivative       
    ##  5 The World           Primary          
    ##  6 World Journal       Derivative       
    ##  7 Everyday News       Derivative       
    ##  8 The Continent       Derivative       
    ##  9 World Source        Partially Primary
    ## 10 International Times Partially Primary
    ## # ... with 19 more rows

### 1b) Relationships:Primary vs Derivative Sources

This section will answer part 1b of the challenge: What are the relationships between the primary and derivative sources?

<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_monogram-1.png" width="672" />

<div id="htmlwidget-1" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],"label":["All News Today","Athena Speaks","Central Bulletin","Centrum Sentinel","Daily Pegasus","Everyday News","Homeland Illumination","International News","International Times","Kronos Star","Modern Rubicon","News Desk","News Online Today","Tethys News","The Abila Post","The Continent","The Explainer","The General Post","The Guide","The Light of Truth","The Orb","The Truth","The Tulip","The World","The Wrap","Who What News","World Journal","World Source","Worldwise"],"cluster":["C","E","E","Others","C","B","C","D","B","D","Others","E","Others","Others","E","B","E","A","D","A","C","D","A","A","C","A","B","B","D"],"group":["Partially Primary","Derivative","Derivative","Primary","Derivative","Derivative","Primary","Derivative","Partially Primary","Partially Primary","Primary","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Partially Primary","Derivative"],"x":[-0.133692979627026,-0.589413167500796,-0.467289789499291,0.706949443290067,0.078954088678802,-0.886775280046954,-0.0345394627389781,-0.889235899351043,-0.805819445030961,-1,-0.877536456870593,-0.0647993151392932,-0.504360869943184,1,-0.315300312232274,-0.576934997821514,-0.471432201374107,0.34500198022509,-0.380512201960549,0.13050563728666,0.439983210303701,0.913880808201079,0.0967701609972973,-0.141169317206389,0.985117849067042,-0.306629732086017,-0.979035497803794,-0.727777819323623,0.827611863493303],"y":[-0.359003984241558,-0.660468879914867,-0.537176772258606,0.744111654830932,-0.381453820810592,-0.0951489089486134,-0.188402232780335,-0.482520252193998,0.161926622159059,-0.335333384523844,0.841489587699875,-1,-0.216463531313384,-0.3277726010557,-0.702252686647187,0.211122677659741,-0.881775859045544,0.612275152108838,0.980487914554029,0.450362677993348,-0.528558697985891,0.365300419337271,1,0.182508147726042,0.0252610939312006,0.00636034929305751,0.0612347812165408,0.0337724599337454,-0.752386688014028]},"edges":{"from":[7,10,15,7,15,10,24,24,9,1,13,13,15,7,8,9,9,9,13,15,28,1,3,3,3,5,9,13,13,13,13,15,17,20,24,26,28,28,28],"to":[13,13,3,1,13,8,13,26,13,13,3,26,17,5,13,6,16,27,5,2,13,5,2,13,17,21,28,2,6,16,27,12,2,18,20,13,6,16,27],"source_label":["Homeland Illumination","Kronos Star","The Abila Post","Homeland Illumination","The Abila Post","Kronos Star","The World","The World","International Times","All News Today","News Online Today","News Online Today","The Abila Post","Homeland Illumination","International News","International Times","International Times","International Times","News Online Today","The Abila Post","World Source","All News Today","Central Bulletin","Central Bulletin","Central Bulletin","Daily Pegasus","International Times","News Online Today","News Online Today","News Online Today","News Online Today","The Abila Post","The Explainer","The Light of Truth","The World","Who What News","World Source","World Source","World Source"],"target_label":["News Online Today","News Online Today","Central Bulletin","All News Today","News Online Today","International News","News Online Today","Who What News","News Online Today","News Online Today","Central Bulletin","Who What News","The Explainer","Daily Pegasus","News Online Today","Everyday News","The Continent","World Journal","Daily Pegasus","Athena Speaks","News Online Today","Daily Pegasus","Athena Speaks","News Online Today","The Explainer","The Orb","World Source","Athena Speaks","Everyday News","The Continent","World Journal","News Desk","Athena Speaks","The General Post","The Light of Truth","News Online Today","Everyday News","The Continent","World Journal"],"arrows":["from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from"],"value":[20,19,13,11,11,10,10,9,6,4,4,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Partially Primary","Derivative","Primary"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"}},"evals":[],"jsHooks":[]}</script>

ANALYSIS WRITE HERE

### 2\) Who is biased?

This section will answer part 2 of the challenge: Characterize any biases you identify in these news sources, with respect to their representation of specific people, places, and events.
This section will be limited to 6 images and 500 words.

### 3\) Connections and Relationships

This section will answer part 3 of the challenge: Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. Include both personal relationships and shared goals and objectives. Provide evidence for these relationships.
This section will be limited to 6 images and 400 words.

## Conclusion

TBC
