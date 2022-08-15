SELECT primary_product_id,
COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item,
COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

SELECT pageview_url,
COUNT(DISTINCT website_pageview_id) AS pvs 
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pvs DESC;

CREATE TEMPORARY TABLE first_pageview
SELECT website_session_id,
MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

SELECT * FROM first_pageview;

SELECT  website_pageviews.pageview_url AS landing_page,
	COUNT(DISTINCT first_pageview.website_session_id) AS session_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY
	website_pageviews.pageview_url;
    
SELECT pageview_url,
COUNT(DISTINCT website_session_id) AS sessions 
FROM website_pageviews
WHERE pageview_url = '/home'
AND website_pageview_id < 1000
GROUP BY 1;

CREATE TEMPORARY TABLE first_pageviews_demo
SELECT wpv.website_session_id, 
MIN(wpv.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wpv
INNER JOIN website_sessions AS ws
ON wpv.website_session_id = ws.website_session_id
AND ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wpv.website_session_id;

SELECT * FROM first_pageviews_demo;

CREATE TEMPORARY TABLE session_w_landing_page_demo
SELECT first_pageviews_demo.website_session_id,
website_pageviews.pageview_url AS Landing_page
FROM first_pageviews_demo 
	LEFT JOIN website_pageviews
    ON first_pageviews_demo.min_pageview_id = website_pageviews.website_pageview_id;
    
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT session_w_landing_page_demo.website_session_id,
session_w_landing_page_demo.landing_page,
COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM session_w_landing_page_demo
LEFT JOIN
website_pageviews
ON session_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
GROUP BY 1,2
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;
    
 SELECT session_w_landing_page_demo.landing_page,
 COUNT(DISTINCT session_w_landing_page_demo.website_session_id) AS sessions,
 COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_website,
 COUNT(DISTINCT bounced_sessions_only.website_session_id)/COUNT(DISTINCT session_w_landing_page_demo.website_session_id)*100 AS bounced_rate
 FROM session_w_landing_page_demo
 LEFT JOIN
 bounced_sessions_only 
 ON session_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
 GROUP BY 1;
 
 CREATE TEMPORARY TABLE first_table
 SELECT wpv.website_session_id AS session_id,
 MIN(wpv.website_pageview_id) AS min_pageview
 FROM website_pageviews AS wpv
 INNER JOIN
	website_sessions AS ws 
    ON wpv.website_session_id = ws.website_session_id
    AND ws.created_at between '2014-01-01' AND '2014-02-01'
 GROUP BY 1;
 
 CREATE TEMPORARY TABLE second_table
SELECT first_table.session_id,
website_pageviews.pageview_url as landing_page
FROM first_table
LEFT JOIN 
	website_pageviews 
		ON first_table.min_pageview = website_pageviews.website_pageview_id;

CREATE TEMPORARY TABLE bounched_session_only
SELECT second_table.session_id,
second_table.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM second_table 
	LEFT JOIN website_pageviews 
		ON second_table.session_id = website_pageviews.website_session_id
GROUP BY 1,2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;


SELECT second_table.landing_page,
COUNT(DISTINCT second_table.session_id) AS sessions,
COUNT(DISTINCT bounched_session_only.session_id) AS bounched_session,
COUNT(DISTINCT bounched_session_only.session_id)/COUNT(DISTINCT second_table.session_id)*100 AS bounce_rate
FROM second_table 
LEFT JOIN bounched_session_only ON second_table.session_id = bounched_session_only.session_id
GROUP BY landing_page;

SELECT * FROM website_sessions;
-- WHERE pageview_url = '/lander-1';

CREATE TEMPORARY TABLE first_table
SELECT website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pv_count
FROM website_sessions INNER JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY 1;


CREATE TEMPORARY TABLE second_table
SELECT first_table.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_table
LEFT JOIN website_pageviews ON first_table.website_session_id = website_pageviews.website_session_id
AND website_pageviews.pageview_url IN ('/home','/lander-1');

CREATE TEMPORARY TABLE third_table
SELECT second_table.website_session_id,
second_table.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM second_table
LEFT JOIN website_pageviews ON second_table.website_session_id = website_pageviews.website_session_id
GROUP BY 1,2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;

SELECT second_table.landing_page,
COUNT(DISTINCT second_table.website_session_id) AS total_sessions,
COUNT(DISTINCT third_table.website_session_id) AS bounced_sessions,
COUNT(DISTINCT third_table.website_session_id)/COUNT(DISTINCT second_table.website_session_id)*100 AS Bounce_rate
FROM second_table 
LEFT JOIN third_table ON second_table.website_session_id = third_table.website_session_id
GROUP BY 1;

CREATE TEMPORARY TABLE first_tables
SELECT website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pv_count,
MIN(DATE(website_sessions.created_at)) AS week_start_date
FROM website_sessions INNER JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1,
YEAR(website_sessions.created_at),
WEEK(website_sessions.created_at);

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

SELECT first_tables.week_start_date,
COUNT(DISTINCT	CASE WHEN third_tables.landing_page = '/home' THEN third_tables.website_session_id
ELSE NULL END) AS home_session,
COUNT(DISTINCT	CASE WHEN third_tables.landing_page = '/lander-1' THEN third_tables.website_session_id
ELSE NULL END) AS lander_session,
COUNT(DISTINCT	CASE WHEN third_tables.landing_page = '/lander-1' THEN third_tables.website_session_id
ELSE NULL END) / COUNT(DISTINCT	CASE WHEN third_tables.landing_page = '/home' THEN third_tables.website_session_id
ELSE NULL END) * 100 AS bounce_rate
FROM first_tables LEFT JOIN third_tables ON first_tables.website_session_id = third_tables.website_session_id
GROUP BY YEAR(first_tables.week_start_date),
		WEEK(first_tables.week_start_date);
        
SELECT ws.website_session_id,
wp.pageview_url,
wp.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws 
LEFT JOIN website_pageviews AS wp 
ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at BETWEEN '2014-01-01' AND '2014-02-01'
AND wp.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 1,3;

SELECT website_session_id,
MAX(product_page) AS product_made_it,
MAX(mrfuzzy_page) AS mrfuzzy_made_it,
MAX(cart_page) AS cart_made_it
FROM
(
SELECT ws.website_session_id,
wp.pageview_url,
wp.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws 
LEFT JOIN website_pageviews AS wp 
ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at BETWEEN '2014-01-01' AND '2014-02-01'
AND wp.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 1,3) AS pageview_level
GROUP BY 1;

CREATE TEMPORARY TABLE session_level_made_it_flag_demo
SELECT website_session_id,
MAX(product_page) AS product_made_it,
MAX(mrfuzzy_page) AS mrfuzzy_made_it,
MAX(cart_page) AS cart_made_it
FROM
(
SELECT ws.website_session_id,
wp.pageview_url,
wp.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws 
LEFT JOIN website_pageviews AS wp 
ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at BETWEEN '2014-01-01' AND '2014-02-01'
AND wp.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 1,3) AS pageview_level
GROUP BY 1;

SELECT COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id)* 100 AS clicked_to_product,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)* 100 AS clicked_to_mrfuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)* 100 AS clicked_to_cart
FROM session_level_made_it_flag_demo;


SELECT pageview_url from website_pageviews
GROUP BY 1;

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

SELECT  created_at AS first_created_at, website_pageview_id AS first_pv_id
FROM  website_pageviews
WHERE pageview_url = '/billing-2'
ORDER BY 1 ASC;

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
GROUP BY 1;

SELECT wp.website_session_id, wp.pageview_url AS landing_page, od.order_id,
CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page
FROM website_pageviews AS wp
LEFT JOIN orders AS od
ON wp.website_session_id = od.website_session_id
LEFT JOIN website_sessions AS ws ON ws.website_session_id = od.website_session_id
WHERE wp.pageview_url IN ('/home','/lander-1')
AND wp.created_at BETWEEN '2012-7-19' AND '2012-8-28'
AND ws.utm_source ='gsearch'
AND ws.utm_campaign = 'nonbrand';

CREATE TEMPORARY TABLE xyzz
SELECT website_session_id,
MAX(home_page) AS home_made_it,
MAX(lander_page) AS lander_made_it
FROM(SELECT wp.website_session_id, wp.pageview_url, od.order_id,
CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page
FROM website_pageviews AS wp
LEFT JOIN orders AS od
ON wp.website_session_id = od.website_session_id
LEFT JOIN website_sessions AS ws ON ws.website_session_id = od.website_session_id
WHERE wp.pageview_url IN ('/home','/lander-1')
AND wp.created_at BETWEEN '2012-7-19' AND '2012-8-28'
AND ws.utm_source ='gsearch'
AND ws.utm_campaign = 'nonbrand'
) AS pageview_level
GROUP BY 1;

SELECT COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN home_made_it = 1 THEN website_session_id ELSE NULL END) AS to_home,
COUNT(DISTINCT CASE WHEN lander_made_it = 1 THEN website_session_id ELSE NULL END) AS to_lander
FROM xyzz;
 
SELECT COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN home_made_it = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT website_session_id)
AS to_home_pct,
COUNT(DISTINCT CASE WHEN lander_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id)
 AS to_lander_pct
FROM xyzz;
 
 CREATE TEMPORARY TABLE xyz
SELECT website_session_id,
website_pageview_id, 
created_at,
CASE WHEN created_at >= '2013-01-06' THEN 'A.post_cart'
	 WHEN created_at < '2013-01-06' THEN 'B.pre_cart'
     ELSE 'uh.nO cHECK lOGIC'
     END AS time_period
FROM 
website_pageviews
WHERE created_at > '2012-10-06'
AND created_at < '2013-04-06'
AND pageview_url = '/cart';

CREATE TEMPORARY TABLE zyx
SELECT x.time_period, x.website_session_id,
MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM XYZ as X
LEFT JOIN website_pageviews AS wp ON x.website_session_id = wp.website_session_id
								  And wp.website_pageview_id > x.website_pageview_id
GROUP BY 1,2 ;

CREATE TEMPORARY TABLE abc
SELECT  z.time_period,
z.website_session_id,
wp.pageview_url AS next_page_view
 FROM zyx AS z
 LEFT JOIN website_pageviews as wp ON wp.website_pageview_id = z.min_next_pageview_id;

SELECT time_period,
COUNT(DISTINCT case when next_page_view IS NOT NULL THEN website_session_id ELSE NULL END) w_next_page,
COUNT(DISTINCT case when next_page_view IS NOT NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_w_next_page
FROM abc
GROUP BY 1;

CREATE TEMPORARY TABLE session_seeing_product_pg
SELECT website_session_id,
website_pageview_id,
pageview_url AS product_page_seen
 FROM website_pageviews
 WHERE created_at < '2013-04-10' 
 AND created_at > '2013-01-06'
 AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
 GROUP BY 1;
 
 SELECT 
ss.website_session_id,
ss.product_page_seen,
CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanku_page
FROM session_seeing_product_pg AS ss
LEFT JOIN website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
AND wp.website_pageview_id > ss.website_pageview_id;

CREATE TEMPORARY TABLE xyzzz
SELECT website_session_id,
product_page_seen,
MAX(cart_page) AS cart_made_it,
MAX(shipping_page) AS shipping_made_it,
MAX(billing_page) AS billing_made_it,
MAX(thanku_page) AS thanku_made_it
FROM( SELECT 
ss.website_session_id,
ss.product_page_seen,
CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanku_page
FROM session_seeing_product_pg AS ss
LEFT JOIN website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
AND wp.website_pageview_id > ss.website_pageview_id

) AS page_view
GROUP BY 1;

SELECT 
CASE WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'MRfuzzy'
	 WHEN product_page_seen = '/the-forever-love-bear' THEN 'LOVEbear'
     ELSE NULL
     END AS product_seen,
COUNT(DISTINCT website_session_id) AS session,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thanku_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thanku
FROM xyzzz
GROUP BY 1


SELECT 
COUNT(DISTINCT CASE WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 
	 WHEN product_page_seen = '/the-forever-love-bear' THEN 'LOVEbear'
     ELSE NULL
     END AS product_seen,
COUNT(DISTINCT website_session_id) AS session,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thanku_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thanku
FROM xyzz
GROUP BY 1











 
 
 
 
 
 
 
 
 
 
 
 






























