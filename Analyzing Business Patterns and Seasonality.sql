-- Analyzing Seasonality

-- monthly 
SELECT YEAR(ws.created_at) AS yr,
MONTH(ws.created_at) AS mo,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders
FROM website_sessions AS ws 
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2013-01-01'
GROUP BY 1,2
ORDER BY 1,2;

-- Weekly
SELECT 
MIN(DATE(ws.created_at)) AS week_start_date,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders
FROM website_sessions AS ws 
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2013-01-01'
GROUP BY YEAR(ws.created_at),
WEEK(ws.created_at)
ORDER BY 1;

-- Analyzing Business Partners

-- Sub query 
SELECT DATE(created_at) AS created_at,
WEEKDAY(created_at) AS wkday,
HOUR(created_at) AS hr,
COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at between '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3;
-- Now you have all the necessary details which is required. 

SELECT hr,
ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS mon,
ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) AS tue,
ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) AS wed,
ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS thu,
ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) AS fri,
ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) AS sat,
ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) AS sun
FROM(
SELECT DATE(created_at) AS created_at,
WEEKDAY(created_at) AS wkday,
HOUR(created_at) AS hr,
COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at between '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) AS daily_hourly_sessions
GROUP BY 1
ORDER BY 1














