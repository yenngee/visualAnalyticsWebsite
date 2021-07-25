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
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],"label":["All News Today","Athena Speaks","Central Bulletin","Centrum Sentinel","Daily Pegasus","Everyday News","Homeland Illumination","International News","International Times","Kronos Star","Modern Rubicon","News Desk","News Online Today","Tethys News","The Abila Post","The Continent","The Explainer","The General Post","The Guide","The Light of Truth","The Orb","The Truth","The Tulip","The World","The Wrap","Who What News","World Journal","World Source","Worldwise"],"cluster":["C","E","E","Others","C","B","C","D","B","D","Others","E","Others","Others","E","B","E","A","D","A","C","D","A","A","C","A","B","B","D"],"group":["Partially Primary","Derivative","Derivative","Primary","Derivative","Derivative","Primary","Derivative","Partially Primary","Partially Primary","Primary","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Partially Primary","Derivative"],"x":[-0.169171814954621,-0.044527819750836,-0.206282782937112,1,0.0644647499295505,-0.476322022437641,-0.0873606468760295,0.131484525268481,-0.580873617530033,0.122859588525305,0.960218216423041,-0.272858490326956,-0.325839282417924,-0.509807949065539,-0.235827268938873,-0.805930751881422,0.0103264168707353,-1,-0.0294682038118658,-0.954622376923752,0.363444069539182,0.759486932384603,0.880730413254048,-0.718731886339876,0.345419132337211,-0.548026383325917,-0.719893468125707,-0.670762042112505,0.680849211247419],"y":[-0.841602961680096,-0.0297183890893707,-0.0959539092126755,0.10923147405135,-0.802455454079321,-0.802813742582856,-0.673279836461928,-0.473126784680441,-0.590063723468336,-0.297637135403811,-0.264690452641628,0.505242303687416,-0.400088818077156,0.95039927327605,0.126058506610291,-0.581649228592623,0.207576545864988,0.537613381382746,1,0.272649982701209,-1,0.347141960723387,-0.663316884941174,-0.021978995819129,0.859025011482514,-0.186073191084546,-0.42555251589086,-0.710058211632478,0.684346429678316]},"edges":{"from":[7,10,15,7,15,10,24,24,9,1,13,13,15,7,8,9,9,9,13,15,28,1,3,3,3,5,9,13,13,13,13,15,17,20,24,26,28,28,28],"to":[13,13,3,1,13,8,13,26,13,13,3,26,17,5,13,6,16,27,5,2,13,5,2,13,17,21,28,2,6,16,27,12,2,18,20,13,6,16,27],"source_label":["Homeland Illumination","Kronos Star","The Abila Post","Homeland Illumination","The Abila Post","Kronos Star","The World","The World","International Times","All News Today","News Online Today","News Online Today","The Abila Post","Homeland Illumination","International News","International Times","International Times","International Times","News Online Today","The Abila Post","World Source","All News Today","Central Bulletin","Central Bulletin","Central Bulletin","Daily Pegasus","International Times","News Online Today","News Online Today","News Online Today","News Online Today","The Abila Post","The Explainer","The Light of Truth","The World","Who What News","World Source","World Source","World Source"],"target_label":["News Online Today","News Online Today","Central Bulletin","All News Today","News Online Today","International News","News Online Today","Who What News","News Online Today","News Online Today","Central Bulletin","Who What News","The Explainer","Daily Pegasus","News Online Today","Everyday News","The Continent","World Journal","Daily Pegasus","Athena Speaks","News Online Today","Daily Pegasus","Athena Speaks","News Online Today","The Explainer","The Orb","World Source","Athena Speaks","Everyday News","The Continent","World Journal","News Desk","Athena Speaks","The General Post","The Light of Truth","News Online Today","Everyday News","The Continent","World Journal"],"arrows":["from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from"],"value":[20,19,13,11,11,10,10,9,6,4,4,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Partially Primary","Derivative","Primary"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"}},"evals":[],"jsHooks":[]}</script>

### 2\) Who is biased?

This section will answer part 2 of the challenge: Characterize any biases you identify in these news sources, with respect to their representation of specific people, places, and events.
This section will be limited to 6 images and 500 words.

### 3\) Connections and Relationships

This section will answer part 3 of the challenge: Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. Include both personal relationships and shared goals and objectives. Provide evidence for these relationships.
This section will be limited to 6 images and 400 words.

## Conclusion

TBC
