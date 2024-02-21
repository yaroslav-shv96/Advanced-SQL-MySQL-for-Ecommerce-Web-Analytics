# MID COURSE PROJECT
:paperclip: **The Situation**

Maven Fuzzy Factory has been live for ~8 months, and your CEO is due to present company performance metrics to the board next week. You’ll be the one tasked with preparing relevant metrics to show the company’s promising growth.

:paperclip: **The Objective**

**Use SQL to:**

Extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth, and to tell the story of how you have been able to generate that growth.

+ Tell the story of your company’s growth, using trended performance data
+ Use the database to explain some of the details around your growth story, and quantify the revenue impact of some of your wins
+ Analyze current performance, and use that data available to assess upcoming opportunities

## QUESTION
:round_pushpin: **Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?**

**Steps:**

+ Extract year and month from date, calculate relavant sessions and orders based source is gsearch

**Query:**
```sql
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
```

**Result:**

<img width="161" alt="1" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/0d426e49-8c0a-40cf-9764-55c9a79ca487">


*Session and orders growth remained stable and saw a steadily increase.* 

:round_pushpin: **Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.**

**Steps:**

+ Extract year and month from date, calculate relavant sessions and orders based on source is gsearch
+ Splitting out nonbrand and brand campaigns separately

**Query:**
```sql
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
```
**Result:**

<img width="366" alt="2" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/dcc29225-10d2-4803-a474-ff93a7f96614">

*Session and orders growth remained stable and saw a steadily increase.*

:round_pushpin: **While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.**

**Steps:**

+ Extract year and month from date, calculate relavant sessions and orders based on source is gsearch and campaign is nonbrand
+ Pull monthly sessions and orders split by device type

**Query:**
```sql
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
```

**Result:**

<img width="359" alt="3" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/93039e3c-7885-41e5-8161-41c2bd074f40">

*The majority  contribution came from desktop users with a good growth. The contribution with mobile devices is quite low and there is a need to investigate this, it could be that the web accessed through mobile is not user friendly.*

:round_pushpin: **I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?**

**Steps:**

+ Find the various utm sources and refers to see the traffic we're getting
+ Extract months and aggregate to find each session based on the last output condition

**Query:**

```sql
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
```

**Result:**

<img width="472" alt="4" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/4e451e57-231c-494c-8bdb-31d2da447823">


*Gsearh is the dominant traffic among other channels. Not only gsearch, each channel also experiences session growth every month.*

:round_pushpin: **I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?**

**Steps:**

+ Extract month from date, calculate relavant sessions and orders
+ Aggregate to find conversion rate for every month sessions

**Query:**
```sql
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
```

**Result:**

<img width="220" alt="5" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/fcda44a0-f897-4928-990b-0161b3b37688">

*The conversion rate in March was 3.19% and decreased in the next month. The conversion rate started to increase steadily in the following month until it reached 4.40% in November.*

:round_pushpin: **For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)**

**Steps:**

Find lander-1 test was created and the first website_pageview_id, retricting to home and lander-1
Create summary, join the result with order_id and aggregat for session, order, and cvr
Find most recent pageview for gsearch nonbrand where traffic was sent to /home and estimate revenue that test earned from lander-1

Query :
```sql
SELECT
MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- first_test_pv = 23504

-- will find the first pageview_id

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

-- next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT 
first_test_pageviews1.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews1
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = first_test_pageviews1.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

-- will make a temporary table to bring in orders

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT 
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
LEFT JOIN orders
ON orders.website_session_id  = nonbrand_test_sessions_w_landing_pages.website_session_id;

-- find the difference between conversion rates

SELECT
landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

-- 0.0319 for /home, vs 0.0406 for /lander-1
-- 0.0087 additional orders per session

-- finding the most reent pageview for gsearch nonbrand where the traffic was sent to /home

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

-- 22972 website_sessions since the test
```
We can estimate the increase in revenue from the increase in orders :
22972 session x 1.08% (incremental % of order) = 248
So, estimated at least 248 incremental orders since 29 Jul using the lander-1 page
Calculate monthly increase (July - November) :
248 / 4 = 64 additional order/month

💡7 - I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?
Step :

Check pageview_url from two pages was created and create summary all pageviews for relevant session
Categorise website sessions under segment by 'saw_home_page' or 'saw_lander_page' and aggregate data to assess funnel performance
Convert aggregated result to percentage of click rate

Query :
```sql
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

-- final output

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
```

#Result:

<img width="456" alt="6" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/457c403c-6519-4685-8c6f-083acecc44b8">

💡8 - I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact.
Step :

Check billing-2 test was created
Calculate or aggregate the sessions and price_usd for /billing and /billing-2
Calculate billing page sessions for the past month (Sep 27 – Nov 27) and estimate revenue

```sql
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
```
Result :

<img width="274" alt="7" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/cb6dc808-335f-4f2a-81ba-9d24951702b5">

8 — billing-2 has a larger revenue per billing page contribution with a lift of 8.51 dollars/pageview







