---
title: "Lesson 8 Programming Geovisual Analytics with R"
author: Ng Yen Ngee
date: '2021-07-03'
slug: []
cover: "/img/geoviz.png"
categories: []
tags: ["R", "raster", "tmap", "MITB"]
output:
  blogdown::html_page: 
    toc: true
---




## Introduction to in-class exercise 8
As part of my lesson in SMU Visual Analytics, prof teaches data visualization in R using Rmarkdown. The post below acts as both an in-class exercise for the lesson, as well as my notes. 

Note to prof, if he is here: I have reorganized the in class exercise in a way that makes sense to me, but may not follow the step by step process prof went through in class. I have added additional items which I have kept as haphazard notes on my desktop.  Hope this is alright! 

## Load packages
Below is shortcut of how to load the packages in one shot. We can choose to add in whatever packages we want to load in the variable `packages`. This is an alternative code as oppose to loading the package line by line. 


```r
packages <- c('raster', 'rgdal', 'sf', 'tmap', 'tidyverse' )
#, 'clock'
for(p in packages){
  if(!require(p,character.only=T)) {
    install.packages(p)
  }
  library(p, character.only=T)
}
```
## Plotting

we use the `raster` package to see it as a raser layer. 


```r
bgmap <- raster("Geospatial/MC2-tourist.tif")
bgmap
```

```
## class      : RasterLayer 
## band       : 1  (of  3  bands)
## dimensions : 1595, 2706, 4316070  (nrow, ncol, ncell)
## resolution : 3.16216e-05, 3.16216e-05  (x, y)
## extent     : 24.82419, 24.90976, 36.04499, 36.09543  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs 
## source     : MC2-tourist.tif 
## names      : MC2.tourist 
## values     : 0, 255  (min, max)
```

tm_raster() is used to plot raster layer using tmap package. Unfortunately it only reads the tmp file as a one layer. We could use `tm_rgb()` instead. 


```r
tmap_mode("plot")
tm_shape(bgmap) + 
  tm_raster(bgmap, legend.show=FALSE)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/raster_plot-1.png" width="672" />

```r
tm_shape(bgmap) + 
  tm_rgb(bgmap, r=1, g=2, b=3, 
         alpha = NA, 
         saturation = 1, 
         interpolate = TRUE, 
         max.value = 255)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/raster_plot-2.png" width="672" />

reading shape file


```r
abila_st <- st_read(dsn = "Geospatial/Abila.shp",
                    )
```

```
## Reading layer `Abila' from data source 
##   `C:\Users\ngyen\Documents\yenngee\visualAnalyticsWebsite\content\post\2021-07-03-lesson-8-programming-geovisual-analytics-with-r\Geospatial\Abila.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 3290 features and 9 fields
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: 24.82401 ymin: 36.04502 xmax: 24.90997 ymax: 36.09492
## Geodetic CRS:  WGS 84
```



we can use read_csv to read the csv file. using `glimpse` to take a look at the data. We make the following observations: 

* Timestamp is not in datetime format 
* id is not in character format


```r
gps <-read_csv("aspatial/gps.csv")
glimpse(gps)
```

```
## Rows: 685,169
## Columns: 4
## $ Timestamp <chr> "01/06/2014 06:28:01", "01/06/2014 06:28:01", "01/06/2014 06~
## $ id        <dbl> 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, ~
## $ lat       <dbl> 36.07623, 36.07622, 36.07621, 36.07622, 36.07621, 36.07619, ~
## $ long      <dbl> 24.87469, 24.87460, 24.87444, 24.87425, 24.87417, 24.87406, ~
```

```r
# gps$Timestamp <- date_time_parse(gps$Timestamp, zone = "", format = "%m/%d/%Y %H:%M:%S" )
# currently unable to load package clock. below is an alternative code. 
gps$Timestamp <- as.Date(gps$Timestamp, "%m/%d/%Y %H:%M:%S")
gps$id <-as_factor(gps$id)

glimpse(gps)
```

```
## Rows: 685,169
## Columns: 4
## $ Timestamp <date> 2014-01-06, 2014-01-06, 2014-01-06, 2014-01-06, 2014-01-06,~
## $ id        <fct> 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, ~
## $ lat       <dbl> 36.07623, 36.07622, 36.07621, 36.07622, 36.07621, 36.07619, ~
## $ long      <dbl> 24.87469, 24.87460, 24.87444, 24.87425, 24.87417, 24.87406, ~
```


In the first step, we convert the tibble dataframe into geospatial points. 
In the second step, when we group by the ID, we can identify the pathway laid by the geospatial points. 


```r
gps_sf <- st_as_sf(gps, 
                   coords = c("long", "lat"), 
                   crs = 4326)
gps_sf
```

```
## Simple feature collection with 685169 features and 2 fields
## Geometry type: POINT
## Dimension:     XY
## Bounding box:  xmin: 24.82509 ymin: 36.04802 xmax: 24.90849 ymax: 36.08996
## Geodetic CRS:  WGS 84
## # A tibble: 685,169 x 3
##    Timestamp  id               geometry
##  * <date>     <fct>         <POINT [°]>
##  1 2014-01-06 35    (24.87469 36.07623)
##  2 2014-01-06 35     (24.8746 36.07622)
##  3 2014-01-06 35    (24.87444 36.07621)
##  4 2014-01-06 35    (24.87425 36.07622)
##  5 2014-01-06 35    (24.87417 36.07621)
##  6 2014-01-06 35    (24.87406 36.07619)
##  7 2014-01-06 35    (24.87391 36.07619)
##  8 2014-01-06 35    (24.87381 36.07618)
##  9 2014-01-06 35    (24.87374 36.07617)
## 10 2014-01-06 35    (24.87362 36.07618)
## # ... with 685,159 more rows
```

```r
gps_path <- gps_sf %>% 
  group_by(id) %>%
  summarize(m = mean(Timestamp), 
            do_union = FALSE) %>%
  st_cast("LINESTRING")
gps_path
```

```
## Simple feature collection with 40 features and 2 fields
## Geometry type: LINESTRING
## Dimension:     XY
## Bounding box:  xmin: 24.82509 ymin: 36.04802 xmax: 24.90849 ymax: 36.08996
## Geodetic CRS:  WGS 84
## # A tibble: 40 x 3
##    id    m                                                              geometry
##    <fct> <date>                                                 <LINESTRING [°]>
##  1 1     2014-01-11 (24.88258 36.06646, 24.88259 36.06634, 24.88258 36.06615, 2~
##  2 2     2014-01-11 (24.86038 36.08546, 24.86038 36.08551, 24.86022 36.08545, 2~
##  3 3     2014-01-11 (24.85763 36.08668, 24.85743 36.08662, 24.85727 36.08664, 2~
##  4 4     2014-01-12 (24.87214 36.07821, 24.87206 36.07819, 24.87195 36.07821, 2~
##  5 5     2014-01-11 (24.8779 36.0673, 24.87758 36.06736, 24.87746 36.06734, 24.~
##  6 6     2014-01-11 (24.89477 36.05949, 24.89475 36.05939, 24.89477 36.05932, 2~
##  7 7     2014-01-12 (24.86424 36.08449, 24.86421 36.08438, 24.86422 36.08423, 2~
##  8 8     2014-01-11 (24.88597 36.0673, 24.88595 36.06725, 24.88588 36.06705, 24~
##  9 9     2014-01-12 (24.85095 36.08172, 24.85095 36.08175, 24.85115 36.0818, 24~
## 10 10    2014-01-12 (24.86589 36.07682, 24.86587 36.07676, 24.86584 36.07657, 2~
## # ... with 30 more rows
```

Now to plot the gps_path. Unfortunately, tmap does not seem to be compatible with .rmarkdown files with hugo theme. So I would have to figure out an alternative. This will be done in a separate blog post. meanwhile, the straightforward code that words in distill is: 


```r
# gps_path_selected <- gps_path %>% 
#   filter(id==1)
# 
# tmap_mode("view")
# 
# tm_shape(bgmap) + 
#   tm_rgb(bgmap, r=1, g=2, b=3,   # raster layer
#          alpha = NA, 
#          saturation = 1, 
#          interpolate = TRUE, 
#          max.value = 255) + 
#   tm_shape(gps_path_selected) +  # gps path 
#   tm_lines()
```
