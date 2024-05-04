-- For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count.
SELECT COUNT(*) 
FROM facilities

-- Produce a count of the number of facilities that have a cost to guests of 10 or more.
SELECT COUNT(*)
FROM facilities
WHERE guestcost > 10;

-- Produce a count of the number of recommendations each member has made. Order by member ID.
SELECT recommendedby, COUNT(*) as count 
FROM members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby

-- Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
SELECT facid, SUM(slots)
FROM bookings
GROUP BY facid

-- Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
SELECT facid, SUM(slots)
FROM bookings
WHERE DATE(starttime) >= '2024-01-01' AND DATE(starttime) <= '2024-01-31'
GROUP BY facid

-- Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
WITH dates AS
(
    --EXTRACT(day or month or year...
    SELECT *,EXTRACT(month from starttime) AS month
    FROM bookings
)

SELECT facid, month, SUM(slots)
FROM dates 
GROUP BY facid,month

-- Find the total number of members (including guests) who have made at least one booking.
SELECT COUNT(DISTINCT memid)
FROM bookings

-- Produce a list of facilities with more than 8 slots booked. Produce an output table consisting of facility id and slots, sorted by facility id.
WITH table1 AS
(   SELECT facid, SUM(slots) as totalSlots
    FROM bookings
    GROUP BY facid
)

SELECT facid, totalSlots
FROM table1
WHERE totalSlots > 8

-- Produce a list of facilities along with their total revenue. The output table should consist of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
WITH table1 AS
(
    SELECT f.name,
    CASE
        WHEN m.memid = 0 THEN b.slots * f.guestcost
        ELSE b.slots * f.membercost
    END AS revenue
    FROM members m 
    JOIN bookings b 
    ON m.memid = b.memid
    JOIN facilities f 
    ON b.facid = f.facid
)

SELECT name, SUM(revenue) as totalRevenue
FROM table1
GROUP BY name 
ORDER BY totalRevenue

-- Produce a list of facilities with a total revenue less than 1000. Produce an output table consisting of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
WITH table1 AS
(
    SELECT f.name,
    CASE
        WHEN m.memid = 0 THEN b.slots * f.guestcost
        ELSE b.slots * f.membercost
    END AS revenue
    FROM members m 
    JOIN bookings b 
    ON m.memid = b.memid
    JOIN facilities f 
    ON b.facid = f.facid
)

,table2 AS
(
    SELECT name, SUM(revenue) as totalRevenue
    FROM table1
    GROUP BY name 
    ORDER BY totalRevenue
)

SELECT *
FROM table2
WHERE totalRevenue>=50

--Output the facility id that has the highest number of slots booked. For bonus points, try a version without a LIMIT clause. This version will probably look messy!
WITH table1 AS
(
    SELECT facid, SUM(slots) as totalSlots
    FROM bookings
    GROUP BY facid
)
SELECT facid, totalSlots
FROM table1
WHERE totalSlots = (
    SELECT MAX(totalSlots)
    FROM table1
)

-- Produce a list of the total number of slots booked per facility per month in the year of 2012. In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities. The output table should consist of facility id, month and slots, sorted by the id and month. When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
SELECT f.facid, EXTRACT(month from b.starttime), SUM(b.slots) AS SLOTS
FROM facilities f JOIN bookings b ON f.facid = b.facid 
GROUP BY f.facid, EXTRACT(month from b.starttime)

--Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour. The output table should consist of the facility id, name, and hours booked, sorted by facility id. Try formatting the hours to two decimal places.
SELECT f.facid, f.name, ROUND(SUM(b.slots)*0.5, 2) AS "Total Hours" 
FROM facilities f JOIN bookings b ON f.facid = b.facid 
GROUP BY f.facid

--Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
WITH table1 AS
(
    SELECT * FROM bookings
    WHERE DATE(starttime) > '2024-01-31'
)

SELECT m.memid, m.firstname, m.surname, MIN(starttime) AS "First Booking"
FROM members m JOIN table1 b ON b.memid = m.memid 
GROUP BY m.memid 
ORDER BY m.memid

--Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
SELECT COUNT(*) OVER() AS count, firstname, surname
FROM members
ORDER BY joindate

-- Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
SELECT ROW_NUMBER() OVER(ORDER BY joindate) AS row_number, firstname, surname
FROM members

-- Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
SELECT facid,total
FROM (
    SELECT facid, sum(slots) as TOTAL, RANK() OVER(order by sum(slots) DESC) as RANK
    FROM bookings
    group by facid
)
WHERE RANK = 1; --2 has 4 tuples

-- Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank. Sort by rank, surname, and first name.
SELECT f.facid, f.name, ROUND(SUM(b.slots)*0.5) AS total, RANK() OVER(ORDER BY SUM(b.slots)*0.5 desc) 
FROM facilities f JOIN bookings b ON f.facid = b.facid 
GROUP BY f.facid

-- Produce a list of the top three revenue generating facilities (including ties). Output facility name and rank, sorted by rank and facility name.
WITH table1 AS
(
    SELECT f.name,
    CASE
        WHEN m.memid = 0 THEN b.slots * f.guestcost
        ELSE b.slots * f.membercost
    END AS revenue
    FROM members m 
    JOIN bookings b 
    ON m.memid = b.memid
    JOIN facilities f 
    ON b.facid = f.facid
)

,table2 AS
(
    SELECT name, SUM(revenue) as totalRevenue
    FROM table1
    GROUP BY name 
    ORDER BY totalRevenue
)
,table3 AS
(
    SELECT name, RANK() OVER(ORDER BY totalrevenue DESC)
    FROM table2
)
SELECT * FROM table3
WHERE RANK<=3

--Classify facilities into equally sized groups of high, average, and low based on their revenue. Order by classification and facility name.
WITH table1 AS
(
    SELECT f.name,
    CASE
        WHEN m.memid = 0 THEN b.slots * f.guestcost
        ELSE b.slots * f.membercost
    END AS revenue
    FROM members m 
    JOIN bookings b 
    ON m.memid = b.memid
    JOIN facilities f 
    ON b.facid = f.facid
)

,table2 AS
(
    SELECT name, SUM(revenue) as totalRevenue
    FROM table1
    GROUP BY name 
    ORDER BY totalRevenue
)
,table3 AS
(
    SELECT name,totalRevenue, ntile(3) OVER(ORDER BY totalRevenue DESC)
    FROM table2
)
SELECT name, 
CASE
WHEN ntile = 1 THEN 'high'
WHEN ntile = 2 THEN 'average'
ELSE 'low'
END AS revenue
FROM table3

-- Based on the 3 complete months of data so far, calculate the amount of time each facility will take to repay its cost of ownership. Remember to take into account ongoing monthly maintenance. Output facility name and payback time in months, order by facility name. Don't worry about differences in month lengths, we're only looking for a rough value here!

