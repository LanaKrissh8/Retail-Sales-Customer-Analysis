CREATE DATABASE RETAIL_SALES;
drop database retail_sales;
USE RETAIL_SALES;
select * from superstores;
show databases;
SELECT * FROM SUPERSTORES LIMIT 2;

-- FIND TOTAL CUSTOMERS
SELECT COUNT(DISTINCT Customer_Name) AS Total_Customers
FROM superstores;

-- TOP 10 CUSTOMERS BY SALES
SELECT Customer_Name,
       ROUND(SUM(Sales),2) AS Total_Sales
FROM superstores
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- TOP10 CUSTOMERS BY PROFIT
SELECT Customer_Name,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstores
GROUP BY Customer_Name
ORDER BY Total_Profit DESC
LIMIT 10;

-- CUSTOMER GENERATING LOSS
SELECT Customer_Name,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstores
GROUP BY Customer_Name
HAVING Total_Profit < 0
ORDER BY Total_Profit;

-- CUSTOMER ORDER FREQUENCY / REPEATED CUSTOMERS
SELECT Customer_Name,
       COUNT(DISTINCT Order_ID) AS Total_Orders
FROM superstores
GROUP BY Customer_Name
ORDER BY Total_Orders DESC
LIMIT 10;

-- AVERAGE ORDER VALUE PER CUSTOMER
SELECT Customer_Name,
       ROUND(SUM(Sales)/COUNT(DISTINCT Order_ID),2) AS Avg_Order_Value
FROM superstores
GROUP BY Customer_Name
ORDER BY Avg_Order_Value DESC
LIMIT 10;

-- CUSTOMER SALES BY REGION
SELECT Region,
       COUNT(DISTINCT Customer_Name) AS Customer_Count,
       ROUND(SUM(Sales),2) AS Total_Sales
FROM superstores
GROUP BY Region
ORDER BY Total_Sales DESC;

-- CUSTOMER LIFETIME VALUE
SELECT Customer_Name,
       ROUND(SUM(Sales),2) AS Customer_Lifetime_Value
FROM superstores
GROUP BY Customer_Name
ORDER BY Customer_Lifetime_Value DESC;

-- CHECK LATEST ORDER DATE
SELECT MAX(Order_Date) AS Latest_Date
FROM superstores;

-- INDUSTRY LEVEL RFM SEGMENTATION

-- CREATE RFM BASE TABLE
WITH rfm AS (
    SELECT 
        Customer_Name,

        -- Recency
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM superstores),
            MAX(Order_Date)
        ) AS Recency,

        -- Frequency
        COUNT(DISTINCT Order_ID) AS Frequency,

        -- Monetary
        ROUND(SUM(Sales),2) AS Monetary

    FROM superstores
    GROUP BY Customer_Name
)
SELECT * FROM rfm;

-- ASSIGN RFM SCORES (1 TO 5) USING NTILE FUNCTION
WITH rfm AS (
    SELECT 
        Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM superstores),
            MAX(Order_Date)
        ) AS Recency,
        COUNT(DISTINCT Order_ID) AS Frequency,
        SUM(Sales) AS Monetary
    FROM superstores
    GROUP BY Customer_Name
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM rfm
)

SELECT * FROM rfm_scores;

-- CREATE CUSTOMER LABELS
WITH rfm AS (
    SELECT 
        Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM superstores),
            MAX(Order_Date)
        ) AS Recency,
        COUNT(DISTINCT Order_ID) AS Frequency,
        SUM(Sales) AS Monetary
    FROM superstores
    GROUP BY Customer_Name
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM rfm
)

SELECT *,
    CASE 
        WHEN R_Score = 5 AND F_Score = 5 AND M_Score = 5 
            THEN 'Champions'

        WHEN R_Score >= 4 AND F_Score >= 4 
            THEN 'Loyal Customers'

        WHEN R_Score = 5 AND F_Score <= 2 
            THEN 'New Customers'

        WHEN R_Score <= 2 AND F_Score >= 3 
            THEN 'At Risk'

        WHEN R_Score = 1 AND F_Score = 1 
            THEN 'Lost Customers'

        ELSE 'Others'
    END AS Customer_Segment

FROM rfm_scores
ORDER BY Customer_Segment;

-- COUNT CUSTOMERS IN EACH SEGMENTATION 
WITH rfm AS (
    SELECT 
        Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM superstores),
            MAX(Order_Date)
        ) AS Recency,
        COUNT(DISTINCT Order_ID) AS Frequency,
        SUM(Sales) AS Monetary
    FROM superstores
    GROUP BY Customer_Name
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM rfm
),

segments AS (
    SELECT *,
        CASE 
            WHEN R_Score = 5 AND F_Score = 5 AND M_Score = 5 
                THEN 'Champions'
            WHEN R_Score >= 4 AND F_Score >= 4 
                THEN 'Loyal Customers'
            WHEN R_Score = 5 AND F_Score <= 2 
                THEN 'New Customers'
            WHEN R_Score <= 2 AND F_Score >= 3 
                THEN 'At Risk'
            WHEN R_Score = 1 AND F_Score = 1 
                THEN 'Lost Customers'
            ELSE 'Others'
        END AS Customer_Segment
    FROM rfm_scores
)

SELECT 
    Customer_Segment,
    COUNT(*) AS Total_Customers
FROM segments
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;


-- Clean the datas
SELECT *
FROM superstores
WHERE Order_Date IS NOT NULL;

-- Customer Summary Views
CREATE VIEW customer_summary AS
SELECT 
    Customer_Name,
    COUNT(Order_ID) AS total_orders,
    SUM(Sales) AS total_sales,
    MAX(Order_Date) AS last_purchase
FROM superstores
GROUP BY Customer_Name
order by total_sales desc;

-- Displaying the Summary
select * from customer_summary;

