-- Top website Pages

SELECT 
	pageview_url,
	COUNT(distinct website_pageview_id) AS sessions 
FROM 
	website_pageviews
WHERE
	created_at < '2012-06-09'
GROUP BY
	1
ORDER BY
	2 DESC;
    
-- Top entry pages

CREATE TEMPORARY TABLE first_pv_per_session
SELECT website_session_id,
MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT wpv.pageview_url AS landing_page,
COUNT(DISTINCT fpv.website_session_id) AS session_hitting_page
FROM first_pv_per_session AS fpv
LEFT JOIN website_pageviews AS wpv
ON fpv.first_pv = wpv.website_session_id
GROUP BY wpv.pageview_url

CREATE TEMPORARY TABLE first_table
SELECT website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pv_count
FROM website_pageviews
INNER JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
AND website_sessions.created_at < '2012-06-14'
GROUP BY 1;

CREATE TEMPORARY TABLE second_table
SELECT first_table.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_table
LEFT JOIN website_pageviews
ON first_table.website_session_id = website_pageviews.website_session_id
AND website_pageviews.pageview_url = '/home';

CREATE TEMPORARY TABLE third_table
SELECT second_table.website_session_id,
second_table.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM second_table
LEFT JOIN website_pageviews
ON second_table.website_session_id = website_pageviews.website_session_id
GROUP BY 1,2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;


SELECT COUNT(DISTINCT second_table.website_session_id) AS sessions,
COUNT(DISTINCT third_table.website_session_id) AS bounched_session,
COUNT(DISTINCT third_table.website_session_id) / COUNT(DISTINCT second_table.website_session_id) * 100 AS bounce_rate
FROM second_table LEFT JOIN
third_table ON second_table.website_session_id = third_table.website_session_id;

CREATE TEMPORARY TABLE first_tables
SELECT website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pv_count
FROM website_sessions INNER JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1;

CREATE TEMPORARY TABLE second_tables
SELECT first_tables.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_tables
LEFT JOIN website_pageviews ON first_tables.website_session_id = website_pageviews.website_session_id
AND website_pageviews.pageview_url IN ('/home','/lander-1');

CREATE TEMPORARY TABLE third_tables
SELECT second_tables.website_session_id,
second_tables.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM second_tables
LEFT JOIN website_pageviews ON second_tables.website_session_id = website_pageviews.website_session_id
GROUP BY 1,2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;

SELECT second_tables.landing_page,
COUNT(DISTINCT second_tables.website_session_id) AS total_sessions,
COUNT(DISTINCT third_tables.website_session_id) AS bounced_sessions,
COUNT(DISTINCT third_tables.website_session_id)/COUNT(DISTINCT second_tables.website_session_id)*100 AS Bounce_rate
FROM second_tables
LEFT JOIN third_tables ON second_tables.website_session_id = third_tables.website_session_id
GROUP BY 1;

-- Help analysing conversion funnel 

SELECT ws.website_session_id,
wp.pageview_url,
ws.created_at,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanku_page
FROM website_sessions AS ws 
LEFT JOIN website_pageviews AS wp 
ON ws.website_session_id = wp.website_session_id
WHERE wp.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
AND ws.created_at > '2012-08-05'
AND ws.created_at < '2012-09-05'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
ORDER BY 1,3;

SELECT website_session_id,
MAX(lander_page) AS lander_made_it,
MAX(product_page) AS product_made_it,
MAX(mr_fuzzy_page) AS mr_fuzzy_page_made_it,
MAX(cart_page) AS cart_made_it,
MAX(shipping_page) AS shipping_made_it,
MAX(billing_page) AS billing_made_it,
MAX(thanku_page) AS thanku_made_it
FROM (SELECT ws.website_session_id,
wp.pageview_url,
ws.created_at,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanku_page
FROM website_sessions AS ws 
LEFT JOIN website_pageviews AS wp 
ON ws.website_session_id = wp.website_session_id
WHERE wp.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
AND ws.created_at > '2012-08-05'
AND ws.created_at < '2012-09-05'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
ORDER BY 1,3
) AS pageview
GROUP BY 1;

SELECT COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN lander_made_it = 1 THEN website_session_id ELSE NULL END) AS to_lander,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_product,
COUNT(DISTINCT CASE WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thanku_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thanku
FROM XYZ;

SELECT COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN lander_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT website_session_id) *100 AS lander_click_rt,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / 
COUNT(DISTINCT CASE WHEN lander_made_it = 1 THEN website_session_id ELSE NULL END) *100 AS product_click_rate,
COUNT(DISTINCT CASE WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) *100 AS mrfuzzy_click_rt,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id ELSE NULL END) *100 AS cart_click_rate,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / 
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) *100 AS shipping_click_rate,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) *100 AS billing_click_rate,
COUNT(DISTINCT CASE WHEN thanku_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
*100 AS thanku_click_rate
FROM XYZ;

-- Analysing Conversion funnel test for billing page
SELECT wp.website_session_id,
wp.pageview_url AS billing_pageviews_seen,
od.order_id 
FROM website_pageviews AS wp
LEFT JOIN orders AS od ON wp.website_session_id = od.website_session_id
WHERE wp.pageview_url IN ('/billing-2','/billing')
AND wp.website_pageview_id >= 53550 -- first pageview_Id
AND wp.created_at < '2012-11-10';

SELECT billing_pageviews_seen,
COUNT(DISTINCT website_session_id) AS Sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM (SELECT wp.website_session_id,
wp.pageview_url AS billing_pageviews_seen,
od.order_id 
FROM website_pageviews AS wp
LEFT JOIN orders AS od ON wp.website_session_id = od.website_session_id
WHERE wp.pageview_url IN ('/billing-2','/billing')
AND wp.website_pageview_id >= 53550 -- first pageview_Id
AND wp.created_at < '2012-11-10'
) AS billing_session_w_orders
GROUP BY 1








