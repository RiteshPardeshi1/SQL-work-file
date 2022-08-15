-- Help me understand the orders placed and having session_id between 1000 and 2000 and provide me the conversion rate into percentage

SELECT 
    ws.utm_content,
    COUNT(DISTINCT ws.website_session_id) AS session,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_conv_rt
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    ws.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

-- Help me understand where the bulk of our website sessions are coming from. FINDING TOP TRAFFIC SOURCES.

SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC;

 -- Traffic Source Convesion Rate
 
 SELECT 
 COUNT(DISTINCT ws.website_session_id) AS sessions,
 COUNT(DISTINCT od.order_id) AS orders,
 COUNT(DISTINCT od.order_id)/COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_conv_rate
 FROM website_sessions AS ws
 LEFT JOIN orders AS od
 ON ws.website_session_id = od.website_session_id
 WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand' AND ws.created_at < '2012-04-14';
 
 -- Traffic Source Trending Gsearch Volume Trend
 
 SELECT
 MIN(DATE(created_at)) AS week_start_date,
 COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS sessions
 FROM website_sessions
 WHERE created_at < '2012-05-10'
 GROUP BY 
	YEAR(created_at),
    WEEK(created_at);
    
-- Another way of writing query

SELECT MIN(DATE(created_at)) AS week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
    FROM website_sessions
    WHERE created_at < '2012-05-12' 
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at);
    
    -- gsearch device level performance.
    
SELECT 
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_conv_rate
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    ws.created_at < '2012-05-11'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
GROUP BY device_type;

-- Gsearch device level trends.

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS dtop_session,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mob_session
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at)


 


 
 
 