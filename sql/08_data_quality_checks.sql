
-- 1. Check whether important customer details are missing

SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR TRIM(customer_name) = '';


-- 2. Check for duplicate customer records

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 3. Check for products with missing or invalid details

SELECT
    product_id,
    product_name,
    category,
    unit_price
FROM products
WHERE product_id IS NULL
   OR product_name IS NULL
   OR TRIM(product_name) = ''
   OR category IS NULL
   OR unit_price IS NULL
   OR unit_price <= 0;


-- 4. Check for duplicate product records

SELECT
    product_id,
    COUNT(*) AS record_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- 5. Find orders with missing or invalid values

SELECT
    order_id,
    order_date,
    order_status,
    quantity,
    unit_price,
    discount_pct
FROM orders
WHERE order_id IS NULL
   OR order_date IS NULL
   OR order_status IS NULL
   OR quantity IS NULL
   OR unit_price IS NULL
   OR discount_pct IS NULL
   OR quantity <= 0
   OR unit_price <= 0
   OR discount_pct < 0
   OR discount_pct > 100;


-- 6. Check whether order dates are stored in a valid date format

SELECT
    order_id,
    order_date
FROM orders
WHERE order_date IS NOT NULL
  AND date(order_date) IS NULL;


-- 7. Find orders linked to customers who do not exist

SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 8. Find orders linked to products that do not exist

SELECT
    o.order_id,
    o.product_id
FROM orders o
LEFT JOIN products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 9. Check whether orders are linked to valid regions

SELECT
    o.order_id,
    o.region_id
FROM orders o
LEFT JOIN regions r
    ON o.region_id = r.region_id
WHERE o.region_id IS NOT NULL
  AND r.region_id IS NULL;


-- 10. Check for duplicate region records

SELECT
    region_id,
    COUNT(*) AS record_count
FROM regions
GROUP BY region_id
HAVING COUNT(*) > 1;


-- 11. Check how many records are available in each table

SELECT 'Customers' AS table_name, COUNT(*) AS total_records
FROM customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'Regions', COUNT(*)
FROM regions;


-- 12. Check for unusually high discounts

SELECT
    order_id,
    product_id,
    discount_pct
FROM orders
WHERE discount_pct >= 50
ORDER BY discount_pct DESC;
