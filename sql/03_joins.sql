

 PROJECT: SQL BUSINESS CASE STUDIES
 FILE: 03_joins.sql
 AUTHOR: Murakonda Surya Teja
 TOPIC: Advanced SQL Joins
 DATABASE: SQLite



-- 1. INNER JOIN
-- Retrieve customers who have placed orders

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;


-- 2. LEFT JOIN
-- Find all customers, including those without orders

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- 3. FIND CUSTOMERS WITHOUT ORDERS

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 4. MULTIPLE TABLE JOIN
-- Analyze customer purchases with product details

SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    p.category,
    o.quantity,
    o.unit_price,
    o.quantity * o.unit_price AS gross_amount
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN products p
    ON o.product_id = p.product_id;


-- 5. REGION-WISE SALES ANALYSIS

SELECT
    r.region_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS total_revenue
FROM regions r
INNER JOIN orders o
    ON r.region_id = o.region_id
WHERE o.order_status = 'Completed'
GROUP BY r.region_name
ORDER BY total_revenue DESC;


-- 6. EMPLOYEE PERFORMANCE ANALYSIS

SELECT
    e.employee_id,
    e.employee_name,
    e.department,
    COUNT(o.order_id) AS total_orders,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS revenue_generated
FROM employees e
LEFT JOIN orders o
    ON e.employee_id = o.employee_id
    AND o.order_status = 'Completed'
GROUP BY
    e.employee_id,
    e.employee_name,
    e.department
ORDER BY revenue_generated DESC;


-- 7. SELF JOIN
-- Compare employees working in the same region

SELECT
    e1.employee_name AS employee_1,
    e2.employee_name AS employee_2,
    r.region_name
FROM employees e1
INNER JOIN employees e2
    ON e1.region_id = e2.region_id
    AND e1.employee_id < e2.employee_id
INNER JOIN regions r
    ON e1.region_id = r.region_id;


-- 8. CROSS JOIN
-- Generate all possible customer-product combinations

SELECT
    c.customer_name,
    p.product_name
FROM customers c
CROSS JOIN products p;


-- 9. JOIN WITH AGGREGATION
-- Identify top-performing product categories

SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_units_sold,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS category_revenue
FROM products p
INNER JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;


-- 10. JOIN THREE BUSINESS TABLES
-- Analyze employee, customer and order performance

SELECT
    e.employee_name,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.order_status,
    ROUND(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0), 2
    ) AS order_revenue
FROM orders o
INNER JOIN employees e
    ON o.employee_id = e.employee_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY order_revenue DESC;





