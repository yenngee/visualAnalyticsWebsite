---
title: "Data Visualization Makeover 2"
author: 'Ng Yen Ngee'
date: '2021-06-20'
slug: []
cover: "/img/trading_shake_hands.jpg"
categories: []
tags: ["Tableau", "DataVizMakeover", "MITB"]
output:
  blogdown::html_page: 
    toc: true
---

As part of Visual Analytics Course taken for SMU-MITB course. We are assigned a data visualization to critique and propose an alternative design. This is the second data viz makeover. The assignment can be found [here](https://isss608.netlify.app/dataviz/dataviz2).  


## 1 Critique of Visualization 

Original visualization can be seen below: 

<img src="img/original_viz.JPG" width="412" />

The original visualization has its own flaws. We will be critiquing them below: 

### By Aesthetics 

**A1 - A colour representing each partner**: Each partner is represented by a colour which serves no further purpose other than identifying countries. However this is redundant as there are labels identifying them, hence making the visualization colourful without any meaning. We could perhaps make better use of the colour to represent balance of trade thus showing additional information. 

**A2 - circles are opaque**: The overlapping opaque circles makes it difficult to read the information properly. While the designer has alleviate this problem by bringing the specific circle to the front when we hover over the circles so that we can see entire circle, it makes the graph unnecessarily cluttered. This could be easily avoided if we made the circles translucent instead. 

**A3 - displayed labels are redundant**: In A2, we know that when we hover above a specific circle, the specific circle will be brought to the front of the visualization. Given that such interaction is possible, the labels could have been brought out together with the interaction as opposed to being displayed making the visualization even more cluttered. Some of the labels even exceeded the visualization space. In fact we could have added more information such as amount imports and exports as part of the tool tip. 

**A4 - long note below explaining the white dot**: The best visualizations are when the visualization speaks for itself unless there are annotations to point out specific insights. This ruins the aesthetics and it makes it inconvenient for the reader to understand the visualization. It is unnecessary to write a paragraph if we could use other elements of visualization to provide the same information such as colour or using legends.

**A4 - long note below explaining the white dot**: additional symbols/legend indicating top net importer and exporters adds to the already cluttered visualization, reducing the aesthetics of it.

### By Clarity 

**C1 - Axis label not on typical side of Axis.** : Usually, the y axis label would be on the left of the y-axis and the x-axis label would be bellow the x-axis. However in this case: 

<img src="img/critique_axis.JPG" width="210" />

They have placed it in reverse. If we were to guess the intention of the original designer, they wanted the axis labels to be an extension of the x-axis and y-axis for aesthetic purposes. They have tried to reduce the confusion by colour coding the symbols consistently. However, this does not take away the initial confusion that most people will have. 

**C2- Misleading circle size**: When the total trade of one country is double another, the area of circle size is not double, but in fact quadrupled. 

<img src="img/critique_compare_size.JPG" width="210" />

The designer's intention was perhaps to show the trade differences by proportion using the diameter of the circle rather than the area. However, this will mislead the readers into believing that the total trade with Mainland China is 4 times larger than Hong Kong's total trade when in fact it is only 2 times larger. 

**C3 - Both axis does not start from 0**: To make space for the lovely animation which indicates the x and y label, the designer has decided to not to start the axis with 0. 

<img src="img/critique_axis.JPG" width="210" />

While it is alright for a scatter plot to not start from 0, unfortunately, there is no such thing as negative import and export and it would have been better to start the axis with 0, reflecting the possible ranges of imports and exports. 

**C4 - no tick marks nor grid lines**: Given that there is no tick marks on the axis nor grid lines, it makes it difficult to read the amount of import and export for each trading partner. The reader can only use their eyes to roughly estimate the differences.

**C5 - Information not shown in visualization**: The information below describes data from 2006 and 2009 which is not visualized in the current graph. 

<img src="img/critique_for_info.JPG" width="466" />

It is unknown why the original design had included this piece of information specifically and may confuse the readers. Furthermore, this information is at the bottom of the visualization and is easily missed. 

## 2 Visualization Makeover 

### Proposed Design

Considering that we want to minimize changes made to the original visualization as much as possible, the visualization has been redesigned as follows: 

<img src="img/design_draft.png" width="768" />

Below I will discuss the various key changes that has been made and explain why the changes were made and which critique in the earlier section did these changes overcome: 

#### **Fixing the axis **
Both the x and y axis now starts from 0, solving [**_C3_**](#by-clarity). We have also made sure that the axis labels are in the correct placement that does not give any ambiguity which solves [**_C1_**](#by-clarity). 

#### **Fixing area of circles ** 
Thankfully, when attaching a measure variable to size, we know that Tableau automatically ensures that the area of the circle is proportionate to the value it supposed to have which will eradicate [**_C2_**](#by-clarity). Nevertheless the design specifically included a note to not make the same mistake as the original designer. 

#### **Grid lines**
The design has added tick marks, though we know with Tableau's functionality, gridlines are also able to be easily added in, thus solving [**_C4_**](#by-clarity)

#### **Added interaction of year**
Given the option of interaction, we have designed the visualization such that we can select and animate the trade data through the years. We considered only keeping the recent 20 years partially because the additional 'for info' note described in [**_C5_**](#by-clarity) mentioned information in 2006 and 2009. 20 years is sufficiently recent enough to see trends over the years. 

#### **less clutter; more information**
The key concept is to de-clutter the visualization so that the more important things will shine. Thus we removed colour representing each partner [**_A1_**](#by-aesthetics), but instead used colour to represent balance of trade (exports - imports) which would also show our top net importer and exporter without explicitly highlighting it [**_A5_**](#by-aesthetics). We made sure that the colour of the visualization would be translucent as oppose to opaque [**_A2_**](#by-aesthetics), even though we would decide the colour later using one of Tableau's in built colour scheme to maximize the colour separation between our net importers and net exporters. We take away the labels but instead added tooltips with additional information, thus solving [**_A3_**](#by-aesthetics). With the colour representing balance of trade, it would naturally be unnecessary to include any long note like in [**_A4_**](#by-aesthetics) to describe it. 


### Proposed Visualization 
The final proposed visualization is as follows: 

<img src="img/final.JPG" width="562" />

The visualization can also be access on [Tableau Public](https://public.tableau.com/app/profile/yen.ngee/viz/Viz_v2_1/MerchandiseTradingPartners)

## 3. Step by Step Guide
In this portion, we will be running through the steps to create the final proposed visualization starting from loading and understanding the data, then we will run through what is done to prepare the data and finally creating the visualization on Tableau. 

### Loading and Understanding the data
The Data obtained from the subsection of [Merchandise Trade by Region/Market](https://www.singstat.gov.sg/find-data/search-by-theme/trade-and-investment/merchandise-trade/latest-data ) and was downloaded by clicking on the link Download all in Excel on the same web page. 

Opening the Excel file we see that there are 3 tabs:

*	Content ??? describes the content of the data in each page, hence we will not use this sheet. 
* T1 ??? Merchandise Imports 
*	T2 ??? Merchandise Exports 

<img src="img/step-A1_excel.jpg" width="331" />

On the top and bottom of the tab, there are notes which we would need to remove in our data preparation step. The header row starts from 6th row. There is data with countries represented by row and monthly data represented by columns. Looking at the first few rows, there are also aggregated such as Total Merchandise and regional data such as Asia(Million Dollars) which we will need to remove. Across the columns, we would also only need to extract data from 2019 Jan to 2020 Dec. T2 has a similar structure as T1 and will be prepared in a similar way. 

<img src="img/step-A2_T1_top.jpg" width="331" />


<img src="img/step-A2_T1_bottom.jpg" width="331" />

In our proposed visualization, we are looking at both exports and imports in a stacked area chart across time and country. Hence, we will need to prepare the data such that it is in a long format which makes it easier to manipulate in Tableau. The final form of the data should look something like this: 

<img src="img/step-A2_final.JPG" width="218" />

### Data Preparation
We will be using Tableau Prep Builder to prepare the data. Each step is explained carefully such that it can also be replicated using alternative means. 

#### **Step 1: Connect to Data Source**
After opening Tableau Prep Builder Software, we first need to connect to the Data Source. In this case, we will connect to the excel file that was previously downloaded.

<img src="img/step-B1_connect.jpg" width="562" />

#### **Step 2: Add Data to Flow**
In the new interface, drag and drop T1 onto the working space on the right. Tableau Prep Builder will automatically load the data. However, we can see that some of the rows has been captured as notes that we need to delete. Tableau has a handy button on the left called Use `Data Interpreter` which automatically extracts the table data without us having the manually delete the rows. 

<img src="img/step-B2_data_interpret.JPG" width="819" />

From there, if we right click on T1, we can choose various steps to treat the data. We will first clean the data. 

<img src="img/step-B2_add_sheetdata.jpg" width="331" />

#### **Step 3a: Clean T1 - filter the data **
At this step, our data looks like this. 

<img src="img/step-B3_before_clean.JPG" width="676" />

As mentioned in Loading and Understanding the data section, we need to exclude the aggregated data. Selecting the first 6 rows until "Africa(Million Dollars)", we can right click and select `Exclude` to exclude these data. We have opted to keep European Union even though it has the same denominator of Million dollars with the other regions. This is because European Union is a special case and is considered a single Market Partner despite it being consist of several countries.  

Note: at this point, we could possibly only keep data from the 10 countries identified in the original visualization with data from the year 2020. However, we choose to keep all of the data so that we can extend the visualization for more possibilities of animation within the visualization. ;) 

<img src="img/step-B3_filter_rows.JPG" width="380" />


#### **Step 3b: Clean T1 - Split column to get country** 

If we look under variables, we know that it is in the format of "white space" + "country name" + "(Thousand Dollars)". We want to only extract the country name, keeping in mind the values are in thousands and for the special case of European Union, in millions. Hence, if we click the 3 dots on the column, we can do an `Automatic split` which will split the original column into the variable we want. 

<img src="img/step-B3_split.JPG" width="242" />
The result after the split is the a new column "Variables - Split 1" which contains the Trading Partner's name in the format that we want. The original "Variables" column is then removed by clicking the 3 dots on the column, and selecting remove. "Variables - Split 1" is renamed to to "Trading Partner" simply by double clicking on the column name and keying in the new column name. 

The data after this step should look like this:

<img src="img/step-B3_after_clean.JPG" width="748" />

#### **Step 4: Pivot T1**
Next, we have to convert all the data in each column and pivot them into rows. To do so, we first select all the columns except for "Country", and click on `Pivot Columns to Rows`.

<img src="img/step-B4_to_pivot.JPG" width="850" />

This will automatically create a pivot step where they will keep the "Country" as it is and create row with each row containing the value found within the original column. 

<img src="img/step-B4_after_pivot.JPG" width="725" />

#### **Step 5: Create calculated field**
The values, as we noted in step 3b are in millions for European Union and thousands for all other Trading Partner. Hence, we need to create a new column to multiply the values by 1000. Click on the 3 dots and select `Create Calculated Field` and then `Custom Calculation`. 

<img src="img/step-B5_create_calculated_field.JPG" width="307" />

A pop up `Add Field` will appear. We key in the name "Imports" and the formula `[Pivot1 Values] * 1000` into the blanks and click `save`. A new column "Imports" will be created. 

We rename "Pivot1 Names" as "Date" and remove "Pivot1 Values" to get:  

<img src="img/step-B5_final_pivot_results.JPG" width="347" />

Notice that we have kept the null values in. These null values occur with the smaller trading partners. This is because Tableau does show if the visualization contains null values or not and would be a great indication to cross-check the data to understand why there was a null value. 

#### Given that T2 has the same structure as T1, we can repeat steps 2 to 5 for T2, except to name the calculated field after pivoting as "Exports".


#### **Step 5: Join Pivoted T1 and Pivoted T2**
Now we would like to combine the data set. There are different ways of doing this. However, I chose to inner join the two data sets on "Country" and "Date". This means that the data left are countries that must have both imports and exports throughout the years

To do this, we simply drag `Pivot 2` over `Pivot 1` under the join option which will appear when you hover over it. 

<img src="img/step-B6_after_join.JPG" width="754" />

Tableau automatically joins the two table on "Country". However, we want the tables to join on both "Country" and "Date". We select `Settings` on the left-hand side, then click on the plus simple on the top right hand of the `Settings` pane. We would be able to add "Date" as a second column to join on. 

<img src="img/step-B6_join_on.JPG" width="236" />

We select the venn diagram such that it is completely shaded to select a full outer join. This is so that we keep every data, including data that has imports but no exports and vice versa. 

<img src="img/step-B6_join_settings.JPG" width="174" />

#### **Step 6: clean and check data types **
We are almost done! Now what is left, is to check the data type. These are the desired data types of our data:

* "Date" - Date 
* "Country" - String
* "Imports" - Number
* "Exports" - Number

<img src="img/step-B7_datatype.JPG" width="418" />

We can see that we need to change our "Date" from string to date type. We select the `Abc` just on top of the column name. We can see that the data type is at `String`. We select `Date` to change the data type. 

<img src="img/step-B7_change_type.JPG" width="112" />

#### **Step 8: Output**
For an output, we create an output node to output the data. Selecting the folder and file name we want to save as, and clicking `Run Flow`, we create a .hyper extract which we would be using for creating our visualization. 



### Create Visualization 
We will be using Tableau Desktop to create the visualization and this section will provide a step by step guide to do so. 

#### **Step 1: Connect to data** 
Our very first step after opening Tableau desktop is to connect to a data source which we have prepared in the earlier step saved as a .hyper file. First we click on `More...` on the left hand side of the `Connect` pane. A window will pop up to request for the directory where the .hyper file is in. We select that file and press open. 

<img src="img/step-C1_open_file.JPG" width="684" />

At this point, it is always good to have cursory check on the data type by looking at the small icons on the top of each column. We see that "Date" has `Date` data type, "Trading Partner" has `String` data type and "Imports" and "Exports" have `Number(whole)` data type which is what we need and what has been saved in the Data Preperation step. 


<img src="img/step-C1_check_dtype.JPG" width="646" />

Selecting `Sheet 1` we come to the platform to start our visualization: 

<img src="img/step-C1_blank_sheet.JPG" width="958" />

On the most extreme left-hand side of the interface, we have our data columns, split into measures and dimensions. Measures will consist of our numerical columns while dimensions consists of our categorical columns. We will be dragging and dropping these columns to create our visualization. 

#### **Step 2: creating additional measures**
We will need 2 addtional measures for our visualization: 

* Total Trade: which is the sum of Imports and Exports
* Balance of Trade: which is Exports subtracted by Imports

With "Total Trade", we will be able to identify our top 10 trading partners. While with Balance of Trade we are able to identify our best Net Importer and Net Exporter. 

To do so we will need to create a new field. Right click on the empty space in the `Data` pane and select `Create Calculated Field`. A window will pop for us to key in the formula of the new column. 

<img src="img/step-C2_create_calculated_field.JPG" width="251" />

For "Total Trade", we key in details as follows and then select `OK`: 

<img src="img/step-C2_total_trade.JPG" width="584" />

For "Balance of Trade", we key in details as follows and then select `OK`: 

<img src="img/step-C2_bot.JPG" width="584" />

Now we have our new columns ready for use: 

<img src="img/step-C2_new_cols.JPG" width="160" />

#### **Step 3: Add axis variables: `Imports` and `Exports`** 
We first drag and drop the following: 

* "Exports" to `Columns`
* "Imports" to `Rows`

Automatically, Tableau will create scatter plot with one single point. 

<img src="img/step-C3_axis_vars.JPG" width="476" />

This is because Tableau does aggregation of measures automatically. To 'split the circle' we will take the next step. 

#### **Step 4: Add "Trading Partner" to `Detail`**
We drag and drop "Trading Partner" to `Detail`. Tableau now splits the single circle into many circles. If we hover over each circle, we can see that each circle now represents imports and exports of a particular trading patner.


<img src="img/step-C4_market_to_detail.JPG" width="479" />

However, we are only interested in Singapore's top 10 trading trading partners. Thus we will need to filter. 

#### **Step 5: Filter Top 10 Trading Partners**
We drag and drop "Trading Partner" to the `Filters` card on the left hand side. Automatically a `Filter [Trading Patner]` window will pop up, giving us various options to filter Trading Partner. As we can see, there are currently 113 Trading Partners (indicated under the Summary table below). 

<img src="img/step-C5_filter_partners.JPG" width="294" />

Next, we select the `Top` tab. We want to only see the top 10 trading partners, which is determined by the sum of total trade. We select the following options as shown in the screenshot below to do so: 

<img src="img/step-C5_filter_topn.JPG" width="292" />

After filtering we now have only the top 10 trading partner's data shown on the visualization. 

<img src="img/step-C5_after_filter_partner.JPG" width="528" />

However, we are showing all of the trading data from 1976 to 2021. We need to filter the dates as well. 

#### **Step 6: Filter Recent 20 years**
Similarly, we drag and drop the "Date" onto `Filters`. A window `Filter [Date]` will pop up. From here we want to select the `Range of Dates` and select `Next`

<img src="img/step-C6_filter_date.JPG" width="169" />

Given that we only want the recent 20 years, we set the range of dates from 1/1/2001 to 31/12/2020. 

<img src="img/step-C6_range_of_dates.JPG" width="410" />

We also want to see data per year as opposed to the sum of trade over 20 years. In preparation for including interactivity later, we drag and drop "Date" onto `Pages` card. Tableau automatically slices the data by year and creates a filter card on the right. We will run through the functions of the card in the future, for now, we have the visualization by year. 

<img src="img/step-C6_pages_dates.JPG" width="638" />

If we look at the bottom right hand side of the chart, the word `2 nulls` appears, signalling that there are data with null values. Let's see what they are. 

#### **Step 9: Treating Null Values**
To view the data, let us right-click on the white space within the visualization area, then select `View data`. 

<img src="img/step-C7_select_view_data.JPG" width="333" />

This is a handy tool to see the subset of the data that the visualization is drawing from. From data, we can immediately see that the 2 null values belong to Indonesia, meaning that there are no values 

<img src="img/step-C7_view_data.JPG" width="387" />

A quick check with the source data indicates that this is true and not a data preparation mistake. At this point, I will usually check with a domain expert to understand why there is no trade before 2002, unfortunately we do not have any domain experts to consult with, hence we shall assume that trade before 2002 is 0. Thankfully, Tableau provide us an easy way to do so.

If we select `2 nulls`, a window `Special Values for [Exports]` will pop up, showing us 2 options to treat null values, either to filter them away, or to show data at default position which is at 0. We select `Show data at default position`. 

<img src="img/step-C7_view_data.JPG" width="387" />

`2 nulls` is still there, we repeat the same steps again for "Imports" this time. Only then will `2 nulls` disappear. If we select 2001 to see, Indonesia is now at the 0B mark. 


#### **Step 8: Add Total Trade to size**
Each circle size is the same, let us add another piece of information by dragging "Total Trade" and dropping them onto `Size` under the `Marks` card. 

<img src="img/step-C8_total_trade_to_size.JPG" width="656" />

Tableau automatically changes the area of the circles to correspond to the amount of "Total Trade". Note that the differences in "Total Trade" corresponds proportionately to the area of the circle and not the diameter of circles. Hence, the differences between the sizes circles is smaller than what we observe in the original visualization. To make the differences slightly more obvious, let us increase the size. We select `Size` under the `Marks` card and a slider appears. Sliding the slider to the right increases the size of the circles. 

<img src="img/step-C8_change_size.JPG" width="624" />

Now that the size of the circle corresponds to "Total Trade", let us add one more information to the visualization.

#### **Step 9: Add Balance of Trade to Colour**
Drag and drop "Balance of Trade" onto `Colour` under the `Marks` card.

<img src="img/step-C9_bot_to_colour.JPG" width="659" />

Tableau automatically applies colour to the ranges of "Balance of Trade". It would be clearer if the circles are shaded in. Currently, Tableau automatically selects the visualization. Now click on he drop down under the `Marks` card, and select `Circle`. 

<img src="img/step-C9_select_circles.JPG" width="568" />

Now all the circles are filled in. 

<img src="img/step-C9_shaded_circles.JPG" width="659" />

Note that the colours are all opaque, hence we will need to adjust the opacity accordingly. Let us select the `Colour` under the `Marks` card. 

<img src="img/step-C9_opacity_borders.JPG" width="198" />

We can now choose opacity as 60% and add in a border to make the overlapping circles more obvious. We also want to edit the colours such that it provides the following information: 

* 2 extreme colours representing positive and negative balance of trade, showing who is our best net importer and exporter. 
* if balance of trade is nearing 0, it should be nearer to white colour 
* hence border colours should be greyish in colour to outline the white areas. 

If we click on `Edit Colors`, an `Edit Colors [Balance of Trade]` window will pop up. 

<img src="img/step-C9_edit_colours.JPG" width="256" />

For our case, let us select `Red-Blue-White Diverging` and `Use Full Colr Range` to make the colours more contrasting. This is our result. 

<img src="img/step-C9_after_colours.JPG" width="659" />
Some of the colours towards the middle of the graph is still quite similar. To make it even clearer, let us add a reference line. 

#### **Step 10: Add 45 degree diagonal reference line**
There is no in-built function to do so, and hence we will need to do some tricks on Tableau. The key concept is to create a line such that the Exports is equal to the Imports. 

First we create a new calculated field called "Reference Line", where it is just Exports. 

<img src="img/step-C10_create_reference_line_field.JPG" width="580" />

Let us drag and drop this to the Rows. Tableau creates a separate subplot, but we want the reference line to be on the same visualization. Hence, let us right-click on the `SUM(Reference Line)` and select `Dual Axis`.

<img src="img/step-C10_dual_axis.JPG" width="390" />

We note that the axis on the right is different from the left. Let us right click on the y-axis on the right and select `Synchronise Axis`. This will synchronise both axis. After sychronising, we do not require the right y-axis. Thus we can right click and de-select `Show Header`. 

<img src="img/step-C10_sychronize_axis.JPG" width="542" />

Under the `Marks` Pane, there is now a new card called "SUM(Reference Line)". We have the same colour and size settings as the "SUM(Imports)" card, which we do not need. Let us remove "Balance of Trade" and "Total Trade" from the shelf. 

<img src="img/step-C10_remove_measures.JPG" width="660" />

Using the same methods as how we edited the size and colour, let us reduce the size to the minimum and to change the opacity to 0%, removing the border by changing it to `None`. We will see the orginal graph again but not to worry, the reference line data is there, we just need to add trend line. We right-click on the white space, select `Trend Lines`, then `Show Trend Lines` and select `SUM(Reference Line)`

<img src="img/step-C10_show_trend.JPG" width="566" />

Now we can see a solid diagonal line cutting through the visualization where Imports is equals to the Exports. However, we want to make the trend line a little more subtle, and less attention grabbing. We right-click on the trend line to select `Format`. 

<img src="img/step-C10_select_format.JPG" width="498" />

We can format many different type of lines here, for now, we want to format Trend Lines. We select dotted lines, with the smallest thicknest, on a dark grey scale and opacity 100%.

<img src="img/step-C10_format_trend.JPG" width="285" />

We now have a diagonal reference line. Anything on the upper left triangle is a net importer and anything on the bottom right triangle is a net exporter. 

<img src="img/step-C10_after_ref_line.JPG" width="657" />

If we look carefully, we can see that the reference line is not exactly at 45 degrees. This is because the ranges of x-axis and y-axis is not the same. They also do not start from 0. 

#### **Step 11: edit axis**
We right-click on x-axis to select `Edit Axis` in order to edit our axis. 

<img src="img/step-C11_select_edit_axis.JPG" width="365" />

A window `Edit Axis [Exports]` will pop up. This is where we want to have a fixed axis. We fixed our start at 0 and the end at 85 Billion. We do the same for the y-axis. 

<img src="img/step-C11_edit_axis.JPG" width="338" />

And now we have a nice 45 degree reference line with proper axis and grid lines. 

<img src="img/step-C11_aft_edit_axis.JPG" width="658" />


#### **Step 12: formatting numbers**
We can see that the numbers on the axis is different from the numbers at the legends and we want them to be consistent. we right-click on axis to select `Format`

<img src="img/step-C12_select_format.JPG" width="250" />
The format pane will appear on the left. We want to change the number format, hence we select the dropdown at `Numbers` under the tab `Axis` and the section `Scale`. For the axis, we key in as follows in order to show number format like this S$10 B: 

<img src="img/step-C12_format_exports.JPG" width="262" />

This would change the x-axis. We take the exact same steps for the Y-axis. An alternative way to change the field would be to select `Fields` on the top right hand corner of the format pane.

<img src="img/step-C12_change_fields.JPG" width="345" />

We use this to change format for all of our measures variables ("Imports", "Exports", "Balance of Trade", "Total Trade")  such that they all follow the same format indicated above. 

<img src="img/step-C13_faulty_tooltip.JPG" width="191" />

When we hover our mouse over the circles, a tooltip will appear showing all of the trade information. We can see that there are different information that can be found in the tooltip. Let us organize it. 

#### **Step 13: editing tooltip**
we can edit the tooltip by selecting `Tooltip` under the `Mark` pane on the left hand side. After select, a window `Edit tooltip`. This is where we can make our edits for the tool tip. 

As an additional feature, we want to edit such that the "Balance of Trade" show a blue colour when it is positive, and red colour when it is negative. To do so, we create 2 new calculated fields with the following formula: 

<img src="img/step-C13_bot_positive.JPG" width="356" />

<img src="img/step-C13_bot_negative.JPG" width="356" />

Then we can edit the tooltip such that we follow the edits in the screenshot: 

<img src="img/step-C13_edit_tooltip.JPG" width="330" />

The created formulas gives a value when the balance of trade is positive or negative. Hence we assign a colour to the new created fields, and placing them side by side. When balance of trade is positive, the column "Balance of Trade (-)" will be negative and will not appear and vice versa. 

The outcome will be as follows: 

<img src="img/step-C13_tooltip_hk.JPG" width="196" />

<img src="img/step-C13_tooltip_tw.JPG" width="237" />


#### **Step 14: editing titles**
Let us clean up our titles. First, we right-click on the main title of the visualization, and select `Edit Title`. A window `Edit Title` will pop up. We will then fill the title as follows, with the following font type and font size: 

<img src="img/step-C14_edit_title.JPG" width="328" />

Next, we want to edit the titles of the legends. When we hover the triangle on the top right hand corner of each card at the legend. Then we select `Edit Title`

<img src="img/step-C14_select_edit_legend_title.JPG" width="118" />

After selecting, a window `Edit Legend Title` will pop up, giving us the option to rename the Legend Title. We will rename as such: 

* "YEAR(Date)" -> "Year"
* "SUM(Total Trade)" -> "Total Trade"
* "SUM(Balance of Trade)" -> "Balance of Trade" 


#### **Step 15: adding additional annotations**
Let us add an indication of 'Net Importers' and 'Net Exporters'. We right-click the white space on the visualization to select `Annotate` and then select `Area`. 

<img src="img/step-C15_create_annotations.JPG" width="248" />

We want to create a text with no box nor shading and large enough to see which side of the triangle belongs to 'Net Importers' and 'Net Exporters' but yet do not take away the attention from the bubbles. 

We follow the following format: 

<img src="img/step-C15_format_annotations.JPG" width="256" />

and the following text fonts and size: 
<img src="img/step-C15_edit_annotations.JPG" width="328" />

To obtain the words in the background. 

#### **Step 15: Animations and Interactions**
Given that we the data changes according to the year, we can add a smoother transitions by switching on the animations. 

<img src="img/step-C16_select_animations.JPG" width="319" />

As mentioned in step 6, we are able to show the data across the years with this card. If we start from 2001 and hit the 'play' button, bubbles will shift through the years and we can see the trend across the years even without a time series line graph in front of us. 

<img src="img/step-C16_across_year.JPG" width="78" />

If we switch on `Show history`, selecting the following format: 

<img src="img/step-C16_across_year_format.JPG" width="206" />

We are able to see the historical marks and trails of selected countries. 

<img src="img/insights - trails.JPG" width="388" />

#### **and we are done!**

## 4 Derived Insights


In the original visualization, it was noted the following: 

<img src="img/critique_for_info.JPG" width="466" />

Now with my updated visualization, we can definitely verify if this is true. 

### Insight 1 
**China** 
<img src="img/insights-info-china_2009.JPG" width="465" />

If we follow the trail carefully, we can see that the bubble falls on the left of the 45 degree reference line before 2009, while after 2009, the bubble falls on the right of the 45 degree. It is further verified using the tool tip of China at 2009, where we can see that the Balance of Trade is positive S$0.5B. If we observe the trails as a whole, we can see a general increasing trend that has exceeded all other trading partners to emerge as Singapore's top trading partner. The trade through the years are quite balanced as the trail is quite close to the 45 degree reference line. However, we can see in the recent 5 years that the amount of trade fluctuated a bit, and the increase is no longer as steady as it used to be in the first decade of the century. 

### Insight 2 
**US** 
<img src="img/insights-info-us_2006.JPG" width="378" />
We employ the same method to view US. Indeed the bubble falls on the right of the 45 degree reference line before 2006. After 2006, most of the bubbles are shaded a strong red which implies that many of the years US is one of our top Net Importers. However, there was a drastic switch where we can also see that the highlighted bubble that represents 2020 trade data, US is blue in colour, which suggests that for year 2020, exports has exceeded imports contrary to the earlier years after 2006. This coincides with COVID 19 pandemic that is happening throughout the world in the year 2020. 

### Insight 3
When we look through across the years, the animation makes it obvious that there is a general increasing total trade over the years as we see the bubbles generally moving towards the upper right corner of the visualization. One notable exception is during 2009 when all of the bubbles retreated back towards the 0 values before slowly increasing again. We have taken a snapshot of 2 separate years to show the difference between 2008 and 2009. The decrease coincides with the financial crisis that started in the second half of 2008, and the effects of it was felt in 2009. 

<img src="img/insights - side by side.JPG" width="606" />




