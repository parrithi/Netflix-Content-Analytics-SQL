-- Netflix Analysis Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
		show_id	VARCHAR(6),
		type VARCHAR(10),
		title VARCHAR(150),
		director VARCHAR(208),	
		casts VARCHAR(1000),	
		country VARCHAR(150),
		date_added VARCHAR(50),
		release_year INT,
		rating VARCHAR(10),
		duration VARCHAR(15),
		listed_in VARCHAR(100),	
		description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) FROM netflix;

SELECT DISTINCT type FROM netflix;


/*
-- 15 Business Problems 

1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie or TV show duration
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10. Find the average release year for content produced in a specific country
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in india
15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field. Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.

*/

--Solutions

--1. Count the number of Movies vs TV Shows

SELECT type,
	COUNT(*) as Total_Content
FROM netflix
GROUP BY type;


--2. Find the most common rating for movies and TV shows


SELECT 
	type,
	rating
FROM 
(
SELECT type,
	rating,
	COUNT(*) as Total_Content,
	RANK() OVER(PARTITION  BY type ORDER BY COUNT(*)DESC) as ranking
	
FROM netflix
GROUP BY 1,2 
) as t1
 WHERE ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE 
	release_year = 2020
	AND
	type = 'Movie';

--4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as Total_Content
	FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country
	FROM netflix;
	

--5. Identify the longest movie or TV show duration

SELECT * FROM netflix
WHERE 
	type = 'movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix );


--6. Find content added in the last 5 years

SELECT *,
		TO_DATE(date_added, 'Month DD, YYYY')
		FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director LIKE '%Rajiv chilaka%'; 


--8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5; 


--9. Count the number of content items in each genre


SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as Genre,
	COUNT(show_id) AS Total_Content
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC; 


--10. Find the average release year for content produced in a specific country


SELECT 
	ROUND(AVG(release_year),0),
	UNNEST(STRING_TO_ARRAY(country, ',')) as S_Country
	FROM netflix
	GROUP BY 2


--10. Find each year and the average numbers of content release by India on netflix. 
--return top 5 year with highest avg content release !


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


--11. List all movies that are documentaries

SELECT * FROM netflix
WHERE 
	listed_in LIKE '%Documentaries%'
	AND
	type = 'Movie';


--12. Find all content without a director

SELECT * FROM netflix
WHERE director IS null;


--13. Find how many movies actor 'Salman Khan' appeared in last 12 years!

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year >EXTRACT(YEAR FROM CURRENT_DATE) - 12


--14. Find the top 10 actors who have appeared in the highest number of movies produced in india


SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) as Actors,
	COUNT(*) as Total_Content 
	FROM netflix
	WHERE country ILIKE '%India%' 
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10;

/*

15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field. Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.

*/

WITH new_table
AS(
SELECT 
*,
	CASE 
	WHEN description ILIKE '%kill%' 
		OR
		description ILIKE '%violance%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END Category
FROM netflix	
	)
SELECT 
	Category,
	COUNT(*) AS Total_Content
	FROM new_table
	GROUP BY 1