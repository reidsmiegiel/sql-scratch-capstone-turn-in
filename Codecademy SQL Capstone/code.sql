--step 1:
SELECT *
FROM subscriptions
LIMIT 100;

--step 2:
SELECT MIN(subscription_start),
	   MAX(subscription_start)
FROM subscriptions;

--step 3:
WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day')

SELECT *
FROM months;

--step 4:
WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day'),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months)

SELECT *
FROM cross_join
LIMIT 100;

--steps 5 & 6:
WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day'),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

status AS
(SELECT id, 
 				first_day AS 'month',
				CASE 
 					WHEN (segment = 87)
					AND (subscription_start < first_day)
 					AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
				END AS is_active_87,
				CASE
					WHEN (segment = 30)
					AND (subscription_start < first_day)
          			AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
        		END AS is_active_30,
        		CASE
 					WHEN (segment = 87)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_87,
 				CASE
 					WHEN (segment = 30)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN 		
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_30
FROM cross_join) 

SELECT *
FROM status
LIMIT 100;

--step 7:
WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day'),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

status AS
(SELECT id, 
 				first_day AS 'month',
				CASE 
 					WHEN (segment = 87)
					AND (subscription_start < first_day)
 					AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
				END AS is_active_87,
				CASE
					WHEN (segment = 30)
					AND (subscription_start < first_day)
          			AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
        		END AS is_active_30,
        		CASE
 					WHEN (segment = 87)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_87,
 				CASE
 					WHEN (segment = 30)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN 		
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_30
FROM cross_join),

status_aggregate AS
(SELECT month,
 				SUM(is_active_87) AS sum_active_87,
 				SUM(is_active_30) AS sum_active_30,
 				SUM(is_canceled_87) AS sum_canceled_87,
 				SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month)
 
SELECT *
FROM status_aggregate;
 
--step 8:
WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day'),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

status AS
(SELECT id, 
 				first_day AS 'month',
				CASE 
 					WHEN (segment = 87)
					AND (subscription_start < first_day)
 					AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
				END AS is_active_87,
				CASE
					WHEN (segment = 30)
					AND (subscription_start < first_day)
          			AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
					ELSE 0
        		END AS is_active_30,
        		CASE
 					WHEN (segment = 87)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_87,
 				CASE
 					WHEN (segment = 30)
 					AND (subscription_start < first_day)
 					AND (subscription_end BETWEEN 		
          				first_day AND last_day)
 					THEN 1
 					ELSE 0
 				END AS is_canceled_30
FROM cross_join),

status_aggregate AS
(SELECT month,
 				SUM(is_active_87) AS sum_active_87,
 				SUM(is_active_30) AS sum_active_30,
 				SUM(is_canceled_87) AS sum_canceled_87,
 				SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month),

churn_rate AS
(SELECT month, 
 		ROUND(1.0 * sum_canceled_87/sum_active_87,2) 
AS churn_rate_87,
 		ROUND(1.0 * sum_canceled_30/sum_active_30,2) 
AS churn_rate_30 
FROM status_aggregate)

SELECT *
FROM churn_rate;

--step 9 (Bonus):

WITH months AS
(SELECT
'2017-01-01' AS 'first_day',
'2017-01-31' AS 'last_day'
UNION
SELECT
'2017-02-01' AS 'first_day',
'2017-02-28' AS 'last_day'
UNION
SELECT
'2017-03-01' AS 'first_day',
'2017-03-31' AS 'last_day'),

cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),

status_aggregate AS
(SELECT  
 				first_day AS month,
 				segment,
				SUM(CASE 
 					WHEN (subscription_start < first_day)
 					AND (subscription_end > first_day OR subscription_end IS NULL)
					THEN 1
 					ELSE 0 END) AS sum_active,
 			  	SUM(CASE
 					WHEN (subscription_start < first_day)
 					AND (subscription_end BETWEEN
          				first_day AND last_day)
 					THEN 1 
 				  	ELSE 0 END) AS sum_canceled
FROM cross_join
GROUP BY 1,2),

churn_rate AS
(SELECT month,
 		segment,
 		ROUND(1.0 * sum_canceled/sum_active,2) AS churn_rate 
FROM status_aggregate
GROUP BY 1,2)

SELECT *
FROM churn_rate;




