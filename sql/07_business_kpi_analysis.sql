
-- 1. How much revenue did we generate and how many orders were completed?

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(
        quantity * unit_price *
        (1 - discount_pct / 100.0)
    ), 2) AS total_revenue,
    ROUND(AVG(
        quantity * unit_price *
        (1 - discount_pct / 100.0)
    ), 2) AS avg_line_value
FROM orders
WHERE order_status = 'Completed';


-- 2. What is the average order value?

SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS order_value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY order_id
);


-- 3. Which product categories contribute the most revenue?

SELECT
    p.category,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS category_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;


-- 4. Which regions are generating the highest revenue?

SELECT
    r.region_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS total_revenue
FROM orders o
JOIN regions r
    ON o.region_id = r.region_id
WHERE o.order_status = 'Completed'
GROUP BY r.region_name
ORDER BY total_revenue DESC;


-- 5. How many customers are making repeat purchases?

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
);


-- 6. What percentage of customers are repeat buyers?

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN total_orders > 1 THEN 1
        ELSE 0
    END) AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- 7. How is revenue changing month by month?

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
),
sales_comparison AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS current_revenue,
    ROUND(previous_month_revenue, 2) AS previous_revenue,
    ROUND(
        revenue - previous_month_revenue, 2
    ) AS revenue_difference,
    ROUND(
        (revenue - previous_month_revenue) * 100.0 /
        NULLIF(previous_month_revenue, 0), 2
    ) AS growth_percentage
FROM sales_comparison
ORDER BY sales_month;


-- 8. What is the order status breakdown?

SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM orders), 2
    ) AS order_percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
