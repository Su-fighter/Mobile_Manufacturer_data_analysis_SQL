Q1--List all the states in which we have customers who have bought cellphones from 2005 till today.   
	
	SELECT DISTINCT State
	FROM DIM_LOCATION L, FACT_TRANSACTIONS F
	WHERE L.IDLocation=F.IDLocation
	AND YEAR(Date) between 2005 and getdate()



--Q1--END

--Q2--What state in the US is buying the most 'Samsung' cell phones? 
	
	
	  SELECT TOP 1 State
	  FROM DIM_LOCATION L
	  INNER JOIN FACT_TRANSACTIONS F
	  ON L.IDLocation=F.IDLocation
	  INNER JOIN DIM_MODEL M
	  ON F.IDModel=M.IDModel
	  INNER JOIN DIM_MANUFACTURER D
	  ON M.IDManufacturer=D.IDManufacturer
	  WHERE Country='US' AND Manufacturer_Name='SAMSUNG'
	  GROUP BY State
	  ORDER BY SUM(Quantity) DESC
	
--Q2--END

--Q3--Show the number of transactions for each model per zip code per state.      
	
	SELECT Model_Name, ZipCode, State, COUNT(TotalPrice) [NO. OF TRANSACTIONS]
	FROM DIM_MODEL M
	left JOIN FACT_TRANSACTIONS F
	ON M.IDModel=F.IDModel
	left JOIN DIM_LOCATION L
	ON F.IDLocation=L.IDLocation
	GROUP BY Model_Name, ZipCode, State


--Q3--END

--Q4-- Show the cheapest cellphone (Output should contain the price also) 
	
	SELECT TOP 1 Model_Name, Unit_price
	FROM DIM_MODEL 
	ORDER BY Unit_price 




--Q4--END

--Q5-- Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.

	SELECT Manufacturer_Name, Model_Name, SUM(TotalPrice)/SUM(Quantity) AS AVG_PRICE
	FROM DIM_MODEL M
	INNER JOIN FACT_TRANSACTIONS F
	ON M.IDModel=F.IDModel
	INNER JOIN DIM_MANUFACTURER R
	ON M.IDManufacturer=R.IDManufacturer
	WHERE M.IDManufacturer IN(
			SELECT TOP 5 IDManufacturer FROM DIM_MODEL D, FACT_TRANSACTIONS T
			WHERE D.IDModel=T.IDModel
			GROUP BY IDManufacturer
			ORDER BY SUM(Quantity) DESC)
	GROUP BY Manufacturer_Name, Model_Name 
	ORDER BY AVG_PRICE
	



--Q5--END

--Q6-- List the names of the customers and the average amount spent in 2009, where the average is higher than 500  

	SELECT Customer_Name, AVG(TotalPrice) AVG_AMOUNT
	FROM DIM_CUSTOMER C,FACT_TRANSACTIONS F
	WHERE C.IDCustomer=F.IDCustomer
	      AND YEAR(DATE)= 2009
	GROUP BY Customer_Name
	HAVING AVG(TotalPrice)>500
	


--Q6--END
	
--Q7--List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010    
	
	WITH YR2008
	AS(
	SELECT F.IDModel, Model_Name
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2008
	GROUP BY F.IDModel, Model_Name
	ORDER BY SUM(Quantity) DESC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY),
	YR2009
	AS(
	SELECT F.IDModel, Model_Name
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2009
	GROUP BY F.IDModel, Model_Name
	ORDER BY SUM(Quantity) DESC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY),
	YR2010
	AS(
	SELECT F.IDModel, Model_Name
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2010
	GROUP BY F.IDModel, Model_Name
	ORDER BY SUM(Quantity) DESC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY)
	SELECT * FROM YR2008
	INTERSECT
	SELECT * FROM YR2009
	INTERSECT
	SELECT * FROM YR2010
	
	--OR USING DENSE_RANK()
	/*WITH YR2008
	AS(
	SELECT IDModel, Model_Name FROM(SELECT M.IDModel, Model_Name, DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC ) AS RANKS 
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2008
	GROUP BY M.IDModel, Model_Name)X
	WHERE RANKS<=5
	),
	YR2009
	AS(
	SELECT IDModel, Model_Name FROM(SELECT M.IDModel, Model_Name, DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC ) AS RANKS 
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2009
	GROUP BY M.IDModel, Model_Name)X
	WHERE RANKS<=5
	),
	YR2010
	AS(
	SELECT IDModel, Model_Name FROM(SELECT M.IDModel, Model_Name, DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC ) AS RANKS 
	FROM FACT_TRANSACTIONS F, DIM_MODEL M
	WHERE F.IDModel=M.IDModel AND YEAR(Date)=2010
	GROUP BY M.IDModel, Model_Name)X
	WHERE RANKS<=5
	)
	SELECT * FROM YR2008
	INTERSECT
	SELECT * FROM YR2009
	INTERSECT
	SELECT * FROM YR2010
	*/


--Q7--END	
--Q8-- Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.   

	WITH T2009
	AS(
	SELECT M.IDManufacturer, Manufacturer_Name
	FROM FACT_TRANSACTIONS F
	JOIN DIM_MODEL M ON F.IDModel=M.IDModel
	JOIN DIM_MANUFACTURER D ON M.IDManufacturer=D.IDManufacturer
		AND YEAR(Date)= 2009
	GROUP BY M.IDManufacturer, Manufacturer_Name
	ORDER BY SUM(TotalPrice) DESC
	OFFSET 1 ROW FETCH NEXT 1 ROW ONLY),
	T2010
	AS(
	SELECT M.IDManufacturer, Manufacturer_Name
	FROM FACT_TRANSACTIONS F
	JOIN DIM_MODEL M ON F.IDModel=M.IDModel
	JOIN DIM_MANUFACTURER D ON M.IDManufacturer=D.IDManufacturer
		AND YEAR(Date)= 2010
	GROUP BY M.IDManufacturer, Manufacturer_Name
	ORDER BY SUM(TotalPrice) DESC
	OFFSET 1 ROW FETCH NEXT 1 ROW ONLY)
	SELECT * FROM T2009
	UNION
	SELECT * FROM T2010
	



--Q8--END
--Q9-- Show the manufacturers that sold cellphones in 2010 but did not in 2009.
	
	SELECT DISTINCT M.IDManufacturer, Manufacturer_Name
	FROM DIM_MODEL M JOIN FACT_TRANSACTIONS F
	ON M.IDModel=F.IDModel
	JOIN DIM_MANUFACTURER D ON M.IDManufacturer=D.IDManufacturer
	WHERE YEAR(DATE)=2010
	EXCEPT
	SELECT DISTINCT M.IDManufacturer, Manufacturer_Name
	FROM DIM_MODEL M JOIN FACT_TRANSACTIONS F
	ON M.IDModel=F.IDModel
	JOIN DIM_MANUFACTURER D ON M.IDManufacturer=D.IDManufacturer
	WHERE YEAR(DATE)=2009 




--Q9--END

--Q10-- Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend. 
	
	WITH TOPCUST
	AS(
	SELECT TOP 10 C.IDCustomer, Customer_Name, SUM(TotalPrice) [AMOUNT]
	FROM DIM_CUSTOMER C, FACT_TRANSACTIONS F
	WHERE C.IDCustomer=F.IDCustomer
	GROUP BY C.IDCustomer, Customer_Name
	ORDER BY AMOUNT DESC
	),
	YEARSPEND
	AS(
	SELECT T.IDCustomer, Customer_Name, YEAR(Date) YEARS, AVG(F.TotalPrice) AVG_PRICE, AVG(F.Quantity) AVG_QUANT
	FROM DIM_CUSTOMER T, FACT_TRANSACTIONS F
	WHERE T.IDCustomer=F.IDCustomer 
		AND T.IDCustomer IN(SELECT IDCustomer FROM TOPCUST)
	GROUP BY T.IDCustomer, Customer_Name, YEAR(Date)
	),
	YEARCHANGE
	AS(
	SELECT *, LAG(AVG_PRICE,1) OVER(PARTITION BY IDCUSTOMER ORDER BY YEARS) PREV_SPEND
	FROM YEARSPEND
	)
	SELECT *, ((AVG_PRICE-PREV_SPEND)/PREV_SPEND)*100 [% CHANGE OF SPEND]
	FROM YEARCHANGE

--Q10--END
	
