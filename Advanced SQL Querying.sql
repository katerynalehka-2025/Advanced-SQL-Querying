USE maven_advanced_sql;

-- 1. Find products that have never been ordered
-- Using LEFT JOIN and filtering NULLs to identify products without matching orders
SELECT p.product_id,product_name,o.product_id AS productid_in_order
FROM products p LEFT JOIN orders o
ON p.product_id = o.product_id
WHERE o.product_id IS NULL;

-- 2. Find pairs of products with very similar prices
-- Self-join on products table to compare prices between different products
-- Filters product pairs where the absolute price difference is less than 0.25
SELECT p1.product_name,p1.unit_price,p2.product_name,p2.unit_price, p1.unit_price-p2.unit_price AS price_diff
FROM products p1 LEFT JOIN products p2
ON p1.product_id <> p2.product_id
WHERE ABS(p1.unit_price-p2.unit_price) <0.25;

-- 3. Calculate the average unit price across all products
SELECT AVG(unit_price)
FROM products;

-- 4. Show each product price compared to the overall average price
-- Uses a scalar subquery to calculate the average price
SELECT product_id, 
	product_name,
    unit_price,
    unit_price - (SELECT AVG(unit_price) FROM products) AS difference_from_average
FROM products
ORDER BY unit_price DESC;

-- 5. Count how many products each factory produces
SELECT factory, COUNT(product_id) AS count
FROM products
GROUP BY factory;

-- 6. Attach factory-level product counts to individual products
-- Demonstrates usage of multiple CTEs for modular query design
with c AS (SELECT factory, COUNT(product_id) AS countt
				FROM products
				GROUP BY factory),
	 p AS (SELECT factory, product_name 
				FROM products)
SELECT p.factory, c.countt, p.product_name
FROM p INNER JOIN  c
ON p.factory = c.factory
ORDER BY p.factory;


-- 7. Find products cheaper than all products from a specific factory
-- Uses ALL operator with a subquery
SELECT *
FROM products
WHERE unit_price < ALL(SELECT unit_price FROM products WHERE factory = "Wicked Choccy's");

-- 8. Inspect raw data from orders table
SELECT *
FROM orders;
-- Inspect raw data from products table
SELECT *
FROM products;

-- 9. Count orders with total value greater than 200
-- First calculates order totals, then counts qualifying orders
WITH oandp AS (SELECT o.order_id, SUM(units*unit_price) AS price_of_orders
				FROM orders o
				INNER JOIN products p
				ON o.product_id = p.product_id
                GROUP BY o.order_id
                HAVING price_of_orders > 200)
           
SELECT COUNT(*)
FROM oandp;

-- 10. Assign sequential transaction numbers per customer
-- Uses ROW_NUMBER window function
SELECT customer_id, order_id, order_date, transaction_id, 
	ROW_NUMBER () OVER (partition by customer_id ORDER BY customer_id) AS transaction_number
FROM orders;

-- 11. Rank products inside each order by quantity ordered
-- Uses DENSE_RANK to allow ties
SELECT order_id, product_id, units, 
	dense_rank () OVER (partition by order_id ORDER BY units DESC) AS ranking
FROM orders;

-- 12. Find the second most ordered product (by units) in each order
WITH pop AS (SELECT order_id, product_id, units,
				ROW_NUMBER() OVER(partition by order_id order by units desc) AS popularity
				FROM orders)
SELECT *
FROM pop
WHERE popularity = 2;

-- 13. Compare order quantities with previous orders per customer
-- Uses LAG to access previous row values
WITH prev AS (SELECT customer_id, order_id, SUM(units) AS sum_of_units,
				LAG (sum_of_units) OVER (partition by customer_id ORDER BY order_date) as prev_units
				FROM orders
                GROUP BY customer_id, order_id
				ORDER BY customer_id)
                
SELECT customer_id, order_id, sum_of_units, prev_units, prev_units - units AS difference_in_units
FROM prev;

-- 14. Segment customers into spending percentiles
-- NTILE(100) used for percentile-based segmentation
WITH sp AS (SELECT customer_id, SUM(units*unit_price) AS spent
			FROM orders o 
			INNER JOIN products p 
			ON o.product_id = p.product_id
			GROUP BY customer_id)
SELECT customer_id, spent,
NTILE (100) OVER (ORDER BY spent DESC) AS spend_pct
FROM sp;

-- 15. Group customers into rounded spending bins (by tens)
-- Useful for histogram-style analysis
WITH checkk AS (SELECT o.customer_id, FLOOR(SUM(o.units * p.unit_price)/10)*10 AS total_spend_bin
				FROM orders o 
				INNER JOIN products p 
				ON  o.product_id = p.product_id
				GROUP BY o.customer_id)
SELECT COUNT(customer_id) AS number_of_cusrtomers, total_spend_bin
FROM checkk
GROUP BY total_spend_bin
ORDER BY total_spend_bin;

-- 16. Calculate shipping date and filter orders from Q2 2024
SELECT order_id, order_date, date_add(order_date, interval 2 DAY) AS ship_date
FROM orders
WHERE QUARTER(order_date)=2 AND YEAR(order_date) = 2024;

-- 17. Create a composite identifier using string functions
SELECT product_id, factory,
CONCAT(REPLACE(factory, " ", "-"), "-", product_id) AS combined
FROM products;

-- 18. Clean product names using conditional logic and string functions
SELECT product_name,
CASE
	WHEN product_name LIKE "%Wonka Bar%" THEN SUBSTR(product_name, INSTR(product_name,"-")+2) 
    ELSE product_name END AS new_product_name
FROM products;

-- 19. Assign top-performing division per factory
-- Uses DENSE_RANK and COALESCE to fill missing divisions
WITH A AS (SELECT factory, division, number_of_products,
			DENSE_RANK() OVER(partition by factory ORDER BY number_of_products DESC) AS rankk
			FROM (SELECT factory, division, count(product_name) AS number_of_products
					FROM products
					GROUP BY factory, division) AS nod
			WHERE division IS NOT NULL),
 B AS (SELECT division, factory
		FROM A 
        WHERE rankk = 1)
        
SELECT p.product_name, p.factory, p.division,
COALESCE(p.division, B.division) AS division_top
FROM products p
LEFT JOIN B
ON p.factory = B.factory;

-- 20. Detect duplicate student records using different grouping strategies
SELECT id, student_name, email, COUNT(*)
FROM students
GROUP BY id, student_name, email
HAVING COUNT(*)>1; -- no dublicates

SELECT id, student_name, COUNT(*)
FROM students
GROUP BY id, student_name
HAVING COUNT(*)>1; -- no dublicates

SELECT student_name, email, COUNT(*)
FROM students
GROUP BY email, student_name
HAVING COUNT(*)>1; -- no dublicates

SELECT id, email, COUNT(*)
FROM students
GROUP BY email, id
HAVING COUNT(*)>1; -- no dublicates

SELECT student_name, COUNT(*)
FROM students
GROUP BY student_name
HAVING COUNT(*)>1; -- Noah Scott

SELECT * 
FROM students
WHERE student_name LIKE "%Noah Scott%"; -- it's really dublicate

-- 21. Remove duplicate students and find each student's top grade
WITH A AS (SELECT id, student_name, email, row_number() OVER(partition by student_name ORDER BY id) AS rownumber
			FROM students),
     B AS (SELECT *
FROM A 
WHERE rownumber = 1), -- removed dublicate value
	C	AS (SELECT B.id, B.student_name, final_grade, class_name, dense_rank() OVER (partition by student_name ORDER BY final_grade DESC) AS ranking
			FROM student_grades g INNER JOIN B
			ON g.student_id = B.id)
SELECT id, student_name, final_grade AS top_grade, class_name 
FROM C 
WHERE ranking = 1; -- top grade with class name

-- 22. Calculate average grades by department and grade level
SELECT department, 
ROUND(AVG(CASE WHEN grade_level = 9 THEN final_grade ELSE NULL END)) AS freshman,
ROUND(AVG(CASE WHEN grade_level = 10 THEN final_grade ELSE NULL END)) AS sophomore,
ROUND(AVG(CASE WHEN grade_level = 11 THEN final_grade ELSE NULL END)) AS junior,
ROUND(AVG(CASE WHEN grade_level = 12 THEN final_grade ELSE NULL END)) AS senior
FROM student_grades g INNER JOIN students s 
ON g.student_id = s.id
GROUP BY department
ORDER BY department;

-- 23. Monthly sales analysis with cumulative sum and moving average
WITH tbl AS (SELECT YEAR(order_date) AS yr, MONTH(order_date) AS mnth, SUM(units*unit_price) AS total_sales
				FROM orders o
				INNER JOIN products p 
				ON o.product_id = p.product_id
				GROUP BY YEAR(order_date), MONTH(order_date))
SELECT yr, mnth, total_sales, 
		SUM(total_sales)OVER(ORDER BY yr,mnth) AS cumluative_sum,
        AVG(total_sales)OVER(ORDER BY yr,mnth ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS six_month_ma
FROM tbl
