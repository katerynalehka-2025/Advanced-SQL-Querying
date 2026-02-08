# Advanced-SQL-Querying
Advanced SQL project covering joins, subqueries, CTEs, window functions, ranking, time-based analysis, and data cleaning.
Project overview

This project is a collection of advanced SQL queries developed while completing the Maven Analytics Advanced SQL course. Although the tasks were part of a guided curriculum, all solutions were written independently, based solely on the task requirements and expected results — without watching or following the official solution videos.
The focus of the project was to strengthen analytical thinking and SQL problem-solving skills by translating business-style questions into efficient, readable SQL queries.

Key objectives

The main goals of this project were to:

Practice advanced SQL concepts in realistic scenarios
Solve analytical problems independently rather than replicating solutions
Improve query structure, clarity, and logical reasoning
Gain confidence working with complex SQL features used in analytics roles

Concepts & techniques covered

Data exploration & joins

Identifying products with no orders using LEFT JOIN and NULL filtering
Comparing products using self-joins
Attaching aggregated metrics back to detail-level records

Subqueries & filtering

Scalar subqueries for benchmarking against averages
ALL operator for comparative price analysis
Multi-step filtering using HAVING

CTEs & modular query design

Breaking complex logic into reusable query blocks
Using multiple CTEs to improve readability and maintainability

Window functions

ROW_NUMBER, DENSE_RANK, NTILE
Ranking products within orders
Assigning transaction sequences per customer
Customer segmentation by spending percentiles

Time-based & trend analysis

Monthly sales aggregation
Cumulative sums
Moving averages
Quarter and year filtering
Derived date calculations (shipping dates)

Data cleaning & transformation

String manipulation with CONCAT, REPLACE, SUBSTR, INSTR
Conditional logic using CASE
Handling missing values with COALESCE
Identifying and removing duplicate records

Example analytical questions solved

Which products have never been ordered?
Which products have very similar prices?
How do individual product prices compare to the overall average?
Which orders exceed a given total value threshold?
How does customer purchasing behavior change over time?
Who are the top-performing customers and products?
How can raw transactional data be transformed into trend-level insights?

Skills demonstrated

Advanced SQL query writing
Analytical problem-solving
Window functions and ranking logic
Query optimization through CTEs
Data cleaning and preparation
Translating business questions into SQL logic
