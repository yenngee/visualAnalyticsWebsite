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

This is not the first time that Vast Challenge has given this data sources and topic. The first time that Vast Challenge set this scenario is in 2014. Though the questions were completely different, there were many valuable information and methodologies that we could learn from. The complete **Literature Review** can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-17-mc1-literature-review/)

## Data Preperation

The complete **Data Preparation process** can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/). The data preparation has included a step by step description of understanding the data and transforming unstructured text such as the news articles into a structured dataframe. For this portion of the post, I will be starting from a cleaned data source.

## Analysis

### 1a) Primary Vs Derivative Sources

This section will answer part 1a of the challenge: Which are primary sources and which are derivative sources? The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-primary-vs-derivative-sources/)

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

The three visualizations shows the breakdown of primary vs derivative sources and the type of primary source that we have managed to identify.

We can see that “Modern Rubicon” and “Centrum Sentinel” are fully blog posts, while “Homeland illumination” and “Abila Post”, has a mix of blog posts and being the first to post. This is interesting to note as later on in part 1a) we can see that some of the news sources actually “copy” the information, almost like a loudhailer for the particular news article source.

For simplicity, we defined primary type as primary if \>75% of the articles are considered primary, else if between 25%-75% then it is considered partially derivative and the rest are derivative.

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

This section will answer part 1b of the challenge: What are the relationships between the primary and derivative sources? The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-explore-relationships-between-articles/)

We started by tokenizing the article data that we have. With that, we are able to find out, based on the single words, which of the new articles are most similar using the `pairwise_cor` function. Below we have the network graph

**How similar are the news articles?**
<img src="{{< blogdown/postref >}}index.en_files/figure-html/cor_monogram-1.png" width="672" />

We notice that they news articles are naturally split into groups of 5, with a few exceptions. This is further supported by looking at articles with duplicated titles. Some of the articles posts before others. The lag in the date of post tells us which of the articles ‘copies’ others. The arrows point to the article source which reported the particular article first.

**Which article is coping who?**

<div id="htmlwidget-1" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,5,6,7,8,9,10,12,13,15,16,17,18,20,21,24,26,27,28],"label":["All News Today","Athena Speaks","Central Bulletin","Daily Pegasus","Everyday News","Homeland Illumination","International News","International Times","Kronos Star","News Desk","News Online Today","The Abila Post","The Continent","The Explainer","The General Post","The Light of Truth","The Orb","The World","Who What News","World Journal","World Source"],"cluster":["C","E","E","C","B","C","D","B","D","E","Others","E","B","E","A","A","C","A","A","B","B"],"group":["Partially Primary","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Partially Primary","Partially Primary","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Partially Primary"],"x":[-0.509098330128488,-0.28525038056169,-0.420964347008331,-0.439733404162135,-0.800618943851457,-0.340103061363728,-0.759481988824094,-1,-0.907550145691469,-0.432048044375157,-0.550205752419759,-0.434826600939951,-0.993365715646576,-0.220884786087645,1,0.608976350502215,-0.393891857077134,0.0696772798317284,-0.224222959878737,-0.961401222856595,-0.866481019211653],"y":[-0.391568498410827,0.383580480029147,0.3238853051501,-0.571512751013211,-0.26602130920247,-0.363732713342599,0.367992288303026,-0.121094129328147,0.306058332371113,1,0.00379503860957464,0.556660854189205,0.0658279560858117,0.626920486376142,-0.0839441329748509,-0.0728462504181743,-1,-0.0475597691194953,-0.0340170144940063,-0.275749120141763,-0.0916134155237065]},"edges":{"from":[7,10,15,7,15,10,24,24,9,1,13,13,15,7,8,9,9,9,13,15,28,1,3,3,3,5,9,13,13,13,13,15,17,20,24,26,28,28,28],"to":[13,13,3,1,13,8,13,26,13,13,3,26,17,5,13,6,16,27,5,2,13,5,2,13,17,21,28,2,6,16,27,12,2,18,20,13,6,16,27],"source_label":["Homeland Illumination","Kronos Star","The Abila Post","Homeland Illumination","The Abila Post","Kronos Star","The World","The World","International Times","All News Today","News Online Today","News Online Today","The Abila Post","Homeland Illumination","International News","International Times","International Times","International Times","News Online Today","The Abila Post","World Source","All News Today","Central Bulletin","Central Bulletin","Central Bulletin","Daily Pegasus","International Times","News Online Today","News Online Today","News Online Today","News Online Today","The Abila Post","The Explainer","The Light of Truth","The World","Who What News","World Source","World Source","World Source"],"target_label":["News Online Today","News Online Today","Central Bulletin","All News Today","News Online Today","International News","News Online Today","Who What News","News Online Today","News Online Today","Central Bulletin","Who What News","The Explainer","Daily Pegasus","News Online Today","Everyday News","The Continent","World Journal","Daily Pegasus","Athena Speaks","News Online Today","Daily Pegasus","Athena Speaks","News Online Today","The Explainer","The Orb","World Source","Athena Speaks","Everyday News","The Continent","World Journal","News Desk","Athena Speaks","The General Post","The Light of Truth","News Online Today","Everyday News","The Continent","World Journal"],"arrows":["from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from"],"value":[20,19,13,11,11,10,10,9,6,4,4,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Partially Primary","Derivative","Primary"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"},"legend":{"width":0.2,"useGroups":true,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true}},"evals":[],"jsHooks":[]}</script>

We can see that “News Online Today” actually grab most of their news from the 3 primary sources and even some of the partially primary source from weight of the arrow. What is interesting is that we find articles also posting after News Online Today though with a smaller degree. All of the primary sources have articles referring to them. What is interesting is that “Centrum Sentinel” and “Modern Rubicon” though are considered primary sources, do not have any duplicated titled articles with other news articles.

### 2\) Who is biased?

This section will answer part 2 of the challenge: Characterize any biases you identify in these news sources, with respect to their representation of specific people, places, and events. The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-who-is-bias-to-whom/)

**How many times do pok/governement/gastech appear?**
<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org_name-1.png" width="672" />

**What is the proportion of pok/governement/gastech in news articles?**
<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org_name_perc-1.png" width="672" />

We can see immediately that there are 8 news sources that do not or rarely mention pok, we can infer that

However, for the other

From our literature review, we understand that in particular “Homeland Illumination”

<img src="{{< blogdown/postref >}}index.en_files/figure-html/sentiment_analysis_pok-1.png" width="672" />
<img src="{{< blogdown/postref >}}index.en_files/figure-html/sentiment_analysis_gastech-1.png" width="672" />

In general,

### 3\) Connections and Relationships

This section will answer part 3 of the challenge: Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-20-mc1-connections-revealed/)

<iframe src="https://yenngee-dataviz.shinyapps.io/email_headers/" width="700" height="500&quot;">

</iframe>
