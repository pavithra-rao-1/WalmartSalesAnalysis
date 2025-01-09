/*
--Add a new column named time_of_day--

ALTER TABLE WalmartData ADD Time_of_day VARCHAR(20);

update WalmartData set Time_of_day = case 
	when Time between '05:00:00' and '12:00:00' then 'Morning'
	when Time between '12:00:01' and '16:00:00' then 'Afternoon'
	when Time between '16:00:01' and '20:00:00' then 'Evening' 
	else 'Night' end
*/


/*
--Add a new column named day_name--

ALTER TABLE WalmartData ADD Day_Name VARCHAR(20);

update WalmartData set Day_Name = DATENAME(WEEKDAY,Date) from WalmartData;
*/


/*
--Add a new column named day_name--

ALTER TABLE WalmartData ADD Month_Name VARCHAR(20);

update WalmartData set Month_Name = FORMAT(Date,'MMMM');
*/


select * from WalmartData;

-------------------------------------Generic Question------------------------------------------

--1. How many unique cities does the data have?
select distinct city from WalmartData;


--2. In which city is each branch?
select city, branch from WalmartData group by City, Branch;


------------------------------------------Product--------------------------------------------

--1. How many unique product lines does the data have?
select DISTINCT(product_line) from WalmartData;


--2. What is the most common payment method?
select top 1 Payment, COUNT(*) Count from WalmartData group by Payment order by Count desc;


--3. What is the most selling product line?
select top 1 Product_line, COUNT(*) Count from WalmartData group by Product_line order by Count desc;


--4. What is the total revenue by month?
select Month_Name, sum(Total) Total_Revenue from WalmartData group by Month_Name order by Month_Name;


--5. What month had the largest COGS?
select top 1 SUM(cogs) Total_cogs, Month_Name from WalmartData group by Month_Name order by Total_cogs desc;


--6. What product line had the largest revenue?
select top 1 Product_line, SUM(Total) Total_Revenue from WalmartData group by Product_line order by Total_Revenue desc;


--7. What is the city with the largest revenue?
select top 1 City, sum(Total) Total_Revenue from WalmartData group by City order by Total_Revenue desc;


--8. What product line had the largest VAT? ($ VAT = 5% * COGS $)
select Product_line, sum(cogs) cogs, (5.0*cogs/100) VAT from WalmartData group by Product_line, cogs order by VAT desc;


--9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
with sales as (select Product_line, AVG(Total) avg_sales from WalmartData group by Product_line)
select wd.Invoice_ID, wd.Product_line, wd.Total, s.avg_sales,
case when Total>avg_sales then 'Good' else 'Bad' end as Remark
from sales s join WalmartData wd on s.Product_line = wd.Product_line
order by Invoice_ID;

ALTER TABLE WalmartData ADD Remark varchar(10);

DECLARE @AvgTotal FLOAT;
SELECT @AvgTotal = AVG(Total) FROM WalmartData;
UPDATE WalmartData SET Remark = CASE WHEN Total>@AvgTotal then 'Good' else 'Bad' end


--10. Which branch sold more products than average product sold?
select Branch, SUM(Quantity) Qnty, AVG(Quantity)
from WalmartData 
group by Branch 
having SUM(Quantity) > AVG(Quantity) 
order by Qnty desc;


--11. What is the most common product line by gender?
WITH RankedProducts AS (SELECT 
        Product_line, 
        Gender, 
        COUNT(Product_line) AS Count,
        ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY COUNT(Product_line) DESC) AS RowNum
    FROM WalmartData
    GROUP BY Gender, Product_line)
SELECT 
    Gender, 
    Product_line, 
    Count
FROM RankedProducts
WHERE RowNum = 1
ORDER BY Gender;


--12. What is the average rating of each product line?
SELECT Product_line, CAST(AVG(Rating)AS decimal(10,2)) AVG_RATING FROM WalmartData GROUP BY Product_line;

------------------------------------------Sales--------------------------------------------

--1. Number of sales made in each time of the day per weekday
SELECT COUNT(*) Count, Time_of_day FROM WalmartData GROUP BY Time_of_day;


--2. Which of the customer types brings the most revenue?
SELECT Customer_type, SUM(Total) Total_Revenue FROM WalmartData GROUP BY Customer_type ORDER BY TOTAL_REVENUE DESC;


--3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT TOP 1 City, CAST(AVG(Tax_5) AS decimal(10,2)) VAT FROM WalmartData GROUP BY City ORDER BY VAT DESC;


--4. Which customer type pays the most in VAT?
SELECT TOP 1 Customer_type, CAST(AVG(Tax_5) AS decimal(10,2)) VAT FROM WalmartData GROUP BY Customer_type ORDER BY VAT DESC;

------------------------------------------Customer--------------------------------------------

select * from WalmartData;

--1. How many unique customer types does the data have?
SELECT DISTINCT Customer_type FROM WalmartData;


--2. How many unique payment methods does the data have?
SELECT COUNT(DISTINCT Payment) No_of_Payment_Methods FROM WalmartData;


--3. What is the most common customer type?
SELECT TOP 1 Customer_type, COUNT(*) AS Count FROM WalmartData GROUP BY Customer_type ORDER BY Count DESC;


--4. Which customer type buys the most?
SELECT TOP 1 Customer_type, SUM(Quantity) AS Total_Quantity FROM WalmartData GROUP BY Customer_type ORDER BY Total_Quantity DESC;


--1. What is the gender of most of the customers?
SELECT TOP 1 Gender, COUNT(*) AS Count
FROM WalmartData
GROUP BY Gender
ORDER BY Count DESC;


--2. What is the gender distribution per branch?
SELECT Branch, Gender, COUNT(*) AS Count
FROM WalmartData
GROUP BY Branch, Gender
ORDER BY Branch, Count DESC;


--3. Which time of the day do customers give most ratings?
SELECT TOP 1 Time_of_day, COUNT(Rating) AS Rating_Count
FROM WalmartData
GROUP BY Time_of_day
ORDER BY Rating_Count DESC;


--4. Which time of the day do customers give most ratings per branch?
SELECT Branch, Time_of_day, COUNT(Rating) AS Rating_Count
FROM WalmartData
GROUP BY Branch, Time_of_day
ORDER BY Branch, Rating_Count DESC;


--5. Which day of the week has the best average ratings?
SELECT TOP 1 Day_Name, CAST(AVG(Rating) AS DECIMAL(10, 2)) AS Avg_Rating
FROM WalmartData
GROUP BY Day_Name
ORDER BY Avg_Rating DESC;


--6. Which day of the week has the best average ratings per branch?
SELECT Branch, Day_Name, CAST(AVG(Rating) AS DECIMAL(10, 2)) AS Avg_Rating
FROM WalmartData
GROUP BY Branch, Day_Name
ORDER BY Branch, Avg_Rating DESC;