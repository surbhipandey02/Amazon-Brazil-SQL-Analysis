# Amazon-Brazil-SQL-Analysis
PostgreSQL data analysis project using Amazon Brazil's e-commerce dataset to generate business insights and strategic recommendations for Amazon India's market expansion.

📊 Amazon Brazil Market Analysis using PostgreSQL
Project Overview

This project analyzes Amazon Brazil's e-commerce data using PostgreSQL to uncover customer behavior, sales trends, payment preferences, product performance, and seller insights.
The objective is to generate business recommendations that can help Amazon India understand customer preferences and make data-driven decisions while expanding its market presence.

🎯 Business Problem

Amazon has successfully expanded across multiple countries, including Brazil. Since Brazil and India share several market characteristics—such as large populations and diverse customer bases—this project analyzes Amazon Brazil's data to identify strategies that could support Amazon India's growth.
The analysis focuses on customer behavior, payment methods, product demand, seasonal trends, and revenue patterns to derive actionable business insights.

🗂 Database Schema
The database contains six interconnected tables:

Customers
Orders
Order Items
Products
Sellers
Payments
The schema enables end-to-end analysis of the e-commerce lifecycle, from customer purchases and payments to product and seller performance.

🛠 Technologies Used
PostgreSQL
SQL
pgAdmin
Joins
Aggregate Functions
Subqueries
Common Table Expressions (CTEs)
Recursive CTEs
Temporary Tables
Window Functions
Date Functions
Ranking Functions
Excel (Data Export & Charts)

📚 SQL Concepts Covered

This project demonstrates practical use of:

INNER JOIN
LEFT JOIN
GROUP BY
HAVING
ORDER BY
CASE WHEN
Aggregate Functions
Subqueries
Common Table Expressions (CTEs)
Recursive CTEs
Temporary Tables
Window Functions
RANK()
DENSE_RANK()
ROW_NUMBER()
Date Functions
String Functions
Standard Deviation
Data Cleaning

📊 Project Objectives

The analysis answers several real-world business questions, including:

What are the most popular payment methods?
Which months generate the highest revenue?
Which product categories contribute the most sales?
Who are the most valuable customers?
How can customers be segmented based on loyalty?
Which products perform above average?
What are the seasonal sales trends?
Which payment methods show the highest growth?
How consistent are transaction values across payment methods?
Which product categories have the highest price variation?

📈 Business Questions Answered

This project includes 25+ SQL business case studies, such as:

Payment Analysis

Average payment value by payment type
Percentage of orders by payment type
Payment consistency using standard deviation
Month-over-month payment growth

Product Analysis

Top revenue-generating categories
Products with above-average sales
Smart products within a target price range
Categories with high price variation
Missing product categories

Customer Analysis

Repeat customers
Customer segmentation
Loyalty segmentation
Top customers by average order value

Sales Analysis

Monthly revenue trends
Top sales months
Seasonal sales analysis
Monthly cumulative sales
