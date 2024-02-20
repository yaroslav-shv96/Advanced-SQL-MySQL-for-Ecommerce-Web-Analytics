# MID COURSE PROJECT
:paperclip: ## The Situation
Maven Fuzzy Factory has been live for ~8 months, and your CEO is due to present company performance metrics to the board next week. You’ll be the one tasked with preparing relevant metrics to show the company’s promising growth.

:paperclip: ### The Objective
Use SQL to :
Extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth, and to tell the story of how you have been able to generate that growth.

Tell the story of your company’s growth, using trended performance data
Use the database to explain some of the details around your growth story, and quantify the revenue impact of some of your wins
Analyze current performance, and use that data available to assess upcoming opportunities

:paperclip: ### QUESTION
1. - Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

Steps :

Extract month from date, calculate relavant sessions and orders based source is gsearch
Aggregate to find conversion rate for every month sessions
Query:
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

Result :

<img width="161" alt="1" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/0d426e49-8c0a-40cf-9764-55c9a79ca487">

Session to orders growth remained stable and saw a steadily increase from March, 3.23% to November, 4.20%.

2. - Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.

Steps :

Extract month from date, calculate relavant sessions and orders based on source is gsearch
Aggregate to find conversion rate for every month based on campaign

Query :
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
Result:


We can see that the percentage of conversion rate of nonbrand campaign steadily grows from 3% to 4%. But, the brand campaign has fluctuating conversion rates/trends every month.

3.
- While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.
Steps :

Extract month from date, calculate relavant sessions and orders based on source is gsearch
Aggregate to find nonbrand conversion rate for every month based on device type

Query :
```sql
SELECT 
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS desktop_orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;
```

Result:
<img width="364" alt="3" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/462c2d51-154b-4eef-bfd8-554efec84d25">

The majority of the conversion rate contribution came from desktop users with a good growth from 4.43% in March, it dropped in April to 3.51%, but continued to increase in the following months to reach 5% in November. The contribution with mobile devices is quite low and there is a need to investigate this, it could be that the web accessed through mobile is not user friendly.

💡4 - I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
Step :

Find the various utm sources and refers to see the traffic we're getting
Extract months and aggregate to find each session based on the last output condition

Query :

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

Result:
<img width="472" alt="4" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/4e451e57-231c-494c-8bdb-31d2da447823">

Gsearh is the dominant traffic among other channels. Not only gsearch, each channel also experiences session growth every month.

💡5 - I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?
Step :

Extract month from date, calculate relavant sessions and orders
Aggregate to find conversion rate for every month sessions

Query :
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

Result:
<img width="220" alt="5" src="https://github.com/yaroslav-shv96/Advanced-SQL-MySQL-for-Ecommerce-Web-Analytics/assets/159712709/fcda44a0-f897-4928-990b-0161b3b37688">

The conversion rate in March was 3.19% and decreased in the next month. The conversion rate started to increase steadily in the following month until it reached 4.40% in November.

💡6 - For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
Step :

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

-- 22972 sessions since the test
```







