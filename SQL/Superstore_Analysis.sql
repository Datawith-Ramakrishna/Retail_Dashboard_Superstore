-- 1) Which region drives the most sales and profit?
SELECT Region,
       ROUND(SUM(Profit), 2) AS Profit,
       ROUND(SUM(Sales), 2)  AS Sales
FROM dbo.Superstore
GROUP BY Region
ORDER BY Profit DESC;

-- 2) Who are the top 10 customers by total spending?
SELECT TOP 10
       Customer_Name,
       ROUND(SUM(Sales), 2) AS TotalSpending
FROM dbo.Superstore
GROUP BY Customer_Name
ORDER BY TotalSpending DESC;

-- 3) What is the monthly sales trend, and is there growth over time?
WITH m AS (
  SELECT
    MonthStart    = CAST(DATEFROMPARTS(YEAR(Order_Date), MONTH(Order_Date), 1) AS date),
    Monthly_Sales = SUM(Sales)
  FROM dbo.Superstore
  GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT
  MonthStart,
  Monthly_Sales,
  Running_Total =
    SUM(Monthly_Sales) OVER (
      ORDER BY MonthStart
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
FROM m
ORDER BY MonthStart;

-- 4) Which product categories and sub-categories are the most profitable?
SELECT
  Category,
  Sub_Category,
  ROUND(SUM(Sales),  2) AS Sales,
  ROUND(SUM(Profit), 2) AS Profit,
  ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0), 4) AS MarginRatio
FROM dbo.Superstore
GROUP BY Category, Sub_Category
ORDER BY Profit DESC;

-- 5) Do discounts hurt profitability? (analyze profit by discount band)
WITH b AS (
  SELECT
    CASE
      WHEN Discount = 0       THEN '0%'
      WHEN Discount <= 0.10   THEN '0-10%'
      WHEN Discount <= 0.20   THEN '10-20%'
      WHEN Discount <= 0.30   THEN '20-30%'
      ELSE '>30%'
    END AS Discount_Band,
    Sales,
    Profit
  FROM dbo.Superstore
)
SELECT
  Discount_Band,
  ROUND(SUM(Sales),  2) AS Sales,
  ROUND(SUM(Profit), 2) AS Profit,
  ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0), 4) AS Margin_Ratio
FROM b
GROUP BY Discount_Band
ORDER BY
  CASE Discount_Band
    WHEN '0%'     THEN 1
    WHEN '0-10%'  THEN 2
    WHEN '10-20%' THEN 3
    WHEN '20-30%' THEN 4
    ELSE 5
  END;

-- 6) Which products generate the highest revenue and quantity sold?
SELECT TOP 20
  Product_Name,
  SUM(Quantity) AS Units_Sold,
  ROUND(SUM(Sales), 2) AS Revenue,
  RANK() OVER (ORDER BY SUM(Sales) DESC) AS Revenue_Rank
FROM dbo.Superstore
GROUP BY Product_Name
ORDER BY Revenue DESC;

-- 7) Which states are losing money (negative profit)?
SELECT
  State,
  ROUND(SUM(Profit), 2) AS Profit
FROM dbo.Superstore
GROUP BY State
HAVING SUM(Profit) < 0
ORDER BY Profit ASC;

-- 8) What share of customers are repeat vs one-time buyers?
WITH orders_per_c AS (
  SELECT
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS orders_cnt
  FROM dbo.Superstore
  GROUP BY Customer_Name
)
SELECT
  CASE
    WHEN orders_cnt = 1               THEN '1 order'
    WHEN orders_cnt BETWEEN 2 AND 3   THEN '2-3 orders'
    WHEN orders_cnt BETWEEN 4 AND 5   THEN '4-5 orders'
    ELSE '6+ orders'
  END AS Frequency_Band,
  COUNT(*) AS Customers
FROM orders_per_c
GROUP BY
  CASE
    WHEN orders_cnt = 1               THEN '1 order'
    WHEN orders_cnt BETWEEN 2 AND 3   THEN '2-3 orders'
    WHEN orders_cnt BETWEEN 4 AND 5   THEN '4-5 orders'
    ELSE '6+ orders'
  END
ORDER BY
  CASE
    WHEN MIN(orders_cnt) = 1               THEN 1
    WHEN MIN(orders_cnt) BETWEEN 2 AND 3   THEN 2
    WHEN MIN(orders_cnt) BETWEEN 4 AND 5   THEN 3
    ELSE 4
  END;

-- 9) Does shipping mode affect profitability?
SELECT
  Ship_Mode,
  ROUND(SUM(Profit), 2) AS Profit,
  COUNT(DISTINCT Order_ID) AS Orders
FROM dbo.Superstore
GROUP BY Ship_Mode
ORDER BY Profit DESC;

-- 10) What are the busiest weekdays and months?
SELECT
  YEAR(Order_Date)                  AS OrderYear,
  DATENAME(month,   Order_Date)     AS MonthName,
  DATENAME(weekday, Order_Date)     AS WeekdayName,
  ROUND(SUM(Sales), 2)              AS Total_Sales
FROM dbo.Superstore
GROUP BY
  YEAR(Order_Date),
  MONTH(Order_Date),
  DATENAME(month,   Order_Date),
  DATENAME(weekday, Order_Date),
  DATEPART(weekday, Order_Date)
ORDER BY
  YEAR(Order_Date),
  MONTH(Order_Date),
  DATEPART(weekday, Order_Date);

-- 11) Which customers contribute the most lifetime value?
SELECT TOP 10
  Customer_Name,
  ROUND(SUM(Sales),  2) AS Sales,
  ROUND(SUM(Profit), 2) AS Profit
FROM dbo.Superstore
GROUP BY Customer_Name
ORDER BY Profit DESC;

-- 12) Which specific products consistently cause losses?
SELECT
  Product_Name,
  ROUND(SUM(Profit), 2) AS Profit
FROM dbo.Superstore
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Profit ASC;  
