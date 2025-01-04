CREATE DATABASE IF NOT EXISTS NF;
use nf;
CREATE TABLE `Netflix`(
`show_id` varchar(500) DEFAULT NULL,
`type` varchar(255) default NULL,
`title`varchar(255) default NULL,
`director` varchar(255) default NULL,
`country` varchar(255) default NULL,
`date_added` varchar(255) default NULL,
`release_year` varchar(255) default NULL,
`rating` varchar(255) default NULL,
`duration` varchar(255) DEFAULT NULL,
`listed_in` varchar(255) DEFAULT NULL);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NFi.csv' INTO TABLE Netflix
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

INSERT INTO  `Netflix` (show_id,type, title,director,country,date_added,release_year,rating,duration,listed_in) VALUES ('s3', 'TV Show', 'Ganglands', 'Julien Leclercq','France
','2021-09-24','2021','TV-MA','1 Season','Crime TV Shows, International TV Shows, TV Action & Adventure'); # insert table for check why data was truncated frp, data there were input column

# All data after uploaded data
SELECT * FROM netflix;

SELECT DISTINCT listed_in FROM netflix;

-- Cleaning Data 
# -- 1. Duplicate value use Window Function for see what row it have its.
# -- 2. Standardize data & Date format for adjust time series


SELECT *, ROW_NUMBER() OVER(PARTITION BY `show_id`,`type`,`title`,`director`,`country`,`date_added`,release_year,rating,duration,listed_in) AS row_num
FROM netflix;

WITH TempNetflix AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY `show_id`,`type`,`title`,`director`,`country`,`date_added`,release_year,rating,listed_in) AS row_num
FROM netflix) 
SELECT * FROM TempNetflix
WHERE row_num > 1; # No duplicated values

-- Check duplicated from Col#Show_id
SELECT show_id , count(*) AS Qty FROM netflix
GROUP BY show_id
ORDER BY Qty DESC;


WITH dup_count AS (SELECT show_id , count(*) AS Qty FROM netflix
GROUP BY show_id
ORDER BY Qty DESC) SELECT * FROM dup_count 
WHERE Qty>1; # That mean no duplicated data 

## Back up Raw data 
CREATE TABLE nfbkp
SELECT * FROM netflix;


SELECT * FROM nfbkp;

## Drop column i no longer use from bkp table
ALTER TABLE nfbkp 
DROP COLUMN show_id;


##  Data exploration
	# dividing types
SELECT type
FROM nfbkp
GROUP BY type;

# Quantity of any type of Netflix movies
SELECT type,count(*) AS Quantity_type
FROM nfbkp
GROUP BY type
ORDER BY Quantity_type;



## How many rating of movies and where it came from ?

SELECT rating ,count(*) AS Quantity_of_Rating 
from nfbkp
GROUP BY rating
ORDER BY Quantity_of_Rating  DESC;


SELECT rating,count(*) AS Qty ,country  
FROM nfbkp
group by rating,country
ORDER BY  Qty DESC;

# counting content projects produced by country
SELECT country,count(*) AS Quantity_of_Project_movie
FROM nfbkp
WHERE country != 'Not Given'
GROUP BY 1
ORDER BY Quantity_of_Project_movie DESC;

## What period of Movie or TVs Show is release?

SELECT type,release_year,count(*) AS made_this_Year
FROM nfbkp
WHERE director != 'NotGiven' and title != 'Not Given'
GROUP BY type, release_year
ORDER BY type ASC ,made_this_Year DESC;


SELECT * FROM nfbkp;


    SELECT  title FROM nfbkp
    WHERE title LIKE '%Not%';

## counts by director. Let's look at those, who did the most

SELECT director,country,count(*) AS Quantity_Per_project
FROM nfbkp
WHERE director != 'NotGiven'
GROUP BY director,country
ORDER BY Quantity_Per_project DESC
LIMIT 15;

## count by rating with director and quantity of project 
SELECT director,country,count(*) AS Quantity_Per_project
FROM nfbkp
WHERE director != 'NotGiven'
GROUP BY director,country
ORDER BY Quantity_Per_project DESC
LIMIT 50;

# What rating of Rai v Chalaka made ?

SELECT rating,director,type,count(*) AS Made_this_year
FROM nfbkp
WHERE director != 'NotGiven'
GROUP BY rating,director,type
ORDER BY Made_this_year DESC; # That mean Rai v Chalaka made Movies type and got  rating TV-Y7 programming is designed for chil- dren ages 7 and older for fantasies violence.

SELECT DISTINCT listed_in
FROM nfbkp
WHERE listed_in LIKE '%Docu%';

# Frequency of among Genre Content...
SELECT
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Comedies%') AS Count_Comedies,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Documentaries%' or listed_in LIKE '%Docuseries%') AS Count_Documentarieseries,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Horror%') AS count_horror,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Crime%') AS Count_Crime,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Adventure%') AS  Count_Adventure,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Action%') AS Count_Action,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%anime%') AS Count_Anime,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Music%') AS Count_Music,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Drama%') AS Count_Drama,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Romantic%') AS Count_Romantic,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Thrillers%') AS Count_Thrillers,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%Kid%') AS Count_KIDs,
(SELECT count(*) FROM nfbkp WHERE listed_in LIKE '%family%') AS Count_Familys;

SELECT * FROM nfbkp;

# Choose a Movie type which duration of movie is not over 250 minute
WITH CTE AS (SELECT type,
			 CAST(replace(duration,' min','') AS SIGNED) AS duration_min 
             FROM nfbkp
             WHERE type = 'Movie')
SELECT type,duration_min ,count(*) AS Qty_Duration_min
FROM cte
WHERE duration_min <= 250
GROUP BY type,duration_min
ORDER BY duration_min ASC;

# Choose a Series type which duration of How many seasons  of any TV Shows? 

WITH CTESS AS (SELECT type,
			   cast(replace(replace(duration,' seasons',''),' season','') AS SIGNED) AS Duration_seasons
               FROM nfbkp
               WHERE type = 'TV Show'
               )
               SELECT type,Duration_seasons,count(*) AS Qty_of_Seasons
               FROM CTESS
               WHERE Duration_seasons <= 250
               GROUP BY  type,Duration_seasons
               ORDER BY Qty_of_Seasons DESC;
               

               








	