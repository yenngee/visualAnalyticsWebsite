---
title: 'MC1: Literature Review'
author: 'Ng Yen Ngee'
date: '2021-07-23'
lastmod: '2021-07-25'
slug: []
cover: "/img/lit_review.jpg"
categories: []
tags: ['MITB', "MC1", 'Text Analytics']
output:
  blogdown::html_page: 
    toc: true
---



# Introduction 
In this post, I will be running through the literature review of [Vast Challenge MC1](https://vast-challenge.github.io/2021/MC1.html). This data set and scenario has been used as a challenge before in 2014. Hence, I will be looking through some of the 'answers' and methodology that other groups have already [completed](http://visualdata.wustl.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/). 

The final analysis done can be found [here](https://yenngee-dataviz.netlify.app/post/2021-07-16-mc1-findings/).


## Information obtained XD 

Below is a collection of information extracted from previous groups. 

### Events on Jan 20th and 21st is listed below:

Collated by [Peking University](http://visualdata.wustl.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Peking%20University/)


> *Jan 20th:*
> 
> 10:00 AM:The meeting of the annual company of GASTech with a reception of government of Kronos is closed and the executives have not yet arrived. [Article 140] <br>
10:15 AM: Fire alarm goes off at GASTech headquarter. Abila Fire Department trucks were dispatched to GASTech Kronos headquarters. [Article 692, 738] <br>
10:20 AM: GASTech employees evacuate the building and a helicopter leaves from the roof of the building. [Article 763] <br>
10:25 AM: Firemen have entered the GASTech headquarter. [Article 13,470,563,844]<br>
10:52 AM: CEO Sanjorge arrived at the capitol building a few minutes ago. [Article 350,749]<br>
11:45 AM: AFD gives the all clear for the GASTech employees to re-enter the building. [Article 365,376]<br>
12:20 PM: The police of Aliba arrives at GASTech. [Article 355,806]<br>
12:25 PM: The reporter covering reception at the capitol sees the CEO, Jr. of Sten Sanjorge, but doesn't see the rest four of the excutives. [Article 67,122,528,569]<br>
12:30 PM: A private jet carried 7 or 8 passengers in a hurry departs Abila. [Article 202,324,633,718,721]<br>
12:45 PM: Additional Abila Police officers arrive at GASTech headquarters. [Article 356,425]<br>
14:05 PM: Kronos Government officials arrives at GASTech headquarters. [Article 805]<br>
14:30 PM: Another private jet carried 7 or 8 passengers who seemed celebrating departs Abila. [Article 202,324,633,718,721]<br>
15:12 PM: Two police vehicles each with two policemen in inside have just left GASTech headquarters with no lights or sirens. [Article 320,426]<br>
15:20 PM: GASTech employees are being allowed to leave the building. [Article 321]<br>
15:40 PM: One GASTech employee reports having seen several people dressed in black in the building before the fire alarm. These people were not GASTech employees are "were acting odd and lurking about".[Article 253,381]
17:00 PM GASTech's employee Edvard Vann is released after being questioned by Kronos Police and civil servant of government for 6 hours. [Article 440,466,512]<br>
17:10 PM: A GASTech administrator who had been supporting the executive meeting has informed us that the "people in black" present that morning were the caterers. [Article 368,395]<br>
18:10 PM: The GASTech executive jet reportedly arrived in Tethys a few hours ago bearing Sten Sanjorge Jr. The jet was quickly refueled and then departed for Abila International Airport with six GASTech officials onboard. [Article 26]<br>
22:32 PM: Airport officials have confirmed the arrival of a private jet from Tethys. Several passengers departed into a waiting limousine which drove directly to Abila Police Headquarters. [Article 744]


> *Jan 21st:*
> 
> 9:00 AM: The Abila police holds a press conference on the kidnapping GASTech headquarters. Police inform reporters that four of the GASTech employees whose whereabouts were unconfirmed yesterday were found overnight, leaving ten people who are presumed missing. [Article 276,372] <br>
10:16 AM: A GASTech spokesman announces that CEO Sten Sanjorge is not among the missing GASTech employees, and has returned to Tethys. [Article 556,624]<br>
12:00 AM: The Protectors of Kronos have released a statement claiming responsibility for the kidnapping of GASTech employees demanding a $20 million ransom. [Article 106,261,407,708] <br>


### Leaders of POK

The viz below is by [Tianjin-Cai](http://visualdata.wust.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Tianjin%20University%20-%20Cai/)

![](image/tianjin_cai_summary_5leaders.jpg)<!-- -->
### Extended Network of POK

The viz below is by [Tianjin-Cai](http://visualdata.wust.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Tianjin%20University%20-%20Cai/)

<img src="image/tianjincai_network_of_pok.png" width="519" />


## Methodology and Visualization

### Media clusters 

The viz below is by [Tianjin-Cai](http://visualdata.wust.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Tianjin%20University%20-%20Cai/)

![](image/cluster_medias_word_association.jpg)<!-- -->


I personally really like this graphic because we can see 

* how the news sources are being clustered, with the 'representative' news article source being highlighted. 
* it shows how the clusters are biased towards POK and government. 
* How certain words, like corruption, or terrorist is linked with the different sources. 

However, there are certain things that could be improved on, or have doubts about: 

* How did the creator come to these 10 words? 
* there are only links from Homeland Illumination to the words. The other news source do not have the links so we are not sure what the implications. 
* some lines are thicker but there is no explanation.

I might change this to a network graph, differentiating the nodes between sources and words, maybe pick out the top 10-30 words and figure out how to link to the main organization POK, Government and GASTech. 

### words over time

The viz below is by [Tianjin-Cai](http://visualdata.wustl.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Tianjin%20University%20-%20Gao/)

![](image/tianjingao_topics_sentiment_over_time.JPG)<!-- -->

The second and third area chart is quite interesting as they show the amount of positivity/negativity and the topics trend over the year. 

However, there are certain things that could be improved on, or have doubts about: 
* how did he determine the value of positivity and negativity in the second chart? 
* why were those words chosen? 

### relationship between people 

The viz below is by [Peking University](http://visualdata.wustl.edu/varepository/VAST%20Challenge%202014/challenges/MC1%20-%20Disappearance%20at%20GASTech/entries/Peking%20University/)

![](image/relationship network graph.gif)<!-- -->

This visualization is good because it shows all of the important names and their connections to each other. However, it is a little messy in the following sense: 

* Organizations and people's names are all nodes which makes it confusing. 
* the coloured edges represents different 'relationship, but some of them are labeled differently. 
* the labels are too small and hardly visible and also makes the entire diagram messy. 

I would want to recreate a similar picture but with a simplified relationships. 
For the nodes, I want to be able to differentiate different people with their official 'organization' 

* POK
* Government 
* General Public 

For the edges, i want to determine 3 types of relationships 

* colleagues: people who work in / work for the  
* familial relationships (based on known relationships or probable family due to same surname)
* news articles mentions (names that are mentioned together)


