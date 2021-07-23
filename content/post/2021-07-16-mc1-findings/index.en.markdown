---
title: 'MC1: Findings and Discoveries'
author: "Ng Yen Ngee"
date: '2021-07-25'
lastmod: '2021-07-25'
slug: []
cover: "/img/data_discovery.png"
categories: []
tags: ['MITB', "MC1", 'Text Analytics']
output:
  blogdown::html_page: 
    toc: true
---

# Introduction 
In this post, I will be running through the findings and analysis of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). This will be my main page and answer to my class [assignment](https://isss608.netlify.app/assignment.html). 

The objective of this assignment is identify the complex relationships between the people, organizations, news articles given the data that we have. 


## Content of all Posts 

Below and the table of content on the left is how we can navigate through the posts and analysis. Each section has a full post dedicated which runs through explanations, codes and actual visualizations. As analyzing in R and the data set is new to me, some of the posts are documented in a step by step manner with a run through of how I managed to arrive at the last visualization for my analysis below. Hence, some of the posts are quite lengthy. If you want to skip to the analysis bit, please scroll down to the analysis section of this post. 

* Literature Review [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-17-mc1-literature-review/)
* Data Preparation [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/)
* Analysis 
  * 1a) Primary Vs Derivative Sources [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-primary-vs-derivative-sources/)
  * 1b) Relationships:Primary vs Derivative Sources [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-15-mc1-explore-relationships-between-articles/)
  * 2) Who is biased? [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-who-is-bias-to-whom/)
  * 3) Connections and Relationships [Full Post](https://yenngee-dataviz.netlify.app/post/2021-07-20-mc1-connections-revealed/)

## Literature Review 



## Data Preperation
The complete **Data Preparation process** can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-11-mc1-data-preperation/). The data preparation has included a step by step description of understanding the data and transforming unstructured text such as the news articles into a structured dataframe. For this portion of the post, I will be starting from a cleaned data source. 


```r
library(tidyverse)
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
```

```
## v ggplot2 3.3.5     v purrr   0.3.4
## v tibble  3.1.2     v dplyr   1.0.7
## v tidyr   1.1.3     v stringr 1.4.0
## v readr   1.4.0     v forcats 0.5.1
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(tidytext)
```

## Analysis
### 1a) Primary Vs Derivative Sources 
This section will answer part 1a of the challenge: Which are primary sources and which are derivative sources?
The combined section of 1a) and 1b) will be limited to 8 images and 300 words. The step by step thought process and description of how to obtain.

Primary Sources is "first-hand" information. In terms of data, we've defined an article as the following: 
 



### 1b) Relationships:Primary vs Derivative Sources
This section will answer part 1b of the challenge: What are the relationships between the primary and derivative sources?



### 2) Who is biased? 
This section will answer part 2 of the challenge: Characterize any biases you identify in these news sources, with respect to their representation of specific people, places, and events. 
This section will be limited to 6 images and 500 words.




### 3) Connections and Relationships 
This section will answer part 3 of the challenge: Given the data sources provided, use visual analytics to identify potential official and unofficial relationships among GASTech, POK, the APA, and Government. Include both personal relationships and shared goals and objectives. Provide evidence for these relationships. 
This section will be limited to 6 images and 400 words.


## Conclusion 
