SELECT 
	cohort_year ,
	SUM(net_revenue) AS total_net_revenue,
	COUNT(DISTINCT customerkey) AS total_customer,
	(
		SUM(net_revenue)
	) / (
		COUNT(DISTINCT customerkey)
	) AS customer_revenue
FROM
	cohort_analysis
GROUP BY 
	cohort_year ;