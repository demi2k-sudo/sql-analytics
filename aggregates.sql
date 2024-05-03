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