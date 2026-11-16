-- PROJECT: SQL BUSINESS CASE STUDIES
-- FILE: 02_basic_sql.sql
-- AUTHOR: Murakonda Surya Teja
-- DATABASE: SQLite
-- TOPIC: Basic SQL and Business Analytics


-- 1. Display all customer records

SELECT *
FROM customers;


-- 2. Find all completed orders

SELECT *
FROM orders
WHERE order_status = 'Completed';


-- 3. Calculate total completed sales revenue
-- Revenue = Quantity * Unit Price * (1 - Discount)

SELECT
    ROUND(
        SUM(quantity * unit_price * (1 - discount_pct / 100.0)),
        2
    ) AS total_revenue
FROM orders
WHERE order_status = 'Completed';


-- 4. Find the top 5 customers by revenue

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;


-- 5. Identify the best-selling products

SELECT
    p.product_name,
    SUM(o.quantity) AS units_sold
FROM products p
JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY units_sold DESC;


-- 6. Calculate category-wise revenue

SELECT
    p.category,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS category_revenue
FROM products p
JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;


-- 7. Calculate monthly revenue

SELECT
    strftime('%Y-%m', order_date) AS sales_month,
    ROUND(
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)), 2
    ) AS monthly_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY sales_month;


-- 8. Calculate average order value

SELECT
    ROUND(
        AVG(order_revenue), 2
    ) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS order_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY order_id
);


-- 9. Analyze order status distribution

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 10. Calculate region-wise sales revenue

SELECT
    r.region_name,
    ROUND(
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)), 2
    ) AS regional_revenue
FROM regions r
JOIN orders o
    ON r.region_id = o.region_id
WHERE o.order_status = 'Completed'
GROUP BY r.region_name
ORDER BY regional_revenue DESC;


-- 11. Find customers who have never placed an order

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 12. Find orders above the average completed order value

SELECT
    order_id,
    order_revenue
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS order_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY order_id
) order_summary
WHERE order_revenue > (
    SELECT AVG(order_revenue)
    FROM (
        SELECT
            order_id,
            SUM(quantity * unit_price *
                (1 - discount_pct / 100.0)) AS order_revenue
        FROM orders
        WHERE order_status = 'Completed'
        GROUP BY order_id
    )
)
ORDER BY order_revenue DESC;


