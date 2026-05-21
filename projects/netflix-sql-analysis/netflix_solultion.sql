--Netflix Project--

DROP TABLE IF EXISTS Netflix;

CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),	
	castS VARCHAR(1000),	
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);

select * from netflix;

--counts content/rows in the table	
select
	count(*) as total_content
from netflix;

--shows all content in the table
select
	*
from netflix;

--Show all different types of content available in the Netflix table without repeating them.
select
	distinct type
from netflix;

select
	distinct rating
from netflix;

select * from netflix;

--15 business problems

--1.count the number of movies vs tv shows
select 
	type,    -- Displays the type of content (Movie or TV Show)
	count (*) as total_of_each_type   -- Counts the number of records in each type group
from netflix    -- Retrieves data from the netflix table
group by type;    -- Groups rows based on content type

--2.find the most common rating for movies and tv shows

select
	type,      -- Displays the content type (Movie or TV Show)
	rating      -- Displays the most common rating for each type
from
(
	select      -- Selects the content type
		type,     -- Selects the content type
		rating,    -- Selects the rating category
		count(*),     -- Counts how many times each rating appears
		rank() over(
			partition by type 
			order by count(*) desc
		) as ranking        -- Ranks ratings within each type based on highest count
	from netflix       -- Retrieves data from the netflix table
	group by 1,2         -- Groups data by type and rating
                                  -- (1 = type, 2 = rating)
) as t1           -- Creates a temporary table named t1
where
ranking=1    -- Shows only the top-ranked (most frequent) rating for each type

--3.list all movies released in a specific year(e.g.,2020)

--filter 2020
--movies

select * from netflix
where      -- Filters rows based on given conditions
	type='Movie'      -- Selects only content with type Movie
	and            -- Combines multiple conditions
	release_year=2020      -- Selects movies released in the year 2020


--4.find the top 5 countries with the most content on netflix

select
	distinct country
from netflix;

select
	unnest(string_to_array(country,',')) as new_country,   -- Splits multiple countries into separate rows
                                                           -- and renames the column as new_country
	count(show_id) as total_content                          -- Counts the number of shows for each country
from netflix                  -- Retrieves data from the netflix table
group by 1                    -- Groups data by the first selected column (new_country)
order by 2 desc               -- Sorts results by total_content in descending order
limit 5                      -- Displays only the top 5 countries


--5.identify the longest movie:

select * from netflix
where               -- Filters rows based on conditions
	type='Movie'            -- Selects only movies
	and                 -- Combines multiple conditions
	duration=(
		select max(duration)     -- Finds the maximum duration value
		from netflix                         -- Searches within the netflix table
	)           -- Subquery returns the longest duration

--6.find content added in the last five years

select 
	*
from netflix
where
	to_date(date_added,'month dd,yyyy')      -- Converts the date_added text into a proper date format
	>= current_date - interval '5 years'          -- Selects records added within the last 5 years

select current_date - interval '5 years'

--7.find all the movies/tv shows by director 'rajiv chilaka'

select * from netflix
where director ilike '%Rajiv Chilaka%'    -- Searches for director names containing
                                    -- 'Rajiv Chilaka' (case-insensitive search)


--8.list all tv shows with more than 5 seasons

select * from  netflix
where
	type='TV Show'
	duration

select 
	*
from  netflix
where
	type='TV Show'
	and
	split_part(duration,' ',1)::numeric>5       -- Extracts the number from duration
                                     -- converts it to numeric
                                     -- and selects shows with more than 5 seasons

--9.count the number of content items in each genre

select 
	unnest(string_to_array(listed_in,',')) as genre,     -- Splits multiple genres into separate rows
                                      -- and renames the column as genre
	count(show_id) as total_content       -- Counts the number of shows in each genre
from netflix
group by 1                  -- Groups rows by the first selected column (genre)


--10. find each year and the average numbers of content release by india on netflix .\
--return top 5 year with highest avg content release:

total content 333/972

select 
	extract(year from to_date(date_added,'month dd,yyyy')) as year,      -- Extracts the year from the date_added column
	count(*) as yearly_content,     -- Counts total content added in each year

	round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric*100  -- Counts total Indian content
	,2) as avg_content_per_year            -- Calculates percentage of content added each year
                                      -- rounded to 2 decimal places       
from netflix
where country='India'
group by 1                       -- Groups rows by year

--11.list all the movies that are documentaries

select * from netflix
where
	listed_in ilike '%documentaries%'

--12.find all the content without a director
select *from netflix 
where
	director is null

--13.find how many movies actor'salman khan' appeared in last 10 years

select * from netflix
where
	casts ilike '%salman khan%'
	and
	release_year > extract(year from current_date)-15

--14.find the top 10 actors who appeared in the highest number of movies produced in india
select
--show_id,
--casts,
unnest(string_to_array(casts,',')) as actors,
count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by 2 desc limit 10


--15.categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--label content containing these keywords as 'bad' and all other content as 'good' .
--count how many items fall into each category

with new_table
as
(
select 
* ,
	case
		when description ilike '%kill%'
		or
		description ilike '%violence%' 
		then 'bad_content'
		else
		'good_content'
	end category
from netflix
)
select
	category,
	count(*) as total_content
from new_table
group by 1
