# Risk-and-Fraud-Detection-Analysis
🔍 Risk & Fraud Detection Analysis | SQL Server + Power BI

📌 Project Overview

This project focuses on analyzing risk and fraud patterns in financial transactions using SQL Server and Power BI.

The goal is to identify fraud trends, high-risk customers, risky channels, geographic hotspots, and assess the operational and business impact of fraud.

The project is designed using real-world data modeling practices, including a Star Schema, SQL Views, and Power BI DirectQuery for scalable analytics.

________________________________________
🧠 Business Problem
Financial institutions face challenges such as:

•	Increasing fraud losses

•	Identifying high-risk customers and channels

•	Detecting fraud hotspots geographically

•	Balancing fraud prevention with customer experience (false positives)

This project helps stakeholders answer:

•	Where is fraud happening?

•	Who is committing fraud repeatedly?

•	Which channels and locations are riskiest?

•	Where should fraud teams prioritize investigations?
________________________________________
🗂 Dataset

Key Columns:

•	transaction_id

•	customer_id

•	transaction_date

•	transaction_amount

•	transaction_type

•	device_type

•	location

•	fraud_flag
________________________________________
🏗 Data Modeling Approach

⭐ Star Schema (Industry Standard)

Fact Table

•	vw_Fact_Fraud_Transactions (transaction-level data)

Dimension Tables

•	Dim_Date

•	Dim_Channel

•	Dim_TransactionType

•	Dim_Location

•	Dim_Customer

This structure enables:

•	High performance with DirectQuery

•	Proper visual interaction in Power BI

•	Scalable and maintainable analytics
________________________________________
🔎 Analysis Performed

1️⃣ Fraud KPIs

•	Total transactions

•	Fraud vs legitimate transactions

•	Fraud rate (%)

•	Total fraud loss

•	Fraud loss as % of transaction value

2️⃣ Time-Based Analysis

•	Daily and monthly fraud trends

•	Fraud spikes by date

•	Business hours vs non-business hours fraud

3️⃣ Channel-Based Fraud Analysis

•	Fraud rate by channel (Online, ATM, POS, Mobile)

•	Fraud loss by channel

•	High-risk low-volume channels

•	Channel prioritization for fraud controls

4️⃣ Geographic Fraud Analysis

•	Locations with highest fraud count

•	Fraud loss by location

•	Fraud rate by geography

•	Identification of fraud hotspots

5️⃣ Customer Risk Analysis

•	Unique customers involved in fraud

•	Repeat fraud offenders

•	Derived customer risk levels (High / Medium / Low)

•	Percentage of repeat fraud customers

6️⃣ Operational & Business Impact

•	High-risk but legitimate transactions

•	Potential false-positive revenue loss

•	Risky combinations of channel + transaction type

•	Investigation prioritization strategy
________________________________________
📊 Power BI Dashboard

Key Features

•	DirectQuery connection to SQL Server

•	Interactive visuals using star schema

•	KPIs, bar charts, maps, trends, and tables

•	Slicers for date, channel, location, and transaction type
________________________________________
🛠 Tools & Technologies

•	SQL Server – Data storage, views, transformations

•	Power BI – Visualization & reporting

•	DirectQuery – Real-time analytics

•	SQL Views – Fact & dimension modeling
________________________________________
📈 Key Insights

•	Online and mobile channels show higher fraud rates

•	Certain locations emerge as consistent fraud hotspots

•	A small group of customers account for repeat fraud

•	High-value transactions contribute disproportionately to fraud loss

•	Derived risk metrics help prioritize investigations efficiently
________________________________________
🚀 Conclusion

This project demonstrates how SQL + Power BI can be used in a real-world fraud analytics scenario to support data-driven decision-making, operational efficiency, and risk mitigation.
________________________________________
📌 Author

S. Sai Vamshidhar

Aspiring Data Analyst | SQL | Power BI | Data Analytics
