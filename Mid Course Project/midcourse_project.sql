USE mavenfuzzyfactory;
-- 1 
SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

-- 2

SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1,2;

-- 3

SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;

-- 4

SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
COUNT(DISTINCT CASE WHEN utm_source IS NULL and http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
COUNT(DISTINCT CASE WHEN utm_source IS NULL and http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- 5

SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100 AS convers_rate
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- 6

SELECT
MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- first_test_pv = 23504

CREATE TEMPORARY TABLE first_test_pageviews1
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-07-28'
AND website_pageviews.website_pageview_id >= 23504
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'

GROUP BY website_pageviews.website_session_id;

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT 
first_test_pageviews1.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews1
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = first_test_pageviews1.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT 
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
LEFT JOIN orders
ON orders.website_session_id  = nonbrand_test_sessions_w_landing_pages.website_session_id;

SELECT
landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

SELECT
MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27';

-- max website_session_id = 17145

SELECT
COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND website_session_id > 17145
AND created_at < '2012-11-27';

-- 22972 sessions since the test

-- 7

CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
website_session_id,
MAX(homepage) AS saw_homepage,
MAX(custom_lander) AS saw_custom_lander,
MAX(products_page) AS product_made_it,
MAX(mrfuzzy_page) AS mrfuzzy_made_it,
MAX(cart_page) AS cart_made_it,
MAX(shipping_page) AS shipping_made_it,
MAX(billing_page) AS billing_made_it,
MAX(thank_you_page) AS thank_you_made_it
FROM(
SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url = '/home' THEN 1 ELSE NULL END AS homepage,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE NULL END AS custom_lander,
CASE WHEN pageview_url = '/products' THEN 1 ELSE NULL END AS products_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thank_you_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
AND website_sessions.utm_campaign = 'nonbrand'
AND website_sessions.created_at > '2012-06-19'
AND website_sessions.created_at < '2012-07-28'
ORDER BY
website_sessions.website_session_id,
website_pageviews.created_at
) AS pageview_level
GROUP BY
website_session_id;

CREATE TEMPORARY TABLE session_level1
SELECT
website_session_id,
MAX(product_page) AS product,
MAX(mrfuzzy_page) AS mrfuzzy,
MAX(cart_page) AS cart,
MAX(shipping_page) AS shipping,
MAX(billing_page) AS billing,
MAX(thank_you_page) AS thank_you
FROM(
SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url = '/products' THEN 1 ELSE NULL END AS product_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thank_you_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
AND website_sessions.utm_campaign = 'nonbrand'
AND website_sessions.created_at > '2012-08-05'
AND website_sessions.created_at < '2012-09-05'
ORDER BY
website_sessions.website_session_id,
website_pageviews.created_at
) AS pageview_level
GROUP BY
website_session_id;

SELECT
CASE WHEN saw_homepage = 1 THEN 'saw_homepage'
WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
ELSE 'else'
END AS segment,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thank_you
FROM session_level_made_it_flagged
GROUP BY 1;

-- 8

SELECT 
billing_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;