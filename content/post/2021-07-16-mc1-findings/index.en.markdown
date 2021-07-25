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
<script type="application/json" data-for="htmlwidget-1">{"x":{"nodes":{"id":[1,2,3,5,6,7,8,9,10,12,13,15,16,17,18,20,21,24,26,27,28],"label":["All News Today","Athena Speaks","Central Bulletin","Daily Pegasus","Everyday News","Homeland Illumination","International News","International Times","Kronos Star","News Desk","News Online Today","The Abila Post","The Continent","The Explainer","The General Post","The Light of Truth","The Orb","The World","Who What News","World Journal","World Source"],"cluster":["C","E","E","C","B","C","D","B","D","E","Others","E","B","E","A","A","C","A","A","B","B"],"group":["Partially Primary","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Partially Primary","Partially Primary","Derivative","Derivative","Primary","Derivative","Derivative","Derivative","Derivative","Derivative","Primary","Derivative","Derivative","Partially Primary"],"bias":["unknown","unknown","gastech","unknown","unknown","pok","unknown","unknown","unknown","unknown","unknown","unknown","unknown","unknown","gastech","gastech","unknown","gastech","gastech","unknown","unknown"],"x":[0.149728544671041,0.0468135718733371,-0.136357996884717,0.427355988426598,-1,0.197900677653337,-0.81464799999694,-0.72805092288101,-0.615647634854056,-0.101170780305027,-0.331238868188082,-0.141354109640861,-0.824485861148246,0.153600507203458,-0.169567572530884,-0.204657113787635,1,-0.249860778190928,-0.257328832554967,-0.679176163514091,-0.885197638422489],"y":[-0.0479528429492411,-0.51782920665839,-0.466034057602641,-0.102761530213964,-0.267505267056093,-0.185480707806939,0.0245262892626508,-0.323313449583115,0.086631842897662,-1,-0.207891929615117,-0.651437525635925,-0.192459652411358,-0.707194970219274,1,0.697318294100232,-0.0373499446926214,0.280482169888172,0.0460429637298603,-0.477144122538942,-0.37964743229306]},"edges":{"from":[7,10,15,7,15,10,24,24,9,1,13,13,15,7,8,9,9,9,13,15,28,1,3,3,3,5,9,13,13,13,13,15,17,20,24,26,28,28,28],"to":[13,13,3,1,13,8,13,26,13,13,3,26,17,5,13,6,16,27,5,2,13,5,2,13,17,21,28,2,6,16,27,12,2,18,20,13,6,16,27],"source_label":["Homeland Illumination","Kronos Star","The Abila Post","Homeland Illumination","The Abila Post","Kronos Star","The World","The World","International Times","All News Today","News Online Today","News Online Today","The Abila Post","Homeland Illumination","International News","International Times","International Times","International Times","News Online Today","The Abila Post","World Source","All News Today","Central Bulletin","Central Bulletin","Central Bulletin","Daily Pegasus","International Times","News Online Today","News Online Today","News Online Today","News Online Today","The Abila Post","The Explainer","The Light of Truth","The World","Who What News","World Source","World Source","World Source"],"target_label":["News Online Today","News Online Today","Central Bulletin","All News Today","News Online Today","International News","News Online Today","Who What News","News Online Today","News Online Today","Central Bulletin","Who What News","The Explainer","Daily Pegasus","News Online Today","Everyday News","The Continent","World Journal","Daily Pegasus","Athena Speaks","News Online Today","Daily Pegasus","Athena Speaks","News Online Today","The Explainer","The Orb","World Source","Athena Speaks","Everyday News","The Continent","World Journal","News Desk","Athena Speaks","The General Post","The Light of Truth","News Online Today","Everyday News","The Continent","World Journal"],"arrows":["from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from","from"],"value":[20,19,13,11,11,10,10,9,6,4,4,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["Partially Primary","Derivative","Primary"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"},"legend":{"width":0.2,"useGroups":true,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true}},"evals":[],"jsHooks":[]}</script>

We can see that “News Online Today” actually grab most of their news from the 3 primary sources and even some of the partially primary source from weight of the arrow. What is interesting is that we find articles also posting after News Online Today though with a smaller degree. All of the primary sources have articles referring to them. What is interesting is that “Centrum Sentinel” and “Modern Rubicon” though are considered primary sources, do not have any duplicated titled articles with other news articles.

### 2\) Who is biased?

This section will answer part 2 of the challenge: Characterize any biases you identify in these news sources, with respect to their representation of specific people, places, and events. The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-who-is-bias-to-whom/)

**How many times do pok/governement/gastech appear?**
<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org_name-1.png" width="672" />

**What is the proportion of pok/governement/gastech in news articles?**
<img src="{{< blogdown/postref >}}index.en_files/figure-html/freq_of_org_name_perc-1.png" width="672" />

We can see immediately that there are 8 news sources that do not or rarely mention pok, we can infer that these articles write mainly about gastech.

  - The World
  - The Tulip
  - The General Post
  - The Light of Truth
  - Who What News
  - Centrum Sentinel
  - Modern Rubicon
  - Tethys News

However, for the other news articles, they generally have an even distribution of mentions of pok, government and gastech. From our literature review, we understand that in particular “Homeland Illumination” has a strong inclination for POK.

Thus we ran a sentiment analysis to see what are the sentiments of each news article.

<img src="{{< blogdown/postref >}}index.en_files/figure-html/sentiment_analysis_pok-1.png" width="672" />
<img src="{{< blogdown/postref >}}index.en_files/figure-html/sentiment_analysis_gastech-1.png" width="672" />

We can observe that even though “Homeland Illumination” is pro-POK, the general tone of the article is still very negative whether or not the article contains the words POK or GASTech. This suggests that the tone of these articles slants towards POK by painting a negative situation. From this we can see that “The Truth” and “The Guide” are probably pro-GASTech as well.

On a side note: The Abila Post overall contains many very negative news articles.

### 3\) Connections and Relationships

This section will answer part 3 of the challenge: Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. The complete step by step thought process and documentation can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-20-mc1-connections-revealed/)

From some literature review and assumptions that those with the same surname are family, we can see the connections below.

<div id="htmlwidget-2" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"nodes":{"id":[2,7,9,13,17,18,23,24,31,33,36,38,42,50,51,53,55,56,59,67,68,69],"FirstName":["Adan","Benito","Birgitta","Claudio","Edvard","Elsa","Henk","Hennie","Isia","Kare","Linda","Loreto","Minke","Valeria","Varja","Vira","Henk","Carmine","Mandor","Lemual","Neske","Juliana"],"LastName":["Morlun","Hawelon","Frente","Hawelon","Vann","Orilla","Mies","Osvaldo","Vann","Orilla","Lagos","Bodrogi","Mies","Morlun","Lagos","Frente","Bodrogi","Osvaldo","Vann","Vann","Vann","Vann"],"group":["GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","GASTech","POK","POK","POK","Public","Public","Public"],"label":["Adan Morlun  ","Benito Hawelon  ","Birgitta Frente  ","Claudio Hawelon  ","Edvard Vann  ","Elsa Orilla  ","Henk Mies  ","Hennie Osvaldo  ","Isia Vann  ","Kare Orilla  ","Linda Lagos  ","Loreto Bodrogi  ","Minke Mies  ","Valeria Morlun  ","Varja Lagos  ","Vira Frente  ","Henk Bodrogi  ","Carmine Osvaldo  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  "],"x":[0.856431205298791,0.134945228585424,0.150337711100652,0.324777126381276,-0.699945926076489,0.643618201855506,-0.3983075115797,0.966185398187784,-0.451615278290924,0.452538197973952,-1,0.447775073737424,-0.531448636819052,0.910773806170877,-0.957687856579898,-0.108510032405938,0.261944056566356,1,-0.530177145579643,-0.394932430130946,-0.748976020608161,-0.617127088927439],"y":[-0.591192175419257,0.0909018324051951,0.986414546062662,-0.0990464520412695,-0.678265602412452,0.755989656224268,0.526244693794053,0.344390501506547,-0.452022978750236,0.58019345224699,0.233173306777055,-0.825522049962855,0.753591814615478,-0.351508661919214,0.478536531953453,1,-1,0.100251263200776,-0.729957675714822,-0.617053521791497,-0.509721242507751,-0.391173468865311]},"edges":{"from_label":["Loreto Bodrogi  ","Birgitta Frente  ","Benito Hawelon  ","Linda Lagos  ","Henk Mies  ","Adan Morlun  ","Elsa Orilla  ","Hennie Osvaldo  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Edvard Vann  ","Isia Vann  ","Isia Vann  ","Isia Vann  ","Isia Vann  ","Mandor Vann  ","Mandor Vann  ","Mandor Vann  ","Lemual Vann  ","Lemual Vann  ","Neske Vann  "],"LastName":["Bodrogi","Frente","Hawelon","Lagos","Mies","Morlun","Orilla","Osvaldo","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann","Vann"],"to_label":["Henk Bodrogi  ","Vira Frente  ","Claudio Hawelon  ","Varja Lagos  ","Minke Mies  ","Valeria Morlun  ","Kare Orilla  ","Carmine Osvaldo  ","Isia Vann  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Mandor Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Lemual Vann  ","Neske Vann  ","Juliana Vann  ","Neske Vann  ","Juliana Vann  ","Juliana Vann  "],"from":[38,9,7,36,23,2,18,24,17,17,17,17,17,31,31,31,31,59,59,59,67,67,68],"to":[55,53,13,51,42,50,33,56,31,59,67,68,69,59,67,68,69,67,68,69,68,69,69],"label":["family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family","family"],"sum":["93","62","20","87","65","52","51","80","48","76","84","85","86","90","98","99","100","126","127","128","135","136","137"],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":false},"physics":{"stabilization":false},"layout":{"randomSeed":123}},"groups":["GASTech","POK","Public"],"width":null,"height":null,"idselection":{"enabled":true,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","igraphlayout":{"type":"square"},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"}},"evals":[],"jsHooks":[]}</script>

We observe that there are many ‘family’ members within GASTech. However, what is concerning are the relationships between POK memebers and GASTech members:
\*

#### View connection via email headers

We can view the connection between employees within GASTech by selecting the relavent email headers.

<iframe src="https://yenngee-dataviz.shinyapps.io/email_headers/" width="700" height="500&quot;">

</iframe>

#### Highlights of Suspicious Emails sent by Suspicious People

**Action: Virus detected on your system**
![](image/Email_action_virus_detected_on_your_system.JPG)<!-- -->

**Cute**
![](image/Email_cute.JPG)<!-- -->

**Files**
![](image/Email_files.JPG)<!-- -->

**FW: Arise inspiration for defenders of Kronos**
![](image/Email_fw_arise_inspiration_for_defenders_of_kronos.JPG)<!-- -->

**Plants**
![](image/Email_plants.JPG)<!-- -->

**Do you like the folowers**
![](image/Email_do_you_like_the_flowers.JPG)<!-- -->
