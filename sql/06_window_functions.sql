
-- 1. Rank products based on their total sales

SELECT
    p.product_name,
    p.category,
    ROUND(SUM(o.quantity * o.unit_price *
        (1 - o.discount_pct / 100.0)), 2) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)) DESC
    ) AS sales_rank
FROM products p
JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY sales_rank;


-- 2. Find the top 3 products in each category

WITH product_sales AS (
    SELECT
        p.product_name,
        p.category,
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)) AS revenue
    FROM products p
    JOIN orders o
        ON p.product_id = o.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT
        product_name,
        category,
        ROUND(revenue, 2) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY revenue DESC, product_name
        ) AS product_rank
    FROM product_sales
)

SELECT *
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;


-- 3. Compare each customer's orders with their previous order

WITH customer_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS order_value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, order_id, order_date
)

SELECT
    customer_id,
    order_id,
    order_date,
    ROUND(order_value, 2) AS order_value,
    ROUND(
        LAG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ), 2
    ) AS previous_order_value
FROM customer_orders
ORDER BY customer_id, order_date;


-- 4. Calculate running revenue month by month

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
        SUM(revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ), 2
    ) AS running_revenue
FROM monthly_sales
ORDER BY sales_month;


-- 5. Compare monthly revenue with the previous month

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS sales_month,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY strftime('%Y-%m', order_date)
),
monthly_comparison AS (
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
    ) AS revenue_change,
    ROUND(
        (revenue - previous_month_revenue) * 100.0 /
        NULLIF(previous_month_revenue, 0), 2
    ) AS growth_percentage
FROM monthly_comparison
ORDER BY sales_month;


-- 6. Rank customers based on their total spending

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price *
            (1 - o.discount_pct / 100.0)) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)

SELECT
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS customer_rank
FROM customer_sales
ORDER BY customer_rank, customer_name;


-- 7. Find each customer's highest-value order

WITH order_values AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        SUM(quantity * unit_price *
            (1 - discount_pct / 100.0)) AS order_value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, order_id, order_date
),
ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROUND(order_value, 2) AS order_value,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_value DESC, order_date
        ) AS order_rank
    FROM order_values
)

SELECT
    customer_id,
    order_id,
    order_date,
    order_value
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;
