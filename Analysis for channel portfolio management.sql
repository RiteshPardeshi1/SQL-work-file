-- Expanded Channel Portfolio
SELECT MIN(DATE(created_at) )AS week_start_date,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
AND utm_campaign = 'nonbrand'
GROUP BY yearweek(created_at);

SELECT utm_source,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) *100 AS pct_mobile
FROM website_sessions
WHERE created_at > '2012-08-22' AND
created_at < '2012-11-30'
AND utm_campaign = 'nonbrand'
GROUP BY 1;


SELECT ws.utm_source,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders,
COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END)/COUNT(DISTINCT od.order_id) AS pct_mobile_orders
FROM website_sessions AS ws
LEFT JOIN orders as od ON ws.website_session_id = od.website_session_id
WHERE ws.created_at > '2012-08-22' AND
ws.created_at < '2012-11-30'
AND ws.utm_campaign = 'nonbrand'
GROUP BY 1;


-- Multi- channel Bidding 

SELECT ws.device_type,
ws.utm_source,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders,
COUNT(DISTINCT od.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.utm_campaign = 'nonbrand'
AND ws.created_at > '2012-08-22'
AND ws.created_at < '2012-09-18'
GROUP BY 1,2;

-- Analysing channel portfolio trends

SELECT MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_dtop_session,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_dtop_session,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mob_session,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mob_session,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE created_at > '2012-11-04'
AND created_at < '2012-12-22'
AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at),
WEEK(created_at);

-- Analysing Direct Traffic
SELECT 
max(DATE(created_at)),
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS brand,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND  http_referer IN ('https://www.gsearch.com','https://www.bsearch.com')THEN website_session_id ELSE NULL END) AS organic,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND  http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY YEAR(created_at),
MONTH(created_at);

SELECT DISTINCT http_referer FROM website_sessions




















