WITH customer_last_purchase AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_orderdate,
		cohort_year
	FROM
		cohort_analysis
),
churned_customer AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate AS last_purchase_date,
		CASE
			WHEN orderdate < (
				SELECT
					max(orderdate)
				FROM
					sales
			) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active'
		END AS customer_status,
		cohort_year
	FROM
		customer_last_purchase
	WHERE
		rn = 1
		AND first_orderdate < (
			SELECT
				max(orderdate)
			FROM
				sales
		) - INTERVAL '6 months'
)
SELECT
	cohort_year ,
	customer_status,
	count(customerkey) AS num_customers,
	sum(count(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
	round(count(customerkey) / sum(count(customerkey)) OVER(PARTITION BY cohort_year), 2) AS status_percentage
FROM 
	churned_customer
GROUP BY
	cohort_year ,
	customer_status