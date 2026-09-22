
--1.Write a query to display every sales order along with the corresponding customer name, 
--  product name, and quantity purchased.

		SELECT S.ORDER_NUMBER,C.NAME,P.PRODUCT_NAME,S.QUANTITY FROM SALES AS S
		INNER JOIN 
		CUSTOMERS AS C 
			ON S.CUSTOMERKEY = C.CUSTOMERKEY
		INNER JOIN
		PRODUCTS AS P
			ON S.PRODUCTKEY = P.PRODUCTKEY

--2.Write a query to display, for every sale, the customer name, customer country, product name, 
--  product category, and quantity sold.

			SELECT C.NAME,C.[Country],P.[Product_Name],P.[Category],S.[Quantity] FROM SALES AS S
			INNER JOIN 
			CUSTOMERS AS C
				ON S.CUSTOMERKEY = C.CUSTOMERKEY
			INNER JOIN
			PRODUCTS AS P
				ON S.PRODUCTKEY = P.PRODUCTKEY 

--3. Write a query to calculate the total quantity sold for each combination of store country and product category.

		SELECT C.COUNTRY,P.CATEGORY,SUM(S.QUANTITY) AS TOTAL_QTY_SOLD FROM SALES AS S
		INNER JOIN 
		STORES AS C
			ON C.STOREKEY = S.STOREKEY
		INNER JOIN
		PRODUCTS AS P
			ON P.PRODUCTKEY = S.PRODUCTKEY
		GROUP BY 
			C.COUNTRY,P.CATEGORY

--4. Write a query to calculate the total sales revenue (in USD) generated across all orders
	SELECT 
		SUM(P.[Unit_Price_USD] * S.[Quantity] / ER.[Exchange] ) AS TOTAL_SALES_REVENUE_USD
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
			ON S.PRODUCTKEY = P.PRODUCTKEY
		INNER JOIN
		EXCHANGE_RATES AS ER
			ON ER.CURRENCY = S.CURRENCY_CODE AND S.ORDER_DATE = ER.SQL_DATE_FORMAT

--5. Write a query to calculate total sales converted into each order's local currency, using the exchange rate
--   matched by currency code and order date.

		SELECT S.[Order_Number], S.[Currency_Code],(P.[Unit_Price_USD]*S.[Quantity] * ER.[Exchange]) AS LOCAL_SSALES 
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
			ON S.PRODUCTKEY = P.PRODUCTKEY
		INNER JOIN
		EXCHANGE_RATES AS ER
			ON S.CURRENCY_CODE = ER.CURRENCY AND S.[Order_Date] = ER.[Sql_Date_Format]

--6. Write a query to display, for each order, the total sales in both USD and the local currency side by side.

		SELECT S.[Order_Number],(P.[Unit_Price_USD]*S.[Quantity]) AS USD_TOTAL_SALES,(P.[Unit_Price_USD]*S.[Quantity] * ER.[Exchange]) AS LOCAL_SSALES 
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
			ON S.PRODUCTKEY = P.PRODUCTKEY
		INNER JOIN
		EXCHANGE_RATES AS ER
			ON S.CURRENCY_CODE = ER.CURRENCY AND S.[Order_Date] = ER.[Sql_Date_Format]


--7. : Assume the Sales table stores the order amount in local currency.
--   Write a query to convert this local currency amount into USD for each order using the applicable exchange rate.

		Local Amount = USD Amount * Exchange
		USD Amount = Local Amount / Exchange


		SELECT S.ORDER_NUMBER,(P.[Unit_Price_USD]*S.QUANTITY)/ER.[Exchange]AS USD	FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
			ON S.PRODUCTKEY = P.PRODUCTKEY
		INNER JOIN
		EXCHANGE_RATES AS ER
			ON S.CURRENCY_CODE = ER.CURRENCY AND S.[Order_Date] = ER.[Sql_Date_Format]

--8. Write a query to identify the top 10 customers ranked by total sales revenue.
		
		SELECT TOP 10 C.[Name],SUM((P.[Unit_Price_USD]*S.QUANTITY)) AS TOTAL_SALES_REVENUE
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
		ON S.[ProductKey] = P.[ProductKey]
		INNER JOIN
		CUSTOMERS AS C
		ON C.[CustomerKey] = S.[CustomerKey]
		GROUP BY C.NAME
		ORDER BY TOTAL_SALES_REVENUE DESC


--9. Write a query to find the best-selling product (by revenue) within each product category.
--Expected Output (Columns):Output Column-Category-Product Name-Sales-RN


		WITH ProductSales AS
		(
			SELECT
				P.Category,
				P.Product_Name,
				SUM(P.Unit_Price_USD * S.Quantity) AS Sales
			FROM Sales AS S
			INNER JOIN Products AS P
				ON S.ProductKey = P.ProductKey
			GROUP BY
				P.Category,
				P.Product_Name
		),
		RankedProducts AS
		(
			SELECT
				Category,
				Product_Name,
				Sales,
				ROW_NUMBER() OVER
				(
					PARTITION BY Category
					ORDER BY Sales DESC
				) AS RN
			FROM ProductSales
		)
		SELECT
			Category,
			Product_Name,
			Sales,
			RN
		FROM RankedProducts
		WHERE RN = 1;


--10. Write a query to calculate the number of days taken to deliver each order, along with the customer name.

	SELECT S.[Order_Number],
	ISNULL(DATEDIFF(DD,[Order_Date],[Delivery_Date]),0) AS DELIVERY_DAYS,
	C.NAME FROM SALES AS S
	INNER JOIN
	CUSTOMERS AS C
	ON S.CUSTOMERKEY = C.CUSTOMERKEY

--11. Write a query to calculate the average order delivery time (in days) for each customer country

	SELECT C.[Country],
	AVG(DATEDIFF(DD,[Order_Date],[Delivery_Date])) AS AVG_DELIVERY_DAYS
	FROM SALES AS S
	INNER JOIN 
	CUSTOMERS AS C
	ON S.CUSTOMERKEY =C.CUSTOMERKEY
	WHERE S.DELIVERY_DATE IS NOT NULL
	GROUP BY C.COUNTRY

--12. Write a query to identify the top 5 product brands ranked by total revenue.

		WITH CTE AS
		(
		SELECT P.[Brand],SUM(P.[Unit_Price_USD]*S.[Quantity]) AS TOTAL_REVENUE FROM SALES AS S
		INNER JOIN PRODUCTS AS P
		ON S.ProductKey = P.ProductKey
		GROUP BY P.BRAND
		),
		TEXT AS
		(
		SELECT BRAND ,TOTAL_REVENUE,
		RANK()OVER(ORDER BY TOTAL_REVENUE DESC) AS BRAND_RANK
		FROM CTE
		)
		SELECT *FROM TEXT
		WHERE BRAND_RANK <= 5
		ORDER BY BRAND_RANK

		----------------
		SELECT TOP 5 P.BRAND,SUM(P.[Unit_Price_USD]*S.[Quantity])AS TOTAL_REVENUE
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
		ON S.ProductKey = P.ProductKey
		GROUP BY P.BRAND
		ORDER BY TOTAL_REVENUE DESC

--13. Write a query to identify the single store that has generated the highest total revenue

		WITH CTE AS 
		(
		SELECT ST.STOREKEY,SUM(P.[Unit_Price_USD]*S.[Quantity])AS TOTAL_REVENUE
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
		ON P.ProductKey = S.ProductKey
		INNER JOIN
		STORES AS ST
		ON ST.StoreKey = S.StoreKey
		WHERE S.STOREKEY IS NOT NULL
		GROUP BY ST.STOREKEY
		)
		SELECT STOREKEY ,TOTAL_REVENUE
		FROM (
		SELECT *,RANK()OVER(ORDER BY TOTAL_REVENUE DESC) AS RN
		FROM CTE ) AS X
		WHERE RN =1

--14. Write a query to calculate the total profit generated by each product category.
		
		SELECT P.[Category],SUM(P.[Unit_Price_USD]*S.[Quantity])AS TOTAL_REVENUE
		FROM SALES AS S
		INNER JOIN
		PRODUCTS AS P
		ON S.PRODUCTKEY = P.PRODUCTKEY
		GROUP BY P.CATEGORY
		ORDER BY TOTAL_REVENUE DESC

--15. Write a query to calculate the total profit generated by customers in each country.

		SELECT C.[Country], SUM(P.[Unit_Price_USD]*S.[Quantity]) AS PROFIT
		FROM SALES AS S 
		INNER JOIN
		PRODUCTS AS P
		ON S.ProductKey = P.ProductKey
		INNER JOIN
		CUSTOMERS AS C
		ON S.CUSTOMERKEY = C.CUSTOMERKEY
		GROUP BY C.COUNTRY
		ORDER BY PROFIT DESC

--16. Write a query to identify the top 3 best-selling products (by revenue) within each product category,
--    using a ranking window function such as ROW_NUMBER(), RANK(), or DENSE_RANK().

	WITH CTE AS 
	(
	SELECT P.[Product_Name],P.[Category],SUM(P.[Unit_Price_USD]*S.[Quantity])AS TOTAL_REVENUE
	FROM SALES AS S
	INNER JOIN
	PRODUCTS AS P
	ON S.PRODUCTKEY = P.[ProductKey]
	GROUP BY P.CATEGORY,P.PRODUCT_NAME
	
	)
	SELECT PRODUCT_NAME,CATEGORY,TOTAL_REVENUE,RN FROM(
	SELECT *, DENSE_RANK()OVER(PARTITION BY CATEGORY ORDER BY TOTAL_REVENUE DESC) AS RN
	FROM CTE 
	) AS X
	WHERE RN <=3


--17. Write a query to calculate each customer's age at the time they placed each order.

	SELECT C.[Name],
	DATEDIFF(YYYY,C.[Birthday],S.[Order_Date])
	-CASE
		WHEN
		DATEADD(YYYY,DATEDIFF(YYYY,C.[Birthday],S.[Order_Date]),C.BIRTHDAY) > S.ORDER_DATE
		THEN 1
		ELSE 0
	END
		AS AGE
	FROM CUSTOMERS AS C
	INNER JOIN 
	SALES AS S
	ON C.CUSTOMERKEY = S.CUSTOMERKEY

--18. Write a query to identify customers who have made purchases from more than one store.

		
		SELECT C.NAME,COUNT(DISTINCT S.STOREKEY) FROM SALES AS S
		INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY 
		GROUP BY C.NAME
		HAVING COUNT(DISTINCT S.STOREKEY) > 1
	
--19. Write a query to calculate total revenue generated by each store, grouped by store country and state.

	SELECT C.COUNTRY, C.STATE, SUM(P.[Unit_Price_USD] * S.[Quantity]) AS TOTAL_REVENUE
	FROM  SALES AS S
	INNER JOIN 
	PRODUCTS AS P 
	ON S.PRODUCTKEY = P.PRODUCTKEY
	INNER JOIN 
	CUSTOMERS AS C
	ON C.CUSTOMERKEY = S.CUSTOMERKEY
	GROUP BY C.COUNTRY,C.STATE


--20. : Write a query to calculate total revenue generated on each continent.

	SELECT C.CONTINENT, SUM(P.[Unit_Price_USD] * S.[Quantity]) AS TOTAL_REVENUE
	FROM SALES AS S
	INNER JOIN 
	PRODUCTS AS P
	ON P.PRODUCTKEY = S.PRODUCTKEY
	INNER JOIN
	CUSTOMERS AS C
	ON C.CUSTOMERKEY = S.CUSTOMERKEY
	GROUP BY C.CONTINENT

--21. : Write a query to identify repeat customers, i.e., customers who have placed more than one order.


	SELECT C.NAME,COUNT(DISTINCT S.ORDER_NUMBER) AS TOTAL_ORDERS
	FROM CUSTOMERS AS C
	INNER JOIN
	SALES AS S
	ON S.CustomerKey = C.CustomerKey
	GROUP BY
	C.NAME
	HAVING COUNT(DISTINCT S.ORDER_NUMBER) > 1

--22. Write a query to identify customers who have purchased products from more than one product category.

		SELECT C.NAME ,count(distinct p.[Category]) as category_purchased from sales as s
		inner join
		customers as c 
		on c.CustomerKey = s.CustomerKey
		inner join 
		products as p
		on p.productkey = s.productkey
		group by c.name
		having count(distinct p.category) > 1



--23. Write a query to calculate total monthly sales revenue for each country.

		SELECT YEAR(S.[Order_Date])AS SALE_YEAR, MONTH(S.[Order_Date])AS SALE_MONTH, C.COUNTRY,
		SUM(P.[Unit_Price_USD]* S.[Quantity]) AS SALES_USD FROM SALES AS S
		JOIN
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		JOIN
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		WHERE (S.[Order_Date]) IS NOT NULL
		GROUP BY YEAR(S.[Order_Date]),MONTH(S.[Order_Date]),C.COUNTRY
		ORDER BY YEAR(S.[Order_Date]),MONTH(S.[Order_Date]),C.COUNTRY DESC





--24.: Write a query to identify the top-selling product (by quantity) in each country.

		WITH CTE AS 
		(
	SELECT P.Product_Name,C.COUNTRY,SUM(S.[Quantity]) AS TOT_QTY,
	DENSE_RANK() OVER (PARTITION BY C.COUNTRY ORDER BY SUM(S.QUANTITY) DESC) AS RN_
	FROM SALES S 
	INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		INNER JOIN 
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		GROUP BY P.[Product_Name],C.COUNTRY
	)
		SELECT [Product_Name],COUNTRY,TOT_QTY FROM CTE 
		WHERE RN_ = 1
		
	
--25. Write a query to calculate revenue, cost, profit, profit percentage, and revenue in local currency for each country.
	
--Country-RevenueUSD-CostUSD-ProfitUSD-ProfitPercentage-RevenueLocalCurrency

		SELECT ST.[Country],SUM(P.[Unit_Price_USD] * S.[Quantity]) AS REVENUE_USD,
		SUM(P.[Unit_Cost_USD]* S.[Quantity]) AS COST_USD, 
		SUM((P.[Unit_Price_USD] - P.[Unit_Cost_USD])*S.[Quantity]) AS PROFIT,
		(
		SUM((P.[Unit_Price_USD] - P.[Unit_Cost_USD])*S.[Quantity])*100.0/SUM(P.[Unit_Price_USD]*S.[Quantity])) AS PROFIT_PERCENTAGE,
		SUM((P.[Unit_Price_USD]*S.[Quantity])* ER.[Exchange]) AS LOCAL_REVENUE
		FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P 
		ON P.PRODUCTKEY = S.ProductKey
		INNER JOIN
		STORES AS ST
		ON ST.STOREKEY = S.STOREKEY
		INNER JOIN
		EXCHANGE_RATES AS ER
		ON ER.[Currency] = S.[Currency_Code] AND S.[Order_Date] = ER.[Sql_Date_Format]
		GROUP BY ST.COUNTRY
		ORDER BY ST.COUNTRY

--26. The marketing team wants to identify high-value customers for a loyalty program. 
--Write a query to display each customer's name, country, total number of orders,
--total quantity purchased, and total sales in USD, sorted by highest sales.


		SELECT C.[Name],C.[Country],COUNT(DISTINCT S.[Order_Number]) AS TOT_ORDERS,
		SUM(S.[Quantity])AS TOT_QTY,
		SUM(P.[Unit_Price_USD] * S.[Quantity]) AS TOT_SALES_USD
		FROM SALES AS S
		INNER JOIN
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		INNER JOIN
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		GROUP BY C.NAME, C.COUNTRY
		ORDER BY SUM(P.[Unit_Price_USD] * S.[Quantity]) DESC

--27. : The procurement department wants to identify products with the highest profit contribution. Write a query to display product name,
--brand, revenue, cost, and profit, sorted by profit in descending order.

		SELECT P.[Product_Name],P.[Brand],SUM(P.[Unit_Price_USD]*S.[Quantity]) AS REVENUE,
		SUM(P.[Unit_Cost_USD] )AS COST, 
		SUM((P.[Unit_Price_USD] - P.[Unit_Cost_USD])*S.[Quantity])*100 /SUM(P.[Unit_Price_USD]*S.[Quantity]) AS PROFIT
		FROM SALES AS S
		INNER JOIN
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		GROUP BY P.PRODUCT_NAME,P.BRAND
		ORDER BY PROFIT DESC

--28. Management wants to know which stores are generating the highest sales. 
--Write a query to display total revenue for every store along with store country,state, and store size (square meters).

		SELECT SUM(P.[Unit_Price_USD]*S.[Quantity]) AS REVUNUE,
		ST.COUNTRY,ST.[State],ST.[Square_Meters] FROM SALES AS S
		INNER JOIN 
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		INNER JOIN 
		STORES AS ST
		ON ST.STOREKEY = S.STOREKEY
		GROUP BY ST.COUNTRY,ST.[State],ST.[Square_Meters]

--29. : The CEO wants to identify the best-selling product category in each country. Write a query to display 
--the top-selling category (by revenue) for every customer country.

		SELECT C.COUNTRY ,P.[Category],
		SUM(P.[Unit_Price_USD] * S.[Quantity]) AS REVENUE
		FROM SALES AS S
		INNER JOIN
		PRODUCTS AS P 
		ON P.PRODUCTKEY = S.PRODUCTKEY 
		INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		GROUP BY C.COUNTRY, P.CATEGORY
		ORDER BY REVENUE DESC

--30. : Finance wants to calculate revenue in each customer's local currency. Write a query to display order number,
--customer name, currency code, revenue in USD, and revenue in local currency.


		SELECT S.[Order_Number],C.NAME,S.[Currency_Code],
		SUM([Unit_Price_USD] * S.[Quantity]) AS REVENUE,
		SUM(([Unit_Price_USD] * S.[Quantity])*ER.EXCHANGE) AS LOCAL_REVENUE
		FROM SALES AS S 
		INNER JOIN 
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		INNER JOIN
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		INNER JOIN 
		EXCHANGE_RATES AS ER
		ON ER.[Currency] = S.[Currency_Code] AND ER.[Sql_Date_Format] = S.[Order_Date]
		GROUP BY C.NAME,S.CURRENCY_CODE,S.[Order_Number]
		ORDER BY REVENUE,LOCAL_REVENUE DESC


--31. : Write a query to find customers who have purchased products from at least three different brands.


		SELECT C.NAME, COUNT(DISTINCT P.[Brand]) AS BRAND
		FROM SALES AS S
		INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		INNER JOIN PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		GROUP BY C.NAME
		HAVING COUNT(DISTINCT P.[Brand]) >= 3

--32. Write a query to calculate the average order value for each country.

		SELECT C.COUNTRY, 
		AVG(P.[Unit_Price_USD]*S.[Quantity]) AS AVG_ORDER_VALUE
		FROM SALES AS S
		INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		INNER JOIN 
		PRODUCTS AS P
		ON P.PRODUCTKEY = S.PRODUCTKEY
		GROUP BY C.COUNTRY

--33. : Write a query to find the oldest customer (by birthday) who has placed at least one order.
		

		SELECT TOP 1 C.NAME,C.COUNTRY,
		C.BIRTHDAY
		FROM SALES AS S
		INNER JOIN 
		CUSTOMERS AS C
		ON C.CUSTOMERKEY = S.CUSTOMERKEY
		ORDER BY C.BIRTHDAY ASC
		
--34. Write a query to display yearly revenue for each product category

		select year(s.[Order_Date])as year_ ,p.category,sum((p.[Unit_Price_USD]*s.[Quantity]))as yearly_revenue
		from sales as s
		inner join
		products as p 
		on p.ProductKey = s.ProductKey
		where s.order_date is not null
		group by p.category,year(s.order_date)
		order by p.category, year_

--35. : Write a query to identify products that have never been sold.

		select s.productkey, p.product_name from sales as s
		inner join 
		products as p
		on p.productkey = s.productkey
		where s.productkey is null

--36. Write a query to identify stores that have never processed an order.
		
		select st.storekey, st.country,st.state from stores as st
		left join
		sales as s
		on st.storekey = s.storekey
		where s.storekey  is null

--37. : Write a query to display monthly revenue for each product brand.

		select month(s.order_date)as month_,p.brand, sum(p.[Unit_Price_USD]*s.[Quantity]) as revenue
		from sales as s
		inner join 
		products as p
		on p.productkey = s.productkey
		where month(s.order_date) is not null
		group by month(s.order_date), p.brand
		order by month_ ,p.brand

--38. Write a query to identify customers whose total spending exceeds the overall average customer spending.

		with customer_spendings as
		(
		select s.customerkey,sum(p.[Unit_Price_USD]*s.[Quantity]) as total_spending
		from sales as s
		inner join
		products as p
		on p.productkey = s.productkey
		group by s.customerkey
		)
		select customerkey,total_spending from customer_spendings 
		where total_spending > (select avg (total_spending) from customer_spendings)

--39. Write a query to rank all stores based on their total revenue.
		
		
		select st.storekey, st.country,sum(p.[Unit_Price_USD]*s.[Quantity]) as revenue,
		dense_rank()over(order by sum(p.[Unit_Price_USD]*s.[Quantity]) desc) as rank_
		from stores as st
		join
		sales as s 
		on st.storekey = s.storekey
		join 
		products as p
		on p.productkey = s.productkey
		where s.storekey is not null
		group by st.country,st.storekey
		order by revenue desc

--40. Write a query to calculate each customer's percentage contribution to total company revenue.

		with cte as
		(
		select s.customerkey,sum(p.[Unit_Price_USD]*s.[Quantity]) as customer_revenue
		from sales as s
		inner join
		products as p
		on p.productkey = s.productkey
		group by s.customerkey
		)
		select customerkey, customer_revenue,
		customer_revenue * 100.00/ sum(customer_revenue)over() as contribution_percentage
		from  cte
		order by contribution_percentage desc


--41. : The Operations Manager wants to identify which stores consistently deliver ordersthe fastest. 
--Write a query to display store key, country, state, total orders,and average delivery days, sorted by the fastest delivery time. 

		select s.storekey, st.country,st.state,count(s.[Order_Number]) as total_orders,
		avg(datediff(day ,s.[Order_Date], s.[Delivery_Date])) as avg_delivery_days
		from sales as s
		inner join 
		stores as st
		on st.storekey = s.storekey
		
		group by st.country,st.state,s.storekey
		order by avg_delivery_days desc


--42. Management wants to investigate stores with poor delivery performance. Write a query to display the 
--top 5 stores with the highest average delivery days.

		select top 5 s.storekey,st.country,st.state,
		avg(datediff(day,s.[Order_Date],s.[Delivery_Date])) as avg_delivery_days
		from sales as s
		inner join
		stores as st
		on st.storekey = s.storekey
		group by s.storekey,st.country,st.state
		order by avg_delivery_days desc

--43. Finance wants to know which product categories generate the highest profit margin. Write a query to
--display category, revenue, cost, profit,and profit percentage, sorted by profit percentage in descending order.

		select p.category,sum(p.[Unit_Price_USD]*s.[Quantity]) as revenue,
		sum(p.[Unit_Cost_USD]*s.[Quantity]) as cost,sum((p.[Unit_Price_USD]-p.[Unit_Cost_USD])*s.[Quantity]) as profit,
		sum((p.[Unit_Price_USD]-p.[Unit_Cost_USD])*s.[Quantity])*100.00/sum((p.[Unit_Price_USD] * s.Quantity)) as profit_percentage
		from sales as s
		inner join 
		products as p
		on p.productkey = s.productkey
		group by p.category
		order by profit_percentage desc


--44. Marketing wants to know which brands dominate each country. Write a query to display the top 5 brands 
--(by revenue) within each country, along with their rank.

		select top 5 p.brand,c.country,sum(p.[Unit_Price_USD]* s.[Quantity]) as revenue,
		dense_rank()over(partition by c.country order by sum(p.[Unit_Price_USD]* s.[Quantity]) desc ) as rank_
		from sales as s
		inner join
		products as p
		on p.ProductKey = s.ProductKey
		inner join
		customers as c
		on c.CustomerKey = s.CustomerKey
		group by p.brand,c.country
		order by revenue desc

--45. The CFO wants to track cumulative revenue throughout the year. Write a query to display year, month,
--monthly revenue, and running (cumulative) revenue.

		with monthlyrevenue as
		(
		select 
		year(s.order_date)as year_,
		month(s.order_date) as month_,
		sum(p.[Unit_Price_USD]*s.[Quantity]) as monthly_revenue
		from sales as s
		inner join 
		products as p
		on p.ProductKey = s.ProductKey
		group by year(s.order_date),month(s.order_date)
		)

		select year_ ,month_,monthly_revenue,sum(monthly_revenue) over (partition by year_ order by month_ rows unbounded preceding)
		as cumulative_revenue
		from monthlyrevenue
		order by year_,month_


--46. Management wants to compare each month's revenue with the previous month. 
--Write a query to display year, month, current month revenue, previous month revenue, and month-over-month growth.

		with monthlyrevenue as
		(
		select 
		year(s.order_date)as year_,
		month(s.order_date) as month_,
		sum(p.[Unit_Price_USD]*s.[Quantity]) as current_monthly_revenue
		from sales as s
		inner join 
		products as p
		on p.ProductKey = s.ProductKey
		group by year(s.order_date),month(s.order_date)
		),
		previousmonth as 
		(
		select
		year_ ,month_,current_monthly_revenue,
		lag(current_monthly_revenue)over(partition by year_ order by month_)as previous_month_revenue
		from monthlyrevenue
		)
		select year_ ,month_,current_monthly_revenue,previous_month_revenue,
		(current_monthly_revenue-previous_month_revenue)*100.0/nullif(previous_month_revenue,0) as month_over_month_growth
		from previousmonth
		order by year_,
		month_ 

--47.: Write a query to find the highest-selling product color (by quantity) within each product category

		with colorsales as
		(
		select 
		p.category,
		p.color,
		sum(s.quantity) as total_quantity
		from sales as s
		inner join
		products as p
		on p.productkey = s.productkey
		group by p.category,p.color
		),
		rankedcolors as
		(
		select category,color,total_quantity,
		dense_rank()over(partition by category order by total_quantity desc) as rank_
		from colorsales
		)
		select category,color,total_quantity
		from rankedcolors
		where rank_ = 1
		order by category


--48. Write a query to identify customers who have made purchases in more than one store country
--(e.g., customers who travel and shop internationally).

		select c.name,s.customerkey
		from sales as s
		inner join
		stores as st
		on st.storekey = s.storekey
		inner join
		customers as c
		on c.customerkey = s.customerkey
		group by s.customerkey,c.name
		having count(distinct st.country)> 1

--49. Marketing wants age-wise revenue insights. Write a query to calculate total revenue by customer age group 
--(18-25, 26-35, 36-45, 46-60, 60+) at the time of purchase.

				WITH CustomerAge AS
		(
			SELECT
				s.CustomerKey,
				s.Order_Date,
				p.Unit_Price_USD,
				s.Quantity,

				DATEDIFF(YEAR, c.Birthday, s.Order_Date)
				- CASE
					WHEN DATEADD(
							YEAR,
							DATEDIFF(YEAR, c.Birthday, s.Order_Date),
							c.Birthday
						 ) > s.Order_Date
					THEN 1
					ELSE 0
				  END AS age
          
			FROM Sales AS s
			INNER JOIN Customers AS c
				ON c.CustomerKey = s.CustomerKey
			INNER JOIN Products AS p
				ON p.ProductKey = s.ProductKey
		)
		SELECT
			CASE
				WHEN age BETWEEN 18 AND 25 THEN '18-25'
				WHEN age BETWEEN 26 AND 35 THEN '26-35'
				WHEN age BETWEEN 36 AND 45 THEN '36-45'
				WHEN age BETWEEN 46 AND 60 THEN '46-60'
				WHEN age >= 61 THEN '60+'
			END AS age_group,

			SUM(Unit_Price_USD * Quantity) AS total_revenue

		FROM CustomerAge
		GROUP BY
			CASE
				WHEN age BETWEEN 18 AND 25 THEN '18-25'
				WHEN age BETWEEN 26 AND 35 THEN '26-35'
				WHEN age BETWEEN 36 AND 45 THEN '36-45'
				WHEN age BETWEEN 46 AND 60 THEN '46-60'
				WHEN age >= 61 THEN '60+'
			END

		order by
			case
			WHEN age BETWEEN 18 AND 25 THEN '18-25'
				WHEN age BETWEEN 26 AND 35 THEN '26-35'
				WHEN age BETWEEN 36 AND 45 THEN '36-45'
				WHEN age BETWEEN 46 AND 60 THEN '46-60'
				WHEN age >= 61 THEN '60+'
			end


--50. : The CEO requires a single query to power an executive dashboard. Write a query to return total revenue (USD),
--total cost (USD), total profit (USD), profit percentage, total orders, total customers, total products sold, 
--average order value, and total revenue in local currency.


		SELECT
    SUM(p.Unit_Price_USD * s.Quantity) AS total_revenue_USD,

    SUM(p.Unit_Cost_USD * s.Quantity) AS total_cost_USD,

    SUM((p.Unit_Price_USD - p.Unit_Cost_USD) * s.Quantity) AS total_profit_USD,

    SUM((p.Unit_Price_USD - p.Unit_Cost_USD) * s.Quantity) * 100.0
        / NULLIF(SUM(p.Unit_Price_USD * s.Quantity), 0) AS profit_percentage,

    COUNT(DISTINCT s.Order_Number) AS total_orders,

    COUNT(DISTINCT s.CustomerKey) AS total_customers,

    SUM(s.Quantity) AS total_products_sold,

    SUM(p.Unit_Price_USD * s.Quantity) * 1.0
        / NULLIF(COUNT(DISTINCT s.Order_Number), 0) AS average_order_value

FROM Sales AS s
INNER JOIN Products AS p
    ON p.ProductKey = s.ProductKey;