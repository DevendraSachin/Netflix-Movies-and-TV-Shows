select * from netflix;

select director from netflix group by director;

-- Checking if there are any duplicate rows.
select show_id, count(*) from netflix group by show_id having count(*) > 1;


-- Created a temporary table to update and delete duplicate rows.;
with duplicate_rows as (select * from netflix where title in (select title from netflix group by title having count(*) > 1) order by title)
select * from netflix where concat(title, type) in (select concat(title, type) from duplicate_rows group by type, title having count(type) > 1) order by title;


-- new table for listed_in, director, country, cast
-- Created seperate table for movie_diector.
CREATE TABLE movie_director (
  show_id varchar(10),
  director VARCHAR(50),
  co_director varchar(200)
);

INSERT INTO movie_director (show_id, director, co_director)
select show_id, trim(substring_index(director, ',', 1)) as director, 
		trim(substring(director, locate(',', director)+1)) as co_director 
FROM netflix;

update movie_director set co_director = null where director = co_director;


-- Created seperate table for country.
create table country (
	show_id varchar(8),
    country varchar(30));
    
insert into country (show_id, country) 
select show_id, trim(substring_index(country, ",", 1)) as country from netflix;


-- Created seperate table for genre.
create table genre (
	show_id varchar(8),
	genre varchar(50));

insert into genre (show_id, genre)
select show_id, trim(substring_index(listed_in, ",", 1)) from netflix;



-- Recreating new date format
alter table netflix add column months int;

update netflix set months = case trim(substring_index(date_added," ",1))
when "January" Then 1
when "February" Then 2
when "March" then	3
when "April" then 4
when "May" then 5
when "June" then 6
when "July" then 7
when "August" then 8
when "September" then 9
when "October" then 10
when "November" then 11
when "December" then 12
end;


-- Adding and updating Date Column
alter table netflix add column Date date;
update netflix set Netflix_Date = str_to_date(date_added, '%M %e, %Y');

-- Dropping Months and date_added columns
alter table netflix drop date_added, drop months;


-- Modify and updating few data in rating and duration which is not belongs to rating column ;
select show_id, rating, duration from netflix where rating like "%min";

update netflix set duration = rating where rating like "%min";
update netflix set rating = null where show_id IN ('s5542', 's5795', 's5814');

select count(*) from netflix where country is null;



update netflix as n
join 
(select d.director, n.country from movie_director d 
join netflix n on n.show_id = d.show_id  
where d.director is not null and country is not null 
group by d.director, n.country) as tb
on n.director = tb.director
set n.country = tb.country
where n.country is null;


