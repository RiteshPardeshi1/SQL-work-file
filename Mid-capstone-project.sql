-- Mid Course Project-- 

-- Pull Monthly Trends for gsearch sessions and orders

SELECT MIN(DATE(ws.created_at))AS week_start_date, 
COUNT(DISTINCT ws.website_session_id) AS sessions, 
COUNT(distinct od.order_id) AS orders
FROM website_sessions AS ws
LEFT JOIN orders AS od
ON ws.website_session_id = od.website_session_id
WHERE ws.utm_source = 'gsearch'
AND ws.created_at < '2012-11-27'
GROUP BY 
YEAR(ws.created_at),
WEEK(ws.created_at);

-- Another way
SELECT YEAR(ws.created_at) AS yr,
Month(ws.created_at) AS wk, 
COUNT(DISTINCT ws.website_session_id) AS sessions, 
COUNT(distinct od.order_id) AS orders,
COUNT(distinct od.order_id)/ COUNT(DISTINCT ws.website_session_id) AS cov_rate
FROM website_sessions AS ws
LEFT JOIN orders AS od
ON ws.website_session_id = od.website_session_id
WHERE ws.utm_source = 'gsearch'
AND ws.created_at < '2012-11-27'
GROUP BY 1,2;

-- Similar monthly trend splitting our nonbrand and brand campaigns separately.

SELECT 
YEAR(ws.created_at) AS yr,
month(ws.created_at) AS mn,
COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand' THEN od.order_id ELSE NULL END) AS nonbrand_orders,
COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand' THEN od.order_id ELSE NULL END) AS brand_orders
FROM website_sessions AS ws
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2012-11-27'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign IN ('nonbrand','brand')
GROUP BY 1,2;

-- Gsearch, dive into nonbrand, and pull monthly sessions and order split by device type?

SELECT YEAR(ws.created_at) AS yr,
MONTH(ws.created_at) AS mn,
COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_session,
COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN od.order_id ELSE NULL END) AS mobile_order,
COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_session,
COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN od.order_id ELSE NULL END) AS desktop_order
FROM website_sessions AS ws
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND ws.created_at < '2012-11-27'
group by 1,2;


SELECT YEAR(created_at) AS yr,
MONTH(created_at) AS mn,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_count,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_count,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_search_sessions,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1,2;


-- First 8 months, session to order conversion rates,by month


SELECT YEAR(ws.created_at) AS yr,
MONTH(ws.created_at) AS mn,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders,
COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) AS Session_order_conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2;

-- For the gsearch lander test, please estimate the revenue that test earned us. look at the increase CVR from the test (Jun 19 - jul 28), and use nonbrand sessions and revenue since them to calculate incremental value. 

SELECT MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

CREATE TEMPORARY TABLE first_test_pageview
SELECT wp.website_session_id,
MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp
INNER JOIN website_sessions AS ws
ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-7-28'
AND wp.website_pageview_id >= 23504 -- firsr page_view
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
GROUP BY 1;

CREATE TEMPORARY TABLE nonbrand_test_session_w_landing_page
SELECT ft.website_session_id,
wp.pageview_url AS landing_page
FROM first_test_pageview AS ft
LEFT JOIN website_pageviews AS wp 
ON ft.min_pageview_id = wp.website_pageview_id
WHERE wp.pageview_url IN ('/lander-1', '/home');


CREATE TEMPORARY TABLE nonbrand_test_session_w_orders
SELECT nt.website_session_id,
nt.landing_page,
od.order_id 
FROM nonbrand_test_session_w_landing_page AS nt
LEFT JOIN orders AS od
ON od.website_session_id = nt.website_session_id;
 
SELECT landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_session_w_orders
GROUP BY 1;

-- 0.0318 for homepage and VS 0.0406 for lander page
-- 0.0087 additional orders per sessions

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home

SELECT 
	MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
    FROM website_sessions AS ws
    LEFT JOIN website_pageviews AS wp
    ON ws.website_session_id = wp.website_session_id
    WHERE ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND ws.created_at < '2012-11-27';

-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS session_since_test
    FROM website_sessions
    WHERE created_at < '2012-11-27'
    AND website_session_id > 17145
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
    
-- 22972 website sessions since the test
-- 22972 *0.0087 incremental conversion = 202 incremental orders since 7/29

-- Show full conversion funnel from each of the two pages to order

SELECT * FROM website_pageviews






