 ---Views for Dashborad
CREATE VIEW Risk_Fraud_KPI AS
SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE 
            WHEN fraud_flag = 1 THEN 1 
            ELSE 0 
        END) AS fraud_transactions,

    SUM(CASE 
            WHEN fraud_flag = 0 THEN 1 
            ELSE 0 
        END) AS genuine_transactions,

    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / NULLIF(COUNT(*), 0),
    2) AS fraud_rate_percentage,

    SUM(CASE 
            WHEN fraud_flag = 1 THEN transaction_amount 
            ELSE 0 
        END) AS total_fraud_loss,

    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END) * 100.0)
        / NULLIF(SUM(transaction_amount), 0),
    2) AS fraud_amount_percentage

FROM risk_fraud_dataset;

---View Trend Analysis
CREATE VIEW vw_Fraud_Trend_Daily AS
SELECT
    CAST(transaction_date AS DATE) AS fraud_date,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY CAST(transaction_date AS DATE);

CREATE VIEW vw_Fraud_Trend_Monthly AS
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
    DATENAME(MONTH, transaction_date);

--Fraud By Hour
CREATE VIEW vw_Fraud_By_Hour AS
SELECT
    DATEPART(HOUR, transaction_date) AS hour_of_day,
    COUNT(*) AS fraud_transactions
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY DATEPART(HOUR, transaction_date);

--view for Bussiness vs NOnbussiness
CREATE VIEW vw_Fraud_Business_vs_NonBusiness AS
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

--view of recent risk
CREATE VIEW vw_Recent_Risk_Patterns AS
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

---3.Transaction amount and type analysis views
CREATE VIEW vw_Fraud_Transaction_Amount_Type_Analysis AS

/* 1️⃣ Fraud Rate by Transaction Type */
SELECT
    'Fraud Rate by Transaction Type' AS analysis_type,
    transaction_type AS category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage,
    NULL AS fraud_loss_amount,
    NULL AS avg_transaction_amount
FROM risk_fraud_dataset
GROUP BY transaction_type

UNION ALL

/* 2️⃣ Fraud Loss by Transaction Type */
SELECT
    'Fraud Loss by Transaction Type' AS analysis_type,
    transaction_type AS category,
    NULL AS total_transactions,
    NULL AS fraud_transactions,
    NULL AS fraud_rate_percentage,
    SUM(transaction_amount) AS fraud_loss_amount,
    NULL AS avg_transaction_amount
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY transaction_type

UNION ALL

/* 3️⃣ Fraud by Transaction Value Category */
SELECT
    'Fraud by Transaction Value Category' AS analysis_type,
    CASE
        WHEN transaction_amount < 100 THEN 'Low Value'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium Value'
        ELSE 'High Value'
    END AS category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage,
    NULL AS fraud_loss_amount,
    NULL AS avg_transaction_amount
FROM risk_fraud_dataset
GROUP BY
    CASE
        WHEN transaction_amount < 100 THEN 'Low Value'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium Value'
        ELSE 'High Value'
    END

UNION ALL

/* 4️⃣ Average Transaction Amount – Fraud vs Non-Fraud */
SELECT
    'Average Transaction Amount by Fraud Status' AS analysis_type,
    CASE
        WHEN fraud_flag = 1 THEN 'Fraud'
        ELSE 'Non-Fraud'
    END AS category,
    COUNT(*) AS total_transactions,
    NULL AS fraud_transactions,
    NULL AS fraud_rate_percentage,
    NULL AS fraud_loss_amount,
    AVG(transaction_amount) AS avg_transaction_amount
FROM risk_fraud_dataset
GROUP BY fraud_flag

UNION ALL

/* 5️⃣ Fraud Testing – Small Value Transactions */
SELECT
    'Fraud Testing (Small Value Transactions)' AS analysis_type,
    CASE
        WHEN transaction_amount < 50 THEN 'Very Small'
        WHEN transaction_amount BETWEEN 50 AND 100 THEN 'Small'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'Large'
    END AS category,
    COUNT(*) AS total_transactions,
    COUNT(*) AS fraud_transactions,
    NULL AS fraud_rate_percentage,
    NULL AS fraud_loss_amount,
    AVG(transaction_amount) AS avg_transaction_amount
FROM risk_fraud_dataset
WHERE fraud_flag = 1
GROUP BY
    CASE
        WHEN transaction_amount < 50 THEN 'Very Small'
        WHEN transaction_amount BETWEEN 50 AND 100 THEN 'Small'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'Large'
    END;

CREATE VIEW vw_Customer_Risk_Analysis AS
SELECT
    customer_id,

    COUNT(transaction_id) AS total_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END) AS total_fraud_amount,

    CASE
        WHEN SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) >= 3 THEN 'High Risk'
        WHEN SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) = 2 THEN 'Medium Risk'
        WHEN SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) = 1 THEN 'Low Risk'
        ELSE 'No Fraud'
    END AS derived_customer_risk_level,

    CASE
        WHEN SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) > 1 THEN 1
        ELSE 0
    END AS repeat_fraud_offender_flag

FROM risk_fraud_dataset
GROUP BY customer_id;

CREATE VIEW vw_Channel_Based_Fraud_Analysis AS
SELECT
    device_type AS channel,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,

    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage,

    SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END)
        AS total_fraud_loss,

    AVG(CASE WHEN fraud_flag = 1 THEN transaction_amount END)
        AS avg_fraud_transaction_amount

FROM risk_fraud_dataset
GROUP BY device_type;


CREATE VIEW vw_Geographic_Fraud_Analysis AS
SELECT
    location,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,

    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage,

    SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END)
        AS total_fraud_loss,

    AVG(CASE WHEN fraud_flag = 1 THEN transaction_amount END)
        AS avg_fraud_transaction_amount

FROM risk_fraud_dataset
GROUP BY location;


CREATE VIEW vw_Operational_Business_Impact_Analysis AS
SELECT
    device_type,
    transaction_type,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,

    ROUND(
        (SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*),
    2) AS fraud_rate_percentage,

    SUM(CASE WHEN fraud_flag = 1 THEN transaction_amount ELSE 0 END)
        AS fraud_loss_amount,

    SUM(CASE
        WHEN fraud_flag = 0 AND transaction_amount > 500
        THEN transaction_amount
        ELSE 0
    END) AS potential_false_positive_loss

FROM risk_fraud_dataset
GROUP BY device_type, transaction_type;








