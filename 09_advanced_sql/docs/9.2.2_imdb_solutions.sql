USE imdb_ijs;

/******
The Big Picture
******/

-- How many actors are there in the actors table?
SELECT 
    COUNT(DISTINCT id)
FROM
    actors;
-- '817718'

-- How many directors are there in the directors table?
SELECT 
    COUNT(DISTINCT id)
FROM
    directors;
-- '86880'

-- How many movies are there in the movies table?
SELECT 
    COUNT(DISTINCT id)
FROM
    movies;
-- '388269'

/******
Exploring the Movies
******/

-- From what year are the oldest and the newest movies? What are the names of those movies?
SELECT 
    name, year
FROM
    movies
WHERE
    year = (SELECT MAX(year) FROM movies)
	OR year = (SELECT MIN(year) FROM movies);
/* # name, year
'Harry Potter and the Half-Blood Prince', '2008'
'Roundhay Garden Scene', '1888'
'Traffic Crossing Leeds Bridge', '1888'
*/

-- What movies have the highest and the lowest ranks?
SELECT 
    name, `rank`
FROM
    movies
WHERE
    `rank` = (SELECT MAX(`rank`) FROM movies)
	OR `rank` = (SELECT MIN(`rank`) FROM movies);
/*
A lot of movies with either 1 or 9.9 as rank
*/

-- What is the most common movie title?
SELECT 
    name, COUNT(name)
FROM
    movies
GROUP BY name
ORDER BY COUNT(name) DESC;
/* # name, COUNT(name)
'Eurovision Song Contest, The', '49' */

/******
Understanding the Database
******/

-- Are there movies with multiple directors?
SELECT 
    movie_id, COUNT(director_id)
FROM
    movies_directors
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY COUNT(director_id) DESC;
/*
List of movies with multiple directors
*/

-- What is the movie with the most directors? Why do you think it has so many?
SELECT 
    m.name, COUNT(md.director_id)
FROM
    movies_directors md
        JOIN
    movies m ON md.movie_id = m.id
GROUP BY movie_id
ORDER BY COUNT(md.director_id) DESC;
/* # name, COUNT(md.director_id)
"Bill, The", 87 */


-- On average, how many actors are listed by movie?
SELECT 
    AVG(n_actors)
FROM
    (SELECT 
        movie_id, COUNT(DISTINCT (actor_id)) AS n_actors
    FROM
        roles
    GROUP BY movie_id) AS movies_n_actors;
-- 11.4287

-- Are there movies with more than one "genre"?
SELECT 
    movie_id, COUNT(genre)
FROM
    movies_genres
GROUP BY movie_id
HAVING COUNT(genre) > 1
ORDER BY COUNT(genre) DESC;
-- Yes

/******
Looking for specific movies
******/

-- Can you find the movie called “Pulp Fiction”?
SELECT 
    name
FROM
    movies
WHERE
    name = 'Pulp Fiction';

	-- Who directed it?
SELECT 
    d.first_name, d.last_name
FROM
    directors d
        JOIN
    movies_directors md ON d.id = md.director_id
        JOIN
    movies m ON md.movie_id = m.id
WHERE
    m.name LIKE 'pulp fiction';
/* # first_name, last_name
Quentin, Tarantino */

	-- Which actors where casted on it?
SELECT 
    a.first_name, a.last_name
FROM
    actors a
        JOIN
    roles r ON a.id = r.actor_id
        JOIN
    movies m ON r.movie_id = m.id
WHERE
    m.name LIKE 'pulp fiction';
/*
Long list of actors
*/

-- Can you find the movie called “La Dolce Vita”?
SELECT 
    name
FROM
    movies
WHERE
    name LIKE '%dolce vita%';

	-- Who directed it?
SELECT 
    d.first_name, d.last_name
FROM
    directors d
        JOIN
    movies_directors md ON d.id = md.director_id
        JOIN
    movies m ON md.movie_id = m.id
WHERE
    m.name LIKE 'Dolce Vita, la';
/* # first_name, last_name
Federico, Fellini */

	-- Which actors where casted on it?
SELECT 
    a.first_name, a.last_name
FROM
    actors a
        JOIN
    roles r ON a.id = r.actor_id
        JOIN
    movies m ON r.movie_id = m.id
WHERE
    m.name LIKE 'Dolce Vita, la';
/*
Long list of actors
*/

-- When was the movie “Titanic” by James Cameron released?
SELECT 
    m.year
FROM
    movies m
        JOIN
    movies_directors md ON m.id = md.movie_id
        JOIN
    directors d ON md.director_id = d.id
WHERE
    m.name LIKE 'titanic'
        AND d.last_name LIKE 'Cameron';
-- 1997

/******
Actors and directors
******/

-- Who is the actor that acted more times as “Himself”?
SELECT 
    a.first_name, a.last_name, COUNT(a.id)
FROM
    actors a
        JOIN
    roles r ON a.id = r.actor_id
WHERE
    `role` LIKE '%himself%'
GROUP BY a.id , a.first_name , a.last_name
ORDER BY COUNT(a.id) DESC;
/* # first_name, last_name, COUNT(a.id)
Adolf, Hitler, 206 */

-- What is the most common name for actors?

	-- most common first name
SELECT 
    first_name, COUNT(*)
FROM
    actors
GROUP BY 1
ORDER BY COUNT(first_name) DESC;
/* # first_name, COUNT(first_name)
John, 4371 */

	-- most common last name
SELECT 
    last_name, COUNT(*)
FROM
    actors
GROUP BY 1
ORDER BY COUNT(last_name) DESC;
/* # last_name, COUNT(last_name)
Smith, 2425 */

	-- most common full name
SELECT 
    CONCAT(first_name, ' ', last_name) AS fullname, COUNT(*)
FROM
    actors
GROUP BY fullname
ORDER BY COUNT(*) DESC;
/* # fullname, COUNT(fullname)
Shauna MacDonald, 7 */

-- And for directors?

	-- most common first name
SELECT 
    first_name, COUNT(*)
FROM
    directors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
Michael, 670 */

	-- most common last name
SELECT last_name, COUNT(*)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 243 */

	-- most common full name
SELECT 
    CONCAT(first_name, ' ', last_name) AS fullname, COUNT(*)
FROM
    directors
GROUP BY fullname
ORDER BY COUNT(*) DESC;
/* # fullname, COUNT(fullname)
Kaoru UmeZawa, 10 */

/******
Analysing genders
******/

-- How many actors are male and how many are female?
SELECT 
    gender, COUNT(*)
FROM
    actors
GROUP BY gender;
/* # gender, COUNT(gender)
F, 304412
M, 513306 */
	
-- What percentage of actors are female, and what percentage are male?
SELECT 
    gender,
    COUNT(gender) / (SELECT COUNT(id) FROM actors) * 100 AS percent
FROM
    actors
GROUP BY gender;
-- 37.2% female, 62.8% male


/******
Movies across time
******/

-- How many of the movies were released after the year 2000?
SELECT 
    COUNT(id)
FROM
    movies
WHERE
    year > 2000;
-- '46006'

-- How many of the movies where released between the years 1990 and 2000?
SELECT 
    COUNT(id)
FROM
    movies
WHERE
    year BETWEEN 1990 AND 2000;
-- '91138'
-- BETWEEN 1990 AND 2000 is the same as >= 1990 AND <= 2000, be wary of this!!!

-- Which are the 3 years with the most movies? How many movies were produced on those years?
SELECT 
    year, COUNT(DISTINCT id) AS no_of_releases
FROM
    movies
GROUP BY year
ORDER BY no_of_releases DESC
LIMIT 3;
/* # ranking, year, total
1, 2002, 12056
2, 2003, 11890
3, 2001, 11690 */

-- What are the top 5 movie genres?
SELECT 
    genre, COUNT(*) AS num_movies
FROM
    movies_genres
GROUP BY genre
ORDER BY num_movies DESC
LIMIT 5;
/* # ranking, genre, total
1, Short, 81013
2, Drama, 72877
3, Comedy, 56425
4, Documentary, 41356
5, Animation, 17652 */

-- What are the top 5 movie genres before 1920?
SELECT 
    genre, COUNT(DISTINCT movie_id)
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
WHERE
    m.year < 1920
GROUP BY genre
ORDER BY COUNT(DISTINCT movie_id) DESC
LIMIT 5;
/* # ranking, genre, total
1, Short, 18559
2, Comedy, 8676
3, Drama, 7692
4, Documentary, 3780
5, Western, 1704 */

-- What is the evolution of the top movie genres across all the decades of the 20th century?
/*
Here we will utilise temporary tables
This can also be solved with window function - we'll learn about these later in the week
*/

/* the number of movies per genre per decade */
CREATE TEMPORARY TABLE genre_per_decade AS
SELECT 
    genre,
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(genre) AS movies_per_genre
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
GROUP BY decade , genre;

/* the maximum number of movies per genre per decade */
CREATE TEMPORARY TABLE max_movies AS
SELECT 
    decade,
    MAX(movies_per_genre) AS max_movies_per_genre
FROM
    genre_per_decade
GROUP BY decade;

/* select the genres that have the maximum number of movies in their respective decades */
SELECT 
    gd.genre, gd.decade, gd.movies_per_genre
FROM
    genre_per_decade gd
        JOIN
    max_movies mm ON gd.decade = mm.decade
        AND gd.movies_per_genre = mm.max_movies_per_genre
ORDER BY gd.decade;
/*
# genre, decade, movies_per_genre
Short, 1880, 2
Documentary, 1890, 1062
Short, 1900, 3929
Short, 1910, 13764
Short, 1920, 5583
Short, 1930, 5218
Short, 1940, 4458
Drama, 1950, 5427
Drama, 1960, 7234
Drama, 1970, 8304
Drama, 1980, 9625
Drama, 1990, 12232
Short, 2000, 13451
+/


/******
Putting it all together: names, genders, and time
******/

-- Has the most common name for actors changed over time?

CREATE TEMPORARY TABLE names_per_decade AS
SELECT 
    a.first_name AS fname, 
    COUNT(a.first_name) AS totals, 
    FLOOR(m.year / 10) * 10 AS decade
FROM actors a
JOIN roles r ON a.id = r.actor_id
JOIN movies m ON r.movie_id = m.id
GROUP BY decade, fname;

CREATE TEMPORARY TABLE max_name_per_decade AS
SELECT 
    decade,
    MAX(totals) AS max_totals
FROM names_per_decade
GROUP BY decade;

SELECT 
    nd.fname,
    nd.decade,
    nd.totals
FROM
    names_per_decade nd
        JOIN
    max_name_per_decade md ON nd.decade = md.decade
        AND nd.totals = md.max_totals
ORDER BY nd.decade;
/* # decade, name, totals
1890, Petr, 26
1900, Florence, 180
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5929
2000, Michael, 3914 */

-- Get the most common actor name for each decade in the XX century.
SELECT 
    nd.fname,
    nd.decade,
    nd.totals
FROM
    names_per_decade nd
        JOIN
    max_name_per_decade md ON nd.decade = md.decade
        AND nd.totals = md.max_totals
WHERE nd.decade BETWEEN 1900 AND 1990
ORDER BY nd.decade;


-- Re-do the analysis on most common names, splitted for males and females

CREATE TEMPORARY TABLE male_names_per_decade AS
SELECT 
    a.first_name AS fname, 
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(*) AS totals
FROM actors a
JOIN roles r ON a.id = r.actor_id
JOIN movies m ON r.movie_id = m.id
WHERE a.gender = 'm'
GROUP BY decade, fname;

CREATE TEMPORARY TABLE female_names_per_decade AS
SELECT 
    a.first_name AS fname, 
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(*) AS totals
FROM actors a
JOIN roles r ON a.id = r.actor_id
JOIN movies m ON r.movie_id = m.id
WHERE a.gender = 'f'
GROUP BY decade, fname;

CREATE TEMPORARY TABLE max_male_totals_per_decade AS
SELECT 
    decade,
    MAX(totals) AS max_totals
FROM male_names_per_decade
GROUP BY decade;

CREATE TEMPORARY TABLE max_female_totals_per_decade AS
SELECT 
    decade,
    MAX(totals) AS max_totals
FROM female_names_per_decade
GROUP BY decade;

SELECT 
    male.fname AS male_name,
    female.fname AS female_name,
    male.decade
FROM
    max_male_totals_per_decade max_male
        LEFT JOIN
    male_names_per_decade male ON male.decade = max_male.decade
        AND male.totals = max_male.max_totals
        LEFT JOIN
    max_female_totals_per_decade max_female ON male.decade = max_female.decade
        LEFT JOIN
    female_names_per_decade female ON female.decade = max_female.decade
        AND female.totals = max_female.max_totals
ORDER BY male.decade;
/*
# male_name, female_name, decade
Petr, Rosemarie, 1890
Mack, Florence, 1900
Harry, Florence, 1910
Charles, Mary, 1920
Harry, Dorothy, 1930
George, Maria, 1940
John, María, 1950
John, Maria, 1960
John, María, 1970
John, Maria, 1980
Michael, Maria, 1990
Michael, María, 2000
*/


-- How many movies had a majority of females among their cast? 

CREATE TEMPORARY TABLE movie_gender_counts AS
SELECT 
    r.movie_id,
    COUNT(CASE WHEN a.gender = 'M' THEN 1 END) as male_count,
    COUNT(CASE WHEN a.gender = 'F' THEN 1 END) as female_count
FROM roles r
JOIN actors a ON r.actor_id = a.id
GROUP BY r.movie_id;

SELECT COUNT(movie_id)
FROM movie_gender_counts
WHERE female_count > male_count;
-- 50666

-- What percentage of the total movies had a majority female cast?
SELECT
(SELECT COUNT(movie_id)
FROM movie_gender_counts
WHERE female_count > male_count)
/
(SELECT COUNT(DISTINCT movie_id)
FROM roles) * 100 AS female_majority_movies_percentage;
-- 16.8745%
/*
Note: movies and roles have a different count of movies
Here we've used the number of movies in roles as the denominator
We did this as we got the number of majority female movies from the table roles
You may get a different number herE if you used the number of movies in the movies table as the denominator
*/
SELECT count(DISTINCT id) FROM movies;
SELECT count(DISTINCT movie_id) FROM roles;