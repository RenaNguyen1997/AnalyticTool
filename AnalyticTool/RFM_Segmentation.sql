declare @Today Date= Getdate();
With RFM_score as(
select *,
	NTILE(5) over (order by Recency ASC) as RecencyScore,
	NTILE(5) over (order by Frequency DESC) as FrequencyScore,
	NTILE(5) over (order by Monetary DESC) as MonetaryScore
from (select 
	c.[Customer Key] as ID,
	c.Customer as Customer_name,
	DATEDIFF(DAY, MAX(t.[Date Key]), @Today) AS Recency,
	COUNT(t.[Transaction Key]) as Frequency,
	SUM(t.[Total Including Tax]) as Monetary
from [Dimension].[Customer] as c
join [Fact].[Transaction] as t on c.[Customer Key] = t.[Customer Key]
group by c.[Customer Key], c.Customer
having SUM(t.[Total Including Tax])>0) as RFM
)
select ID, Customer_name, 
	CAST(RecencyScore AS VARCHAR(1)) + CAST(FrequencyScore AS VARCHAR(1)) + CAST(MonetaryScore AS VARCHAR(1)) AS RFM_score,
	case
		when CAST(RecencyScore AS VARCHAR(1)) + CAST(FrequencyScore AS VARCHAR(1)) + CAST(MonetaryScore AS VARCHAR(1)) IN ('555', '554', '545') THEN 'Champion'
		when CAST(RecencyScore AS VARCHAR(1)) + CAST(FrequencyScore AS VARCHAR(1)) + CAST(MonetaryScore AS VARCHAR(1)) IN ('444', '445', '454') THEN 'Loyal'
		when CAST(RecencyScore AS VARCHAR(1)) + CAST(FrequencyScore AS VARCHAR(1)) + CAST(MonetaryScore AS VARCHAR(1)) IN ('534', '533', '543') THEN 'Potential Loyalist'
		when CAST(RecencyScore AS VARCHAR(1)) + CAST(FrequencyScore AS VARCHAR(1)) + CAST(MonetaryScore AS VARCHAR(1)) IN ('122', '121', '211', '212','111','222') THEN 'At Risk'
		ELSE 'Others'
	end as Customer_segment 
from RFM_score
