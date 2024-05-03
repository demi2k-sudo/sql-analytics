--How can you produce a list of the start times for bookings by members named 'David Farrell'?
SELECT firstname,starttime 
FROM bookings b JOIN members m ON b.memid = m.memid
WHERE m.firstname = 'John' and m.surname = 'Smith'

--How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
SELECT name,starttime as start
FROM bookings b JOIN facilities f ON b.facid = f.facid 
WHERE f.name LIKE '%Tennis%' AND b.starttime >= '2024-01-02' AND b.starttime < '2024-01-03'

--How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
SELECT b.firstname, b.surname
FROM members a JOIN members b ON a.recommendedby = b.memid
ORDER BY b.firstname, b.surname

--How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
SELECT a.firstname,a.surname,b.firstname, b.surname
FROM members a JOIN members b ON a.recommendedby = b.memid
ORDER BY b.firstname, b.surname

--How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.
SELECT DISTINCT m.firstname ||' '|| m.surname as member, f.name
FROM facilities f 
JOIN bookings b 
ON f.facid = b.facid
JOIN members m 
ON b.memid = m.memid 
WHERE f.name LIKE '%Tennis%'
ORDER BY member,f.name

--How can you produce a list of bookings on the day of 2024-01-02 which will cost the member (or guest) more than $15? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.
SELECT DISTINCT m.firstname ||' '|| m.surname as member, f.name,b.starttime,

b.slots *
CASE
WHEN m.memid=0 THEN f.guestcost
ELSE f.membercost
END as cost,
m.memid

FROM facilities f 
JOIN bookings b 
ON f.facid = b.facid
JOIN members m 
ON b.memid = m.memid 

WHERE b.slots *
CASE
WHEN m.memid=0 THEN f.guestcost
ELSE f.membercost
END >=10 AND DATE(b.starttime) = '2024-01-02' 
ORDER BY cost

--How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
SELECT DISTINCT joinee.memid, joinee.firstname||' '||joinee.surname AS MemberName, 
(SELECT rec.firstname||' '||rec.surname FROM members rec WHERE rec.memid = joinee.recommendedby)
AS Recommender

FROM members joinee

ORDER BY MemberName,Recommender

--How can you produce a list of bookings on the day of 2024-01-02 which will cost the member (or guest) more than $15? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.

WITH table1 AS
(
    SELECT * FROM bookings 
    WHERE DATE(starttime) = '2024-01-02'
)

SELECT DISTINCT B.firstname ||' '|| B.surname as member, C.name,A.starttime
FROM table1 A, members B, facilities C
WHERE A.memid = B.memid AND A.facid = C.facid 
AND A.slots *
CASE
WHEN B.memid = 0  THEN C.guestcost
ELSE membercost
END >=10