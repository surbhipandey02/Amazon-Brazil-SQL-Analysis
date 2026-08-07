CREATE SCHEMA amazon_brazil;

CREATE TABLE amazon_brazil.customer (
 customer_id VARCHAR PRIMARY KEY,
 customer_unique_id VARCHAR,
 customer_zip_code_prefix VARCHAR
);

CREATE TABLE amazon_brazil.orders (
 order_id VARCHAR PRIMARY KEY,
 customer_id VARCHAR REFERENCES amazon_brazil.customer(customer_id),
 order_status VARCHAR,
 order_purchase_timestamp TIMESTAMP,
 order_approved_at TIMESTAMP,
 order_delivered_carrier_date TIMESTAMP,
 order_delivered_customer_date TIMESTAMP,
 order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE amazon_brazil.order_items (
 order_id VARCHAR REFERENCES amazon_brazil.orders(order_id),
 order_item_id INT,
 product_id VARCHAR,
 seller_id VARCHAR,
 shipping_limit_date TIMESTAMP,
 price NUMERIC,
 freight_value NUMERIC,
 PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE amazon_brazil.products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE amazon_brazil.sellers (
  seller_id VARCHAR PRIMARY KEY,
  seller_zip_code_prefix VARCHAR
);

CREATE TABLE amazon_brazil.payments (
    order_id VARCHAR REFERENCES amazon_brazil.orders(order_id),
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value NUMERIC
);

SELECT * FROM amazon_brazil.customer LIMIT 5;

SELECT * FROM amazon_brazil.order_items LIMIT 5;

-- Analysis - I

-- To simplify its financial reports, Amazon India needs to standardize payment values.
-- Round the average payment values to integer (no decimal) for each payment type and display the results sorted in ascending order.
-- Output: payment_type, rounded_avg_payment
-- Q1: Round average payment values per payment type.

SELECT
 payment_type,
 ROUND(AVG(payment_value)) AS rounded_avg_payment
 FROM amazon_brazil.payments
 GROUP BY payment_type
 ORDER BY rounded_avg_payment ASC;

-- To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type.
-- Calculate the percentage of total orders for each payment type, rounded to one decimal place, and display them in descending order
-- Output: payment_type, percentage_orders
-- Q2: Percentage of orders by payment type.

SELECT
  payment_type,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage_orders
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY percentage_orders DESC;
 
-- Amazon India seeks to create targeted promotions for products within specific price ranges.
-- Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name.
-- Display these products, sorted by price in descending order.
-- Output: product_id, price
-- Q3: Products priced 100-500 BRL with 'Smart' in name.

SELECT 
    oi.product_id,
    p.product_category_name,
    oi.price
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.products p ON oi.product_id = p.product_id
WHERE oi.price BETWEEN 100 AND 500
AND p.product_category_name ILIKE '%smart%'
ORDER BY oi.price DESC;

-- To identify seasonal sales patterns, Amazon India needs to focus on the most successful months.
-- Determine the top 3 months with the highest total sales value, rounded to the nearest integer.
-- Output: month, total_sales
-- Q4: Top 3 months with highest total sales.

SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month,
    ROUND(SUM(oi.price)) AS total_sales
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'Month'),
         EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY SUM(oi.price) DESC
LIMIT 3;

-- Amazon India is interested in product categories with significant price variations.
-- Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.
-- Output: product_category_name, price_difference
-- Q5: Categories with price difference > 500 BRL.

SELECT 
    p.product_category_name,
    MAX(oi.price) - MIN(oi.price) AS price_difference
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING MAX(oi.price) - MIN(oi.price) > 500;

-- To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts.
-- Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.
-- Output: payment_type, std_deviation
-- Q6: Payment types ranked by smallest standard deviation.

SELECT 
    payment_type,
    ROUND(STDDEV(payment_value)::NUMERIC, 2) AS std_deviation
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY std_deviation ASC;

-- Amazon India wants to identify products that may have incomplete name in order to fix it from their end.
-- Retrieve the list of products where the product category name is missing or contains only a single character.
-- Output: product_id, product_category_name
-- Q7: Products with missing or single-character category name.

SELECT 
    product_id,
    product_category_name
FROM amazon_brazil.products
WHERE product_category_name IS NULL
   OR LENGTH(TRIM(product_category_name)) <= 1;

-- Analysis - II

-- Amazon India wants to understand which payment types are most popular across different order value segments (e.g., low, medium, high).
-- Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL.
-- Calculate the count of each payment type within these ranges and display the results in descending order of count
-- Output: order_value_segment, payment_type, count
-- Q1: Payment types across order value segments.

SELECT 
    CASE 
        WHEN p.payment_value < 200 THEN 'Low (<200)'
        WHEN p.payment_value BETWEEN 200 AND 1000 THEN 'Medium (200-1000)'
        ELSE 'High (>1000)'
    END AS order_value_segment,
    p.payment_type,
    COUNT(*) AS count
FROM amazon_brazil.payments p
GROUP BY order_value_segment, p.payment_type
ORDER BY count DESC;

-- Amazon India wants to analyse the price range and average price for each product category.
-- Calculate the minimum, maximum, and average price for each category, and list them in descending order by the average price.
-- Output: product_category_name, min_price, max_price, avg_price
-- Q2: Min, max, avg price per product category.

SELECT 
    p.product_category_name,
    ROUND(MIN(oi.price), 2) AS min_price,
    ROUND(MAX(oi.price), 2) AS max_price,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC;

-- Amazon India wants to identify the customers who have placed multiple orders over time.
-- Find all customers with more than one order, and display their customer unique IDs along with the total number of orders they have placed.
-- Output: customer_unique_id, total_orders
-- Q3: Customers with more than 1 order.

SELECT 
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customer c
JOIN amazon_brazil.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Amazon India wants to categorize customers into different types ('New – order qty. = 1' ;  'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4) based on their purchase history.
-- Use a temporary table to define these categories and join it with the customers table to update and display the customer types.
-- Output: customer_unique_id, customer_type
-- Q4: Customer type segmentation using temp table.

CREATE TEMP TABLE customer_order_counts AS
SELECT 
    c.customer_unique_id,
    COUNT(o.order_id) AS order_count
FROM amazon_brazil.customer c
JOIN amazon_brazil.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

SELECT 
    customer_unique_id,
    CASE 
        WHEN order_count = 1 THEN 'New'
        WHEN order_count BETWEEN 2 AND 4 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_type
FROM customer_order_counts
ORDER BY order_count DESC;

-- Amazon India wants to know which product categories generate the most revenue.
-- Use joins between the tables to calculate the total revenue for each product category.
-- Display the top 5 categories.
-- Output: product_category_name, total_revenue
-- Q5: Top 5 product categories by revenue.

SELECT 
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;


-- Analysis - III

-- The marketing team wants to compare the total sales between different seasons.
-- Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) based on order purchase dates, and display the results.
-- Spring is in the months of March, April and May.
-- Summer is from June to August and Autumn is between September and November and rest months are Winter. 
-- Output: season, total_sales
-- Q1: Total sales by season using subquery.

SELECT season, ROUND(SUM(total_sales)) AS total_sales
FROM (
    SELECT 
        CASE 
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3,4,5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6,7,8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9,10,11) THEN 'Autumn'
            ELSE 'Winter'
        END AS season,
        oi.price AS total_sales
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
) subq
GROUP BY season
ORDER BY total_sales DESC;


-- The inventory team is interested in identifying products that have sales volumes above the overall average.
-- Write a query that uses a subquery to filter products with a total quantity sold above the average quantity.
-- Output: product_id, total_quantity_sold
-- Q2: Products with above-average quantity sold.

SELECT product_id, total_quantity_sold
FROM (
    SELECT product_id, COUNT(*) AS total_quantity_sold
    FROM amazon_brazil.order_items
    GROUP BY product_id
) product_sales
WHERE total_quantity_sold > (
    SELECT AVG(qty) FROM (
        SELECT COUNT(*) AS qty FROM amazon_brazil.order_items GROUP BY product_id
    ) avg_sub
)
ORDER BY total_quantity_sold DESC;


-- To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year (year 2018).
-- Run a query to calculate total revenue generated each month and identify periods of peak and low sales.
-- Export the data to Excel and create a graph to visually represent revenue changes across the months. 
-- Output: month, total_revenue
-- Q3: Monthly revenue for 2018 (export this to Excel + make a chart).

SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY month;


-- A loyalty program is being designed  for Amazon India.
-- Create a segmentation based on purchase frequency: ‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders.
-- Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment.
-- Output: customer_type, count
-- Q4: Loyalty segmentation with CTE (export this + make a chart).

WITH customer_segments AS (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM amazon_brazil.customer c
    JOIN amazon_brazil.orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
        WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
        ELSE 'Loyal'
    END AS customer_type,
    COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type
ORDER BY count DESC;


-- Amazon wants to identify high-value customers to target for an exclusive rewards program.
-- You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers.
-- Output: **customer_id, avg_order_value, and customer_rank**
-- Q5: Top 20 customers by average order value with rank.

WITH customer_avg AS (
    SELECT 
        o.customer_id,
        ROUND(AVG(oi.price), 2) AS avg_order_value
    FROM amazon_brazil.orders o
    JOIN amazon_brazil.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    customer_id,
    avg_order_value,
    RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
FROM customer_avg
ORDER BY customer_rank
LIMIT 20;


-- Amazon wants to analyze sales growth trends for its key products over their lifecycle.
-- Calculate monthly cumulative sales for each product from the date of its first sale.
-- Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.
-- Output: product_id, sale_month, and total_sales
-- Q6: Recursive CTE for monthly cumulative sales per product.

WITH RECURSIVE monthly_sales AS (
    SELECT 
        product_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
        SUM(oi.price) AS monthly_sales
    FROM amazon_brazil.order_items oi
    JOIN amazon_brazil.orders o ON oi.order_id = o.order_id
    GROUP BY product_id, 
             DATE_TRUNC('month', o.order_purchase_timestamp)
),
first_months AS (
    SELECT 
        product_id,
        sale_month,
        monthly_sales,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY sale_month
        ) AS rn
    FROM monthly_sales
),
cumulative AS (
    -- Base case: first month only
    SELECT 
        product_id,
        sale_month,
        monthly_sales,
        monthly_sales AS total_sales,
        rn
    FROM first_months
    WHERE rn = 1

    UNION ALL

    -- Recursive case: keep adding next months
    SELECT 
        fm.product_id,
        fm.sale_month,
        fm.monthly_sales,
        c.total_sales + fm.monthly_sales AS total_sales,
        fm.rn
    FROM first_months fm
    INNER JOIN cumulative c 
        ON fm.product_id = c.product_id 
        AND fm.rn = c.rn + 1
)
SELECT 
    product_id,
    TO_CHAR(sale_month, 'YYYY-MM') AS sale_month,
    ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM cumulative
ORDER BY product_id, sale_month;


-- To understand how different payment methods affect monthly sales growth, Amazon wants to compute the total sales for each payment method and calculate the month-over-month growth rate for the past year (year 2018).
-- Write query to first calculate total monthly sales for each payment method, then compute the percentage change from the previous month.
-- Output: payment_type, sale_month, monthly_total, monthly_change.
-- Q7: Month-over-month sales growth by payment type (2018).

WITH monthly_totals AS (
    SELECT 
        p.payment_type,
        TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS sale_month,
        ROUND(SUM(p.payment_value), 2) AS monthly_total
    FROM amazon_brazil.payments p
    JOIN amazon_brazil.orders o ON p.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
    GROUP BY p.payment_type, TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
)
SELECT 
    payment_type,
    sale_month,
    monthly_total,
    ROUND(
        (monthly_total - LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month))
        / NULLIF(LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month), 0) * 100,
        2
    ) AS monthly_change
FROM monthly_totals
ORDER BY payment_type, sale_month;






