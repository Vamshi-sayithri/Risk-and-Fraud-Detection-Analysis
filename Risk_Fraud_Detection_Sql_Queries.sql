select * from risk_fraud_dataset

select *,CASE 
             WHEN [Fraud_Flag] = 1 THEN 'Fraud'
             WHEN [Fraud_Flag] = 0 THEN 'Genuine'
             Else 'Nothing'
         END AS Fraud_Status
from risk_fraud_dataset

alter table risk_fraud_dataset add Fraud_status varchar(20)

update risk_fraud_dataset set Fraud_status=CASE 
             WHEN [Fraud_Flag] = 1 THEN 'Fraud'
             WHEN [Fraud_Flag] = 0 THEN 'Genuine'
             Else 'Nothing'
         END
from risk_fraud_dataset


---Kpis
----1. Fraud Overview (Executive-Level Questions)

What is the total number of transactions?
select count(*)as total_transactions from risk_fraud_dataset

How many transactions are fraudulent vs Genuine?

select fraud_Status,count(*) total_transactions from risk_fraud_dataset group by fraud_status

What is the overall fraud rate (%)?
SELECT 
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0) 
        / COUNT(*), 
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset;


What is the total fraud loss amount?
select sum(transaction_amount) as total_Fraud_loss_amount from risk_fraud_dataset where fraud_flag=1


What percentage of total transaction value is fraudulent?
SELECT 
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END) * 100.0)
        / SUM(transaction_amount),
    2) AS fraud_amount_percentage
FROM risk_fraud_dataset;

🟠 2. Time-Based Fraud Analysis

How does fraud trend over time (daily / monthly)?
SELECT
    CAST(transaction_date AS DATE) AS fraud_date,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY CAST(transaction_date AS DATE)
ORDER BY fraud_date;

SELECT
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    DATENAME(MONTH, transaction_date) AS month_name,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date),
    DATENAME(MONTH, transaction_date)
ORDER BY year, month;



Are there specific dates with spikes in fraud activity?
SELECT
    CAST(transaction_date AS DATE) AS fraud_date,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY CAST(transaction_date AS DATE)
HAVING COUNT(*) > 5
ORDER BY fraud_transactions DESC;


What time of day has the highest fraud occurrence?
SELECT
    DATEPART(HOUR, transaction_date) AS hour_of_day,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY DATEPART(HOUR, transaction_date)
ORDER BY fraud_transactions DESC;


Is fraud higher during business hours or non-business hours?
SELECT
    CASE
        WHEN DATEPART(HOUR, transaction_date) BETWEEN 9 AND 17
            THEN 'Business Hours'
        ELSE 'Non-Business Hours'
    END AS time_category,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY
    CASE
        WHEN DATEPART(HOUR, transaction_date) BETWEEN 9 AND 17
            THEN 'Business Hours'
        ELSE 'Non-Business Hours'
    END;


Are recent transactions showing increased risk patterns?
SELECT
    CASE
        WHEN transaction_date >= DATEADD(DAY, -7, GETDATE())
            THEN 'Last 7 Days'
        ELSE 'Earlier'
    END AS period,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY
    CASE
        WHEN transaction_date >= DATEADD(DAY, -7, GETDATE())
            THEN 'Last 7 Days'
        ELSE 'Earlier'
    END;

🟡 3. Transaction Amount & Type Analysis

Which transaction types have the highest fraud rate?
select transaction_type, ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0) 
        / COUNT(*), 
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset group by transaction_type order by fraud_rate_percentage desc


Which transaction types cause the highest fraud losses?

select transaction_type,sum(transaction_amount) as fraud_loss from risk_fraud_dataset 
where fraud_flag=1 group by transaction_type order by fraud_loss desc

Is fraud more common in high-value transactions?

SELECT
    CASE
        WHEN transaction_amount < 100 THEN 'Low Value'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium Value'
        ELSE 'High Value'
    END AS transaction_value_category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset
GROUP BY
    CASE
        WHEN transaction_amount < 100 THEN 'Low Value'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium Value'
        ELSE 'High Value'
    END
ORDER BY fraud_rate_percentage DESC;


What is the average transaction amount for fraud vs non-fraud?
select fraud_status, avg(transaction_amount) as avg_fraud_transaction_amt from risk_fraud_dataset group by fraud_status


Are small-value transactions used for fraud testing behavior?

SELECT
    CASE
        WHEN transaction_amount < 50 THEN 'Very Small'
        WHEN transaction_amount BETWEEN 50 AND 100 THEN 'Small'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'Large'
    END AS transaction_value_bucket,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY
    CASE
        WHEN transaction_amount < 50 THEN 'Very Small'
        WHEN transaction_amount BETWEEN 50 AND 100 THEN 'Small'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'Large'
    END
ORDER BY fraud_transactions DESC;


🔵 4. Customer Risk Analysis

How many unique customers are involved in fraud?
select count(distinct customer_id) as unique_cust from risk_fraud_dataset where fraud_flag=1

Which customers have multiple fraud transactions?
select customer_id,count(transaction_id) as multiple_fraud_trans from risk_fraud_dataset where fraud_flag=1 
group by customer_id having count(transaction_id)>1

What is the average risk score of fraudulent customers?

Are high-risk-score customers committing more fraud?

What percentage of customers are repeat fraud offenders?


🟢 6. Channel-Based Fraud Analysis

Which channel (Online, ATM, POS, Mobile) has the highest fraud rate?

select device_type, round((sum(case when fraud_flag=1 then 1 else 0 end)*100.0)/count(*),2) as Highest_fraud_rate from 
risk_fraud_dataset group by device_type order by highest_fraud_rate Desc

Which channel causes the maximum fraud loss?

select device_type,sum(transaction_amount) as max_fraud_loss from risk_fraud_dataset where fraud_flag=1 group by device_type 

Are certain channels riskier despite low volume?
SELECT
    device_type,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset
GROUP BY device_type;

How does fraud behavior differ across channels?
SELECT
    device_type,
    COUNT(*) AS fraud_transactions,
    SUM(transaction_amount) AS fraud_loss_amount,
    AVG(transaction_amount) AS avg_fraud_amount
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY device_type;


Which channel should fraud controls focus on first?
select device_type,count(*) as no_of_frauds from risk_fraud_dataset where fraud_flag=1 group by device_type order by no_of_frauds desc

select * from risk_fraud_dataset

🟤7. Geographic Fraud Analysis

Which locations have the highest fraud count?
select Location,count(*) as highest_fraud_count from risk_fraud_dataset where fraud_flag=1 group by location order by highest_fraud_count Desc

Which locations have the highest fraud loss amount?

select Location,sum(transaction_amount) as highest_fraud_loss_amt from 
risk_fraud_dataset where fraud_flag=1 group by location order by highest_fraud_loss_amt Desc

Are there locations with high transactions but low fraud?
SELECT
    location,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset
GROUP BY location
ORDER BY total_transactions DESC;


Are certain regions emerging as fraud hotspots?

SELECT
    location,
    COUNT(*) AS fraud_transactions,
    SUM(transaction_amount) AS fraud_loss_amount
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY location
ORDER BY fraud_transactions DESC, fraud_loss_amount DESC;


How does fraud rate vary geographically?
SELECT
    location,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
    2) AS fraud_rate_percentage
FROM risk_fraud_dataset
GROUP BY location;



🔴 8. Operational & Business Impact Questions

What percentage of transactions are high-risk but legitimate?
SELECT
    ROUND(
        (COUNT(*) * 100.0) /
        (SELECT COUNT(*) FROM risk_fraud_dataset),
    2) AS high_risk_legitimate_percentage
FROM risk_fraud_dataset
WHERE fraud_flag = 0
  AND transaction_amount > 500;


How many transactions could be blocked safely using risk score?
SELECT
    COUNT(*) AS potentially_blockable_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
  AND transaction_amount > 500;


What is the potential revenue loss due to false positives?
SELECT
    SUM(transaction_amount) AS potential_false_positive_loss
FROM risk_fraud_dataset
WHERE fraud_flag = 0
  AND transaction_amount > 500;


Which combination of channel + transaction type is riskiest?
select device_type,transaction_type,count(*) as transactions from risk_fraud_dataset where fraud_flag=1
group by device_type,Transaction_type order by transactions desc



Where should fraud teams prioritize investigations?

SELECT
    device_type,
    transaction_type,
    COUNT(*) AS fraud_transactions,
    SUM(transaction_amount) AS fraud_loss_amount
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY device_type, transaction_type
ORDER BY fraud_transactions DESC, fraud_loss_amount DESC;

