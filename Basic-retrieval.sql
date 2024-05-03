--How can you retrieve all the information from the cd.facilities table?
select * from facilities;

--How would you retrieve a list of only facility names and costs?
select name, membercost from facilities;

--How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/20th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
SELECT *
FROM facilities
WHERE membercost < monthlymaintenance/20;

--How can you produce a list of all facilities with the word 'Tennis' in their name?
SELECT * 
FROM facilities
WHERE name LIKE '%Tennis%'

--How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
SELECT * 
FROM facilities
WHERE facid IN (1,5)

--How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100?
SELECT name,monthlymaintenance,
CASE
WHEN monthlymaintenance>100 THEN 'Expensive'
ELSE 'Cheap'
END as CostLevel
FROM facilities

--How can you produce a list of members who joined after the start of September 2012?
SELECT memid, surname, firstname, joindate
FROM members
WHERE joindate > '15-01-2024';

-- How can you produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.
SELECT DISTINCT surname
FROM members
ORDER BY surname
LIMIT 10

-- You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!
SELECT surname
FROM members 

UNION

SELECT name 
FROM facilities

--You'd like to get the signup date of your last member. How can you retrieve this information?
SELECT MAX(joindate)
FROM members

--You'd like to get the first and last name of the last member(s) who signed up - not just the date. How can you do that?
SELECT firstname,surname,joindate 
FROM members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM members
)

