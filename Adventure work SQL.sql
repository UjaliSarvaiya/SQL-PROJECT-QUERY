use adventure_work;
select Unitprice from sales;
select orders from sales;
-- ============================================================
-- DASHBOARD KPIs: Total Sales, Total Profit (in Millions),
-- Total Orders, Profit Margin %, Total Quantity
-- ============================================================
SELECT
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) / 1000000, 2) AS TotalSales_Millions,
    ROUND(
        (SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
         - SUM(s.ProductStandardCost * s.OrderQuantity)) / 1000000
    , 2) AS TotalProfit_Millions,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders,
    ROUND(
        (SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
         - SUM(s.ProductStandardCost * s.OrderQuantity))
        / SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) * 100
    , 2) AS ProfitMarginPct,
    SUM(s.OrderQuantity) AS TotalQuantity
FROM sales AS s;


-- ============================================================
-- Q1. Product Name for each sale
-- ============================================================
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    p.EnglishProductName AS ProductName
FROM sales AS s
LEFT JOIN DimProduct AS p
    ON s.ProductKey = p.ProductKey;


-- ============================================================
-- Q2. Customer Full Name + Product List Price for each sale
-- ============================================================
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.ListPrice AS ProductListPrice
FROM sales AS s
LEFT JOIN DimCustomer AS c ON s.CustomerKey = c.CustomerKey
LEFT JOIN DimProduct  AS p ON s.ProductKey  = p.ProductKey;


-- ============================================================
-- Q3. Date fields for each sale
-- ============================================================
SELECT
    s.OrderDateKey,
    d.CalendarYear        AS Year,
    d.MonthNumberOfYear    AS MonthNo,
    d.EnglishMonthName     AS MonthName,
    CONCAT('Q', d.CalendarQuarter) AS Quarter,
    DATE_FORMAT(d.FullDateAlternateKey, '%Y-%b') AS YearMonth,
    d.DayNumberOfWeek      AS WeekdayNo,
    d.EnglishDayNameOfWeek AS WeekdayName,
    d.FiscalQuarter        AS FinancialQuarter
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey;


-- ============================================================
-- Q4. Sales Amount per order line
-- ============================================================
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    ROUND(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct), 2) AS SalesAmount
FROM sales AS s;


-- ============================================================
-- Q5. Production Cost per order line
-- ============================================================
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    ROUND(s.ProductStandardCost * s.OrderQuantity, 2) AS ProductionCost
FROM sales AS s;


-- ============================================================
-- Q6. Profit per order line
-- ============================================================
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    ROUND(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct), 2)
        - ROUND(s.ProductStandardCost * s.OrderQuantity, 2) AS Profit
FROM sales AS s;


-- ============================================================
-- Q7. Month-wise Total Sales (pick a year by editing WHERE)
-- ============================================================
SELECT
    d.MonthNumberOfYear AS MonthNo,
    d.EnglishMonthName  AS MonthName,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
WHERE d.CalendarYear = 2014     -- change year here
GROUP BY d.MonthNumberOfYear, d.EnglishMonthName
ORDER BY d.MonthNumberOfYear;


-- ============================================================
-- Q8. Year-wise Total Sales
-- ============================================================
SELECT
    d.CalendarYear AS Year,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;


-- ============================================================
-- Q9. Month-wise Total Sales (all years, chart data)
-- ============================================================
SELECT
    DATE_FORMAT(d.FullDateAlternateKey, '%Y-%b') AS YearMonth,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
GROUP BY YearMonth, d.CalendarYear, d.MonthNumberOfYear
ORDER BY d.CalendarYear, d.MonthNumberOfYear;


-- ============================================================
-- Q10. Quarter-wise Total Sales
-- ============================================================
SELECT
    CONCAT('Q', d.CalendarQuarter) AS Quarter,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarQuarter
ORDER BY d.CalendarQuarter;


-- ============================================================
-- Q11. Month-wise Total Sales AND Total Production Cost (combo chart data)
-- ============================================================
SELECT
    DATE_FORMAT(d.FullDateAlternateKey, '%Y-%b') AS YearMonth,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales,
    ROUND(SUM(s.ProductStandardCost * s.OrderQuantity), 2) AS TotalProductionCost
FROM sales AS s
LEFT JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
GROUP BY YearMonth, d.CalendarYear, d.MonthNumberOfYear
ORDER BY d.CalendarYear, d.MonthNumberOfYear;


-- ============================================================
-- Q12a. Total Sales, Total Profit, Profit Margin % — by Product
-- ============================================================
SELECT
    p.EnglishProductName AS ProductName,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
          - SUM(s.ProductStandardCost * s.OrderQuantity), 2) AS TotalProfit,
    ROUND(
        (SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
         - SUM(s.ProductStandardCost * s.OrderQuantity))
        / SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) * 100
    , 2) AS ProfitMarginPct
FROM sales AS s
LEFT JOIN DimProduct AS p ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC;


-- ============================================================
-- Q12b. Total Sales, Total Profit, Profit Margin % — by Customer
-- ============================================================
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    COUNT(DISTINCT s.SalesOrderNumber) AS OrderCount,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
          - SUM(s.ProductStandardCost * s.OrderQuantity), 2) AS TotalProfit,
    ROUND(
        (SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
         - SUM(s.ProductStandardCost * s.OrderQuantity))
        / SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) * 100
    , 2) AS ProfitMarginPct
FROM sales AS s
LEFT JOIN DimCustomer AS c ON s.CustomerKey = c.CustomerKey
GROUP BY CustomerFullName
ORDER BY TotalSales DESC;


-- ============================================================
-- Q12c. Total Sales, Total Profit, Profit Margin % — by Region
-- ============================================================
SELECT
    t.SalesTerritoryRegion AS Region,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)), 2) AS TotalSales,
    ROUND(SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
          - SUM(s.ProductStandardCost * s.OrderQuantity), 2) AS TotalProfit,
    ROUND(
        (SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct))
         - SUM(s.ProductStandardCost * s.OrderQuantity))
        / SUM(s.UnitPrice * s.OrderQuantity * (1 - s.UnitPriceDiscountPct)) * 100
    , 2) AS ProfitMarginPct
FROM sales AS s
LEFT JOIN DimSalesTerritory AS t ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY Region
ORDER BY TotalSales DESC;


