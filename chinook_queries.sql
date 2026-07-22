SELECT SUM(total) as total_revenue
FROM invoice
--Total revenue is 2328.60

SELECT COUNT(DISTINCT customer_id) as no_of_customers, COUNT(DISTINCT billing_country) as no_of_countries
FROM invoice
--There are a 59 customers from 24 countries

SELECT billing_country, ROUND(AVG(total),2) as total_revenue
FROM invoice as i 
GROUP BY billing_country
ORDER BY total_revenue DESC
--Chile has the highest average revenue at 6.66 with 8 countries tied at the lower end at 5.37

SELECT c.first_name, c.last_name, SUM(total) as total_revenue
FROM customer as c
JOIN invoice as i 
	ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_revenue DESC
--Helena Holy contributed the highest amount to revenue with 49.62 and Puja Srivastava contributed the least with 36.64

WITH customer_purchases AS (
	SELECT customer_id, COUNT(invoice_id) as no_of_purchases
	FROM invoice
	GROUP BY customer_id
	)
SELECT
	(COUNT(CASE WHEN no_of_purchases >= 2 THEN 1 END) * 1.0 / COUNT(*)) * 100 as repeat_purchase_rate
FROM customer_purchases
--The repeat purchase rate is 100% meaning customers make 2 or more orders

SELECT m.name, COUNT(DISTINCT a.album_id) as no_of_albums
FROM track as t
INNER JOIN album as a 
	ON t.album_id = a.album_id
INNER JOIN media_type as m
 	ON t.media_type_id = m.media_type_id
GROUP BY m.name
ORDER BY no_of_albums DESC
--MPEG audio file media type has the highest number of albums at 234 while purchased AAC audio file at 7

SELECT e.first_name, e.last_name,e.title, COUNT(c.customer_id) as no_of_customers
FROM employee as e
LEFT JOIN customer as c
	ON e.employee_id = c.support_rep_id
GROUP BY e.first_name, e.last_name, e.title
ORDER BY no_of_customers DESC
--3 employees act as sales support agent

SELECT p.name, COUNT(pt.track_id) AS number_of_tracks
FROM playlist AS p
LEFT JOIN playlist_track AS pt
	ON p.playlist_id = pt.playlist_id
GROUP BY p.name
ORDER BY number_of_tracks DESC
--Music leads as the playlist with most number of tracks at 6580, three playlist have 0 tracks

WITH genre_counts AS (
	SELECT i.billing_country, g.name, COUNT(il.track_id) as no_of_tracks
	FROM invoice_line AS il
	JOIN invoice AS i
		ON i.invoice_id = il.invoice_id
	JOIN track AS t
		ON il.track_id = t.track_id
	JOIN genre AS g
		ON t.genre_id = g.genre_id
	GROUP BY i.billing_country, g.name),
genre_ranking AS 
	(SELECT billing_country, name , RANK() OVER(PARTITION BY billing_country ORDER BY no_of_tracks DESC) as ranking
	 FROM genre_counts)
SELECT *
FROM genre_ranking
WHERE ranking = 1
--Rock leads as the most listened genre in 23 countries out of the 24 countries with latin leading in only one country, argentina has two leading genres rock and alternative & punk

SELECT invoice_date, 
	 ROUND(AVG(total) OVER (
	 	ORDER BY invoice_date
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as seven_day_moving_average
FROM invoice
ORDER BY invoice_date
--For long stretches the average hovers around 5.37 suggesting a consistent level of activity during those periods
--There are several points where the average climbs to 7-8.These indicate sustained increase over a week not just one day anomalies.
--That signals seasonal demands, promotions or events driving higher activity
--After the surges the trend drops back to 5.37 signalling the change as temporary rather than permanent

