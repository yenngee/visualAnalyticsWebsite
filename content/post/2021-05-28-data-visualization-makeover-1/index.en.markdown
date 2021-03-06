---
title: "Data Visualization Makeover 1"
author: "Ng Yen Ngee"
date: '2021-05-28'
slug: []
cover: "/img/import_export_map.jpg"
categories: []
tags: ["Tableau", "DataVizMakeover", "MITB"]
output:
  blogdown::html_page: 
    toc: true
---

As part of Visual Analytics Course taken for SMU-MITB course. We are assigned a data visualization to critique and propose an alternative design. This is the first data viz makeover. The assignment can be found [here](https://isss608.netlify.app/dataviz/dataviz1) 




## 1 Critique of Visualization 

Original visualization can be seen below: 

<img src="img/original_viz.jpg" width="690" />

The original visualization has its own flaws. We will be critiquing them below: 

### By Aesthetics 

No. | Description of Critique	| Consequence/Remark 
--- | ----------------------- | ------------------------------------------
A1  | The font size of the overall title is smaller than the subtitle of each graph. | The attention is immediately drawn to each country’s names instead of the main title which would tell us what this graph is telling us.
A2  | There is no annotation to convey insights | The visualization just presents a bunch of numbers where audience are unable to make head or tails of. <br> e.g. there is a dip in both exports and imports for Mainland China during 2020 that is likely due to spreading of COVID and annotation should include events like this. 
A3  | Graphs is in a 2 by 3 grid. | Gives the impression that the category splitting the row is different from the category splitting the column which is not true. It also makes it difficult to compare information across countries. 
A4  | There is no order in the placement of countries. | More insights can be derived if we ordered the data in a logical way. 
A5  | Overlapping of area chart colours makes it rather ugly and difficult to read | 

### By Clarity 
No. | Description of Critique	| Consequence/Remark 
--- | ----------------------- | ------------------------------------------
C1  | The width of the x-axis is all different for all countries. | Gives the wrong impression that some countries have more exports/imports based on area. 
C2  | The range of the x-axis is different for Japan, and only shows 2020 on the x-axis | Gives the wrong impression that there is no trade in 2019.
C3  | Within a single subplot, the left and right y-axis have different ranges and scale, resulting in similar heights of area chart between Exports and Imports. | Gives the wrong impression that the amount of Import and Export are around the same for all countries. However, this may not be true. <br> E.g. for Hong Kong, Export ranges below 1 Million while Imports ranges above 4 Million.
C4  | The y-axis across all 6 countries has different scales and ranges resulting in similar heights of area charts across countries. | Gives the wrong impression that trade is consistent across all countries. However, if 2 countries are being compared it is apparent that this is not true. <br> E.g. Hong Kong vs Mainland China, Mainland China has higher amount of Import than Hong Kong 
C5  | The x-axis and y-axis have no tick marks even through it is a quantitative scale. | It makes data difficult to read. 
C6  | Area charts used to represent Export and Import are overlapping. | Area charts are best used for establishing part-to-whole relationship or to exaggerate change. 

## 2 Visualization Makeover 

### Proposed Design

Considering that we want to minimize changes made to the original visualization as much as possible, the visualization has been redesigned as follows: 

<img src="img/design_draft.jpg" width="768" />

Below I will discuss the various key changes that has been made and explain why the changes were made and which critique in the earlier section did these changes overcome: 

#### **Keeping area chart type but stacking them instead.**
As we are looking at Singapore's top 6 merchandise trading partners and not just each countries' export and import, it was decided to use stacked area chart to visualize the merchandise trade (sum of import and export) which shows the part to whole relationship well. Hence, we are also able to see the proportion of import and export relative to the sum of them like how Hong Kong has a very low import but actually has higher overall merchandise trade than that of Japan. This overcomes the issues raised in [**_C6_**](#by-clarity) and [**_A5_**](#by-aesthetics).

#### **Using a single y-axis.**
One of the key confusing points in the original design was that the y-axis keeps changing for both imports and exports and for all six countries stated in [**_C3_**](#by-clarity) and [**_C4_**](#by-clarity). Hence, in the proposed design, merchandise trade of each country shares the same y-axis on the left by placing all 6 countries on the same axis, dividing the visualization into 6 subplots horizontally instead of a 3 by 2 grid (discussed in [**_A3_**](#by-aesthetics)).  This also makes it easier to compare number across countries.

#### **Countries' merchandise trade are ranked in descending order**
We know the top 6 trading countries, but do we know the country with the highest merchandise trade? Do we know out of the 6 countries, which country has the lowest trade? This was one of the critique made in [**_A4_**](#by-aesthetics) which we corrected by adding the order in which the countries are placed so that we can see this ranking at a single glance. 

#### **Using Quarterly data instead of monthly data**
Unfortunately, one drawback of using a single y-axis and comparing 6 countries like this in 6 horizontal subplots is that each subplot has limited x-axis space. If we were to show 2 years worth of monthly data, the level of detail shown by the area of chart would be too messy. Keeping in mind that we want to show Singapore's top 6 trading partners across 2 years, it was decided that aggregating to quarterly data is sufficient to show just enough variation across time and yet not over complicate the visualization. 

#### **Consistent x-axis range in each subplot.** 
To solve [**_C1_**](#by-clarity) and [**_C2_**](#by-clarity), we ensured that the axis in each subplot is of the same width, with the same range starting from 2019 Q1 to 2020 Q4. 

#### **Other fixes**
Other fixes were made such as 

* Ensuring that the visualization title has the largest font ([**_A1_**](#by-aesthetics))
* Adding annotations referring to certain portions of the graph to deliver insights more effectively [(**_A2_**](#by-aesthetics))
* Ensuring that y-axis and x-axis all have tick marks ([**_C5_**](#by-clarity))



### Proposed Visualization 
The final proposed visualization is as follows: 

<img src="img/final.jpg" width="692" />

The visualization can also be access on [Tableau Public](https://public.tableau.com/app/profile/yen.ngee/viz/SingaporeTop6TradingPartners/SGTop6TradingPartners)

## 3. Step by Step Guide
In this portion, we will be running through the steps to create the final proposed visualization starting from loading and understanding the data, then we will run through what is done to prepare the data and finally creating the visualization on Tableau. 

### Loading and Understanding the data
The Data obtained from the subsection of [Merchandise Trade by Region/Market](https://www.singstat.gov.sg/find-data/search-by-theme/trade-and-investment/merchandise-trade/latest-data ) and was downloaded by clicking on the link Download all in Excel on the same web page. 

Opening the Excel file we see that there are 3 tabs:

*	Content – describes the content of the data in each page, hence we will not use this sheet. 
* T1 – Merchandise Imports 
*	T2 – Merchandise Exports 

<img src="img/step-A1_excel.jpg" width="331" />


On the top and bottom of the tab, there are notes which we would need to remove in our data preparation step. The header row starts from 6th row. There is data with countries represented by row and monthly data represented by columns. Looking at the first few rows, there are also aggregated such as Total Merchandise and regional data such as Asia(Million Dollars) which we will need to remove. Across the columns, we would also only need to extract data from 2019 Jan to 2020 Dec. T2 has a similar structure as T1 and will be prepared in a similar way. 

<img src="img/step-A2_T1_top.jpg" width="331" />


<img src="img/step-A2_T1_bottom.jpg" width="331" />

In our proposed visualization, we are looking at both exports and imports in a stacked area chart across time and country. Hence, we will need to prepare the data such that it is in a long format which makes it easier to manipulate in Tableau. The final form of the data should look something like this: 

<img src="img/step-A3_T1_final.JPG" width="251" />

### Data Preparation
We will be using Tableau Prep Builder to prepare the data. Each step is explained carefully such that it can also be replicated using alternative means. 

#### **Step 1: Connect to Data Source**
After opening Tableau Prep Builder Software, we first need to connect to the Data Source. In this case, we will connect to the excel file that was previously downloaded.

<img src="img/step-B1_connect.jpg" width="562" />

#### **Step 2: Add Data to Flow**
In the new interface, drag and drop T1 onto the working space on the right. Tableau Prep Builder will automatically load the data. However, we can see that it has also included the notes that we need to delete. Tableau has a handy button on the left called Use `Data Interpreter` which automatically extracts the table data without us having the manually delete the columns. 

<img src="img/step-B2_data_interpret.JPG" width="819" />

From there, if we right click on T1, we can choose various steps to treat the data. We will first clean the data. 

<img src="img/step-B2_add_sheetdata.jpg" width="331" />

#### **Step 3a: Clean T1 - filter the data**
At this step, our data looks like this. 

<img src="img/step-B3_before_clean.JPG" width="676" />

As mentioned in Loading and Understanding the data section, we need to exclude the aggregated data. Selecting the first 7 rows until "European Union (Million Dollars)", we can right click and select `Exclude` to exclude these data. At the same time, our visualization only include data from 2019 to 2020. Hence, we select the columns from all other dates and select `Remove`. What is left is the Import data of all countries from 2019 to 2020. 

Note: at this point, we could possibly only keep data from the 6 countries identified in the original visualization. It was just a personal choice to keep all of the data for now, so that we can do other visualization with all of the trade data for fun. ;) 

<img src="img/step-B3_filter.jpg" width="331" />


#### **Step 3b: Clean T1 - Split column to get country** 

If we look under variables, we know that it is in the format of "white space" + "country name" + "(Thousand Dollars)". We want to only extract the country name, keeping in mind the values are in thousands. Hence, if we click the 3 dots on the column, we can do an `Automatic split` which will extract country name. The original column is then removed as we do not need it and the new column name is changed to "Country".

<img src="img/step-B3_split.jpg" width="258" />

The data after this step should look like this:

<img src="img/step-B3_after_clean.jpg" width="301" />

#### **Step 4: Pivot T1**
Next, we have to convert all the data in each column and pivot them into rows. To do so, we first select all the columns except for "Country", and click on `Pivot Columns to Rows`.

<img src="img/step-B4_to_pivot.jpg" width="319" />

This will automatically create a pivot step where they will keep the "Country" as it is and create row with each row containing the value found within the original column. We rename "Pivot1 Names" as "Date" and "Pivot1 Values" as "Import (in thousand)"  

<img src="img/step-B4_after_pivot.jpg" width="330" />

#### Repeat steps 2 to 4 for T2, except to rename the column after pivoting as "Export (in thousand)" since T2 has the same structure as T1.


#### **Step 5: Join Pivoted T1 and Pivoted T2**
Now we would like to combine the data set. There are different ways of doing this. However, I chose to inner join the two data sets on "Country" and "Date". This means that the data left are countries that must have both imports and exports throughout the period of 2019 and 2020. 

To do this, we simply drag `Pivot 2` over `Pivot 1` under the join option which will appear when you hover over it. This will be the result after removing the duplicated columns of "Date" and "Country": 

<img src="img/step-B5_after_pivot.jpg" width="301" />

Note: a manual check confirms that the 6 countries that we are concerned with is part of this data set.


#### **Step 6: Clean**
At this point, it is easy to convert the "Import(in thousands)" and "Export(in thousands)" to the values multiply by 1000. Clicking the 3 dots, we select `Create Calculated Field`, then `Custom Calculation`. 

<img src="img/step-B6_calculated_field.jpg" width="177" />

We'll come to this pop up where we can key in our new column. We will follow the following formulas:

* Export = [Export(in thousands)] * 1000
* Import = [Import(in thousands)] * 1000

<img src="img/step-B6_calculated_field2.jpg" width="331" />

We remove the old columns and select the 2 new columns ("Import" & "Export") and pivot them again. 

#### **Step 7: Pivot + Final Clean**
We are very close to the final table that we need. We just need to do a final check on the column name data type and change them where necessary: 

*column name change:
  + "Pivot1 Name" to "Trade Type"
  + "Pivot1 Value" to "Amount"
*data type change: 
  + "Date": from string to date type 

Here is the final table: 

<img src="img/step-B7_final.jpg" width="270" />

In the work space, we can also see the following work flow: 

<img src="img/step-B7_final_flow.jpg" width="552" />

#### **Step 8: Output**
We could create an output node to output the data. However, Tableau Data Prep allows us to have a shortcut. By right-click on the last node and selecting `Preview in Tableau Desktop`, we can create the visualization directly. 

### Create Visualization 
We will be using Tableau Desktop to create the visualization and this section will provide a step by step guide to do so. Before we begin, it is always good to have cursory check on the data type. We see that "Country", "Date" and Trade Type are dimensions while "Amount" is in Measure.

#### **Step 1:**
The first step is to drag and drop the data into our graph. 

* Columns: we drag "Country" and "Date"
* Row: we drag "Amount" 

Automatically, Tableau calculates the sum of the "Amount" which is exactly what we need. For "Date" it automatically selects the "Year" as an input dimension. 

<img src="img/step-C1_drag_and_drop.jpg" width="347" />

#### **Step 2:** 
We can see from the screenshot above there are too many countries. Hence, we need to filter the data by "Country". Drag and drop "Country" onto the Filter card next to the graph. A window will pop-up (see screenshot below). From there we will manually select the top 6 countries: United States, Malaysia, Hong Kong, Japan, Mainland China and Taiwan. 

<img src="img/step-C2_filter_country.jpg" width="422" />

Results will look like this:

<img src="img/step-C2_filter_country_after.jpg" width="452" />

#### **Step 3:**
Now we have line charts of each countries' total trade merchandise. However, we would like to split them into "Import" and "Export". We drag "Trade Type" and drop them in `colour`. Tableau will split the data to 2 lines. 

<img src="img/step-C3_trade_type.jpg" width="301" />

#### **Step 4:**
Tableau automatically churns out line graphs for us. However, following our proposed design, we want an area chart. On the left side under `Marks`, we can select `Area` in the drop down to turn this into an area chart. 

<img src="img/step-C4_area_chart.jpg" width="690" />

#### **Step 5:**
This shows the yearly data for each country but we want quarterly data. Hence clicking on the triangle in the "Year(Date)" on "Date", we can select `Quarter` from the list. Note that we choose the `Quarter` in the lower section, this would give a measure rather than a dimension. This means that the area chart would be continuous within each countries' subplot. 


<img src="img/step-C5_change_to_quarter.jpg" width="452" />

This is the result: 

<img src="img/step-C5_result.jpg" width="301" />


#### **step 6:**
Now we have the foundation of the visualization. Let's sort them in descending order. Under the `Filters` card, we click the triangle button on "Country" and select sort. A window will pop-up and we need to select such that we are sorting by `Field`, in descending Order, using the `Field Name`: "Amount" with `Aggregation`: "Sum". 


<img src="img/step-C6_sort.jpg" width="301" />

This is the result: 

<img src="img/step-C6_result.jpg" width="301" />

#### **Step 7:**
Let us now adjust the axis. For the y-axis, the values are in Billions with horizontal grid lines. All we need to do is to add the units to indicate dollars. So we right-click on the y-axis, and select format in the drop down. The formatting pane will appear on the left. Since we are formatting the axis, we do not change the tab. Under the scale, we can format the `Number` selecting `Currency [Custom]`: 

* Decimal places: 0 
* Display Units: Billion (B)

The changes can be seen immediately on the y-axis: 

<img src="img/step-C7_yaxis.jpg" width="452" />


#### **Step 8:**
Formatting x-axis is slightly more tricky. Due to the limited space, we face the following issues for each subplot: 

* not able to display label for all quarters. (i.e. cannot use 2019 Q1, 2019 Q2,...,  2020 Q4)
* not able to display simplified labels either (i.e. cannot use Q1, Q2, Q3, Q4, Q1, Q1, Q2, Q3, Q4)
* not able to display the year to split the "Quarters" without splitting area chart per country which is not what we want. (If we add year, it will be added as a dimension variable and tableau will automatically displays it on top. If we use only dimension variable, the graphs will split as mention.)

Hence to overcome these issues, we worked around it: 

First let us format the x-axis such that it displays Q1,Q2 etc. Right click on the x-axis and selecting format will open the format pane on the left. 
Under Scale, `Dates`, we select `Custom` and key in "Q"q. 

We can see the changes immediately on the right. 

<img src="img/step-C8_xaxis_format.jpg" width="428" />

Let us also change all the font size under `Default` and `Title` to size 8, `Tableau Book`.  

<img src="img/step-C8_xaxis_font.jpg" width="301" />

Next we right click on the x-axis to `Edit Axis`, and click on the tab `Tick Marks`
We uncheck `Show times` as this is irrelevant for us. We will do the following changes: 

* Major Tick Marks 
  + select Fixed
  + Tick origin: 1/1/2019 
  + Interval: 2
  + Unit: Quarters 
* Minor Tick Marks 
  + select Fixed
  + Tick origin: 1/4/2019 
  + Interval: 2
  + Unit: Quarters 

Now we can see that there are tick marks every quarter. The major tick marks will mark Q1 and Q3. 

<img src="img/step-C8_xaxis_tick.jpg" width="301" />

Switch to `General` to update the `Axis Title` by keying in "2019       |      2020" into `Title` 
This is the little trick to label the year in the x-axis since the title will always be centered for each subplot. 

<img src="img/step-C8_xaxis_title.jpg" width="301" />
Now we have a good x-axis with consistent width, consistent tick marks, sufficient labels. This is the end result: 

<img src="img/step-C8_results.jpg" width="301" />

#### **Step 9:**
Next we want to add circles to the total merchandise trade to indicate the points more clearly. Unfortunately, Tableau does not provide the option of adding shapes or marks to the individual points for area charts unlike line chart. Hence, we need to work around it by using dual axis. 

First, we drag Amount to the right side of the chart until we see a dotted line. This will duplicate the same chart only with the y-axis on the right this time. If we look at the card under Marks, there is now additional cards. We pick the second one and make the following changes: 

* Change `Area` to `Circle` in the dropdown
* Remove "Trade type" from `colour` as we do not need to split the data 
* change the `colour` to something darker for visibility 
* change the `size` to something smaller so that it does not overwhelm the visualization. 

The results will be something like this: 

<img src="img/step-C9_add_circles.jpg" width="301" />

#### **Step 10:**
Let us be a bit more specific with our titles. 
For the title at the y-axis, let us rename it as "Merchandise Trade Amount"
For the "Country" at the top, it is rather redundant and so we will remove it. 
For the overall title we will write: "Singapore's Top Six Merchandise Trading Partners (2019-2020)"

Let us also adjust the font size and font for consistency and so that attention is in the right place: 

* Title Format: Tableau Light, size 15, Bold
* "Country" Format: Tableau Book, size 9, colour html: #555555
* y-axis title Format: Tableau Book, size 9, colour html: #555555

The results will be something like this: 

<img src="img/step-C10_results.jpg" width="301" />

#### **Step 11**
Now to add annotations and reference lines. Right-click on the white space to select annotations, and then `Area`, will pop-up a window for editing the annotation. For this visualization, we select `Font` = "Tableau Book" and `Font Size` = 9. We place the annotations in areas where the content of the annotations makes the most sense, taking into consideration the white spaces in the visualization. 


<img src="img/step-C11_annotate.jpg" width="301" />

One unique even that happened in 2020 is the spreading of COVID, which affected the whole world. To highlight that period, we added a reference band. 
On the x-axis, right click to select `Add Reference Line`. A window will pop-up. As we would like to highlight a segment for each country, we select `Band`, `Per Pane`, ensuring that the date values in `Band From` is "1/1/2020" and date values in `Band To` is "1/4/2020". Next, we edit the `Label` to `Custom`, entering "Covid Worsen in SG", putting the `Label` to `None` under `Band To` so that only one label will appear.

<img src="img/step-C11_ref_band.jpg" width="278" />

#### **and we are done!**

## 4 Derived Insights

### Insight 1
Singapore's top 6 merchandise trading partners are as follows, ranked in descending order: 

1. Mainland China
2. Malaysia 
3. United States 
4. Taiwan 
5. Hong Kong
6. Japan

This ranking does not surprise us. As the [world's manufactoring superpower](https://www.statista.com/chart/20858/top-10-countries-by-share-of-global-manufacturing-output/) and given geographical proximity, it is natural for China to become the highest merchandise trading partner of Singapore. This is followed by Malaysia, just by virtue of the fact that Singapore and Malaysia are neighbours and transporting goods are made convenient. The United States comes a close third as the [third largest global merchandise exporter](https://www.statista.com/topics/1308/trade-in-the-us/#:~:text=In%202018%2C%20the%20United%20States,the%20world's%20total%20export%20trade.). Followed by Taiwan, Hong Kong and Japan which are all in Asia. It is also interesting to note that all 6 countries have [Free Trade Agreements](https://www.mti.gov.sg/-/media/MTI/improving-trade/FTAs/All-you-need-to-know-about-SG-FTAs-and-DEAs.pdf) with Singapore. 

Even though there is a clear ranking, we can also see from the visualization that there is no one country's trade that exceeds other countries' trade by a large proportion which implies that Singapore does not solely rely on a single country for imports and exports. 


### Insight 2
If we observe the proportions of the export and imports in the visualization, we can see an exception where Singapore's trade exports with Hong Kong is at least 10 times bigger than that of imports resulting in a large merchandise trade surplus. (This only occurs with Hong Kong and not with any of the other 6 countries.) It seems that Hong Kong is at the disadvantage here, however, knowing that Hong Kong has close relations with Singapore, it is likely that Hong Kong benefits from Singapore through means other than merchandise trading. 

[Notes about trade](https://www.thebalance.com/balance-of-trade-definition-favorable-vs-unfavorable-3306261): 
+ Trade surplus (positive trade balance) -> when exports exceed imports 
+ Trade deficit (Negative trade balance) -> when exports are less than imports 
+ Trade surplus is harmful when government uses protectionism
+ Otherwise, most countries will strive for Trade surplus 


### Insight 3
In 2020 Q1-Q2 was when COVID situation worsened in Singapore, resulting in circuit breaker where many work places had to be shut down for 2 months except for essential services. It is expected that [trade (especially exports) fall](https://www.channelnewsasia.com/news/business/singapore-exports-q3-third-quarter-oil-nodx-13619218) during this period. This is apparent for Mainland China and Malaysia where we observe a relatively larger dip in trade in this period. There is a slight decrease in trade during this period for the other countries except for Taiwan and it could be that the goods that Singapore trade with Taiwan remains unaffected by the COVID situation. 
