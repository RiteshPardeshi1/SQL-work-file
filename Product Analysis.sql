-- Analysing Product sales and Product launch
SELECT primary_product_id,
SUM(price_usd) as revenue,
SUM(price_usd - cogs_usd) AS margin,
AVG(price_usd) as Average
FROM orders
WHERE order_id BETWEEN 10000 AND 11000
GROUP BY 1;

-- Product level sales analysis

SELECT YEAR(created_at) AS yr,
MONTH(created_at) AS mo,
COUNT(order_id) AS number_of_sales,
SUM(price_usd) AS total_revenue,
SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2;

-- Analyse new product launch, Impact of new Product launch

SELECT YEAR(ws.created_at) AS YR,
MONTH(ws.created_at) AS MO, 
-- COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT od.order_id) AS orders,
COUNT(DISTINCT od.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
SUM(od.price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
COUNT(DISTINCT CASE WHEN od.primary_product_id = 1 THEN od.order_id ELSE NULL END) AS product_one_orders,
COUNT(DISTINCT CASE WHEN od.primary_product_id = 2 THEN od.order_id ELSE NULL END) AS product_two_orders
FROM website_sessions AS ws 
LEFT JOIN orders AS od ON ws.website_session_id = od.website_session_id
WHERE ws.created_at > '2012-04-01' AND ws.created_at < '2013-04-05'
GROUP BY 1,2
ORDER BY 1,2;

-- Product level website analysis
CREATE TEMPORARY TABLE first_table
select website_session_id,
website_pageview_id,
created_at,
CASE WHEN created_at < '2013-01-06' THEN 'A.Pre_product' 
	WHEN created_at >= '2013-01-06' THEN 'B.Post_product'
    ELSE 'uh.Oh..Check logic'
    END AS time_period
FROM website_pageviews
WHERE created_at > '2012-10-06' AND
created_at < '2013-04-06' AND
pageview_url = '/products';

-- finding the next pageview id that occurs AFTER the product pageviews.
CREATE TEMPORARY TABLE second_table
SELECT ft.time_period,ft.website_session_id,
MIN(wp.website_pageview_id) AS min_next_paveview_id
FROM first_table AS ft
LEFT JOIN website_pageviews AS wp ON wp.website_session_id = ft.website_session_id
AND wp.website_pageview_id > ft.website_pageview_id
GROUP BY 1,2;

-- Find the pageview url associated with any applicable next pageview id
CREATE TEMPORARY TABLE third_table
SELECT sd.time_period,
sd.website_session_id,
wp.pageview_url AS next_pageview_url
FROM second_table AS sd
LEFT JOIN website_pageviews AS wp ON wp.website_pageview_id = sd.min_next_paveview_id;

SELECT time_period,
COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page,
COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_w_next_page,
COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_fuzzy,
COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_to_fuzzy,
COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_bear,
COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_to_bear
FROM third_table
GROUP BY 1;


-- Building Product level conversion funnels

CREATE TEMPORARY TABLE session_seeing_product_pages
SELECT website_session_id,
website_pageview_id,
pageview_url AS product_page_seen
 FROM website_pageviews
 WHERE created_at < '2013-04-10' 
 AND created_at > '2013-01-06'
 AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
 GROUP BY 1;
 
 SELECT DISTINCT wp.pageview_url
 FROM session_seeing_product_pg AS ss LEFT JOIN website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
 AND wp.website_pageview_id > ss.website_pageview_id
 
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

CREATE TEMPORARY TABLE xyzzzz
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
GROUP BY 1;

SELECT 
CASE WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'MRfuzzy'
	 WHEN product_page_seen = '/the-forever-love-bear' THEN 'LOVEbear'
     ELSE NULL
     END AS product_seen,
COUNT(DISTINCT website_session_id) AS session,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT website_session_id) AS product_page_click_rt,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / 
 COUNT(DISTINCT website_session_id) AS cart_click_rt,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / 
COUNT(DISTINCT website_session_id) AS shipping_click_rt,
COUNT(DISTINCT CASE WHEN thanku_made_it = 1 THEN website_session_id ELSE NULL END) / 
COUNT(DISTINCT website_session_id) AS billing_click_rt
FROM xyzzz
GROUP BY 1;

-- Cross Selling Product.
CREATE TEMPORARY TABLE first_table
SELECT website_session_id,
website_pageview_id,
CASE WHEN created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell'
	 WHEN created_at > '2013-09-25' THEN 'B.Post_Cross_Sell'
	 ELSE 'uh.oh..Check Logic'
	 END AS time_period
FROM website_pageviews 
WHERE created_at > '2013-08-25'
AND created_at < '2013-10-25'
AND pageview_url = '/cart';

CREATE TEMPORARY TABLE second_tables
SELECT ft.time_period,
ft.website_session_id,
MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM first_table AS ft 
LEFT JOIN website_pageviews AS wp ON ft.website_session_id = wp.website_session_id
AND wp.website_pageview_id > ft.website_pageview_id
GROUP BY 1,2
HAVING MIN(wp.website_pageview_id) IS NOT NULL;

CREATE TEMPORARY TABLE third_tabless
SELECT ft.time_period,
ft.website_session_id,
sd.min_next_pageview_id,
od.order_id AS orders,
od.items_purchased AS item_purchased,
od.price_usd AS price
FROM first_table AS ft
INNER JOIN orders AS od ON ft.website_session_id = od.website_session_id
INNER JOIN second_tables AS sd ON sd.website_session_id = ft.website_session_id;

SELECT time_period,
COUNT(DISTINCT website_session_id) AS cart_sessions,
COUNT(DISTINCT min_next_pageview_id) AS clickthroughs,
COUNT(DISTINCT min_next_pageview_id) / COUNT(DISTINCT website_session_id) AS cart_ctr,
AVG(item_purchased) / COUNT(DISTINCT orders) AS product_per_order,
SUM(price) / COUNT(DISTINCT orders) AS aov,
SUM(price) / COUNT(DISTINCT website_session_id) AS rev_per_cart_session
FROM third_tabless
GROUP BY 1;


-- Recent Product Launch Product Portfolio Launch

CREATE TEMPORARY TABLE first_tables
SELECT 
CASE WHEN created_at < '2013-12-12'
	 THEN 'A.Pre_Birthday_bear'
	 WHEN created_at >= '2013-12-12'
     THEN 'B.Post_Birthday_bear'
     ELSE 'Check_logic'
     END AS time_period,
website_session_id AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2013-11-12'
 AND '2014-01-12';

CREATE TEMPORARY TABLE second_tables
SELECT ft.time_period,
ft.sessions,
od.order_id AS orders,
od.price_usd AS price,
od.items_purchased AS item
FROM first_tables AS ft 
LEFT JOIN orders AS od 
ON ft.sessions = od.website_session_id
GROUP BY 1,2;

SELECT time_period,
COUNT(DISTINCT orders)/ COUNT(DISTINCT sessions) AS conv_rate,
SUM(price)/COUNT(DISTINCT orders) AS aov,
SUM(item)/COUNT(DISTINCT orders) AS product_per_order,
SUM(price)/COUNT(DISTINCT sessions) AS revenue_per_sessions
FROM second_tables
GROUP BY 1;

-- Analysing Product Refund Rate
------------ Quality Issues And refunds----------------

SELECT YEAR(od.created_at) AS yr,
MONTH(od.created_at) AS mo,
COUNT(DISTINCT CASE WHEN od.product_id = 1 THEN od.order_item_id ELSE NULL END) AS p1_orders,
COUNT(DISTINCT CASE WHEN od.product_id = 1 THEN rd.order_item_id ELSE NULL END) /COUNT(DISTINCT CASE WHEN od.product_id = 1 THEN od.order_id ELSE NULL END) AS p1_refund_rate,
COUNT(DISTINCT CASE WHEN od.product_id = 2 THEN od.order_item_id ELSE NULL END) AS p2_orders,
COUNT(DISTINCT CASE WHEN od.product_id = 2 THEN rd.order_item_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN od.product_id = 2 THEN od.order_id ELSE NULL END) AS p2_refund_rate,
COUNT(DISTINCT CASE WHEN od.product_id = 3 THEN od.order_item_id ELSE NULL END) AS p3_orders,
COUNT(DISTINCT CASE WHEN od.product_id = 3 THEN rd.order_item_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN od.product_id = 3 THEN od.order_id ELSE NULL END) AS p3_refund_rate,
COUNT(DISTINCT CASE WHEN od.product_id = 4 THEN od.order_item_id ELSE NULL END) AS p4_orders,
COUNT(DISTINCT CASE WHEN od.product_id = 4 THEN rd.order_item_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN od.product_id = 4 THEN od.order_id ELSE NULL END) AS p4_refund_rate
FROM order_items AS od 
LEFT JOIN order_item_refunds AS rd ON od.order_id = rd.order_id
WHERE od.created_at BETWEEN '2012-03-01' AND '2014-10-31'
GROUP BY 1,2;









































































