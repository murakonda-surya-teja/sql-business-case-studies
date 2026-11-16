
-- 1. Which customers are generating more revenue than the average customer?

SELECT
    c.customer_name,
    ROUND(SUM(
        o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)
    ), 2) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(
    o.quantity * o.unit_price *
    (1 - o.discount_pct / 100.0)
) > (
    SELECT AVG(customer_revenue)
    FROM (
        SELECT
            SUM(quantity * unit_price *
                (1 - discount_pct / 100.0)) AS customer_revenue
        FROM orders
        WHERE order_status = 'Completed'
        GROUP BY customer_id
    )
)
ORDER BY customer_revenue DESC;


-- 2. Which customers have placed more than one order?

SELECT
    customer_id,
    customer_name,
    total_orders
FROM (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
WHERE total_orders > 1
ORDER BY total_orders DESC;


-- 3. Which products are priced above the average product price?

SELECT
    product_name,
    category,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products
)
ORDER BY unit_price DESC;


-- 4. Monthly revenue using a CTE

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS monthly_revenue
FROM monthly_sales
ORDER BY sales_month;


-- 5. Which regions are performing above average?

WITH region_sales AS (
    SELECT
        r.region_name,
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)) AS revenue
    FROM regions r
    JOIN orders o
        ON r.region_id = o.region_id
    WHERE o.order_status = 'Completed'
    GROUP BY r.region_id, r.region_name
)

SELECT
    region_name,
    ROUND(revenue, 2) AS regional_revenue
FROM region_sales
WHERE revenue > (
    SELECT AVG(revenue)
    FROM region_sales
)
ORDER BY revenue DESC;


-- 6. Find customers who have not placed any orders

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- 7. Compare each month's revenue with the overall average monthly revenue

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
)

SELECT
    sales_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        (SELECT AVG(revenue) FROM monthly_sales), 2
    ) AS average_monthly_revenue,
    CASE
        WHEN revenue > (SELECT AVG(revenue) FROM monthly_sales)
            THEN 'Above Average'
        WHEN revenue < (SELECT AVG(revenue) FROM monthly_sales)
            THEN 'Below Average'
        ELSE 'Average'
    END AS performance
FROM monthly_sales
ORDER BY sales_month;
