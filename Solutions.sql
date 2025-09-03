-- Netflix Project
CREATE TABLE netflix
(
  show_id VARCHAR(6),
  type    VARCHAR(10),
  title    VARCHAR(150),
  director VARCHAR(208),
  casts  VARCHAR(1000),
  country VARCHAR(150),
  date_added  VARCHAR(50),
  release_year INT,
  rating   VARCHAR(10),
  duration  VARCHAR(15),
  listed_in VARCHAR(100),
  description VARCHAR(250)
);

SElect * from netflix;

Select 
 Count(*) as total_count
from netflix;

select 
 Distinct type
from netflix;

--  15 Business Problem 

--1. Count the number of Movies vs TV shows

Select 
type, Count(*) as total_content  
from netflix
GRoup by type

-- 2. Find the most common rating for movies and TV shows
Select 
    type,
    rating
from
( 
  Select 
     type,
     rating,
     count(*),
     Rank() Over(Partition By type Order By Count(*) DESC) as ranking
  From netflix
  Group by 1,2
)as t1
Where
   ranking = 1;

--3 List all movies released in a specific year(2020)

Select * from netflix
Where 
   type = 'Movie'
   And
   release_year = 2020;

--4. Find the Top 5 Countries with the Most Content on Netflix
Select 
    Unnest(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
from netflix
Group by 1
Order by 2 DESC
Limit 5

--5. Identify the longest movie

Select * from netflix
Where
     type  ='Movie'
	 AND
	 duration = (Select MAX(duration) From netflix)

--6. Find content added in the last 5 years
Select 
    * 
from netflix
Where
    TO_DATE(date_added, 'Month DD, YYYY') >= Current_Date - Interval '5 years'

--7 Find all the movies/TV shows by director 'Rajiv Chhilaka'

Select * From netflix
Where director ILike '%Rajiv Chilaka%';

--List all TV shows with more than 5 seasons
Select
   *
From netflix
Where 
   type  = 'TV Show'
   AND
   Split_Part(duration, ' ', 1)::numeric > 5;

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

--11 List all the movies that are documentaries

Select * from netflix
Where listed_in ILIKe  '%documentaries%'

--12 Find all the content with no director

Select * from netflix
Where director is NUll

--13. find how many  movies actor 'Salman Khan' appeared in last 10 years!

Select * from netflix
Where casts ILIKE '%Salman Khan%'
AND 
release_year > extract(year from current_date) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
Select 
unnest(string_to_array(casts, ',')) as actors,
count(*) as total_conetent
from netflix
where country ilike '%india%'
group by 1
order by 2 DESC
Limit 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
With new_table
as(
SElect *,
       Case
	   When 
	       description ilike '%kill%'
		   or
		   description ilike '%violence%' then 'Bad content'
		   Else 'Good content'
		End category
from netflix
)
Select category,
      count(*) as total_content
from new_table
Group by 1