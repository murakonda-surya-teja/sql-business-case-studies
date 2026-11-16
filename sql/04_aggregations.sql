-- How much revenue did we actually generate
-- from orders that were successfully completed?

SELECT
    ROUND(
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)), 2
    ) AS net_sales
FROM orders
WHERE order_status = 'Completed';


-- Which product categories are bringing in the most revenue?

SELECT
    p.category,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS net_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY net_revenue DESC;


-- Which customers contribute the most to our sales?

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_revenue DESC;


-- How are sales performing month over month?

SELECT
    strftime('%Y-%m', order_date) AS sales_month,
    COUNT(*) AS completed_orders,
    ROUND(SUM(
        quantity * unit_price *
        (1 - discount_pct / 100.0)
    ), 2) AS monthly_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY sales_month;


-- Which employees are generating the highest sales?

SELECT
    e.employee_name,
    COUNT(o.order_id) AS orders_handled,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS sales_generated
FROM employees e
LEFT JOIN orders o
    ON e.employee_id = o.employee_id
    AND o.order_status = 'Completed'
GROUP BY e.employee_id, e.employee_name
ORDER BY sales_generated DESC;


-- What percentage of orders are completed, pending or cancelled?

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders), 2
    ) AS order_percentage
FROM orders
GROUP BY order_status;


-- How much discount are we offering on average?

SELECT
    ROUND(AVG(discount_pct), 2) AS average_discount,
    MAX(discount_pct) AS highest_discount,
    MIN(discount_pct) AS lowest_discount
FROM orders;


-- Which regions contribute the most to completed sales?

SELECT
    r.region_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS regional_revenue
FROM regions r
JOIN orders o
    ON r.region_id = o.region_id
WHERE o.order_status = 'Completed'
GROUP BY r.region_id, r.region_name
ORDER BY regional_revenue DESC;
