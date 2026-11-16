
-- =====================================================
-- PROJECT: SQL BUSINESS CASE STUDIES
-- FILE: 01_create_tables.sql
-- AUTHOR: Murakonda Surya Teja
-- PURPOSE: Create and populate Sales Analytics tables
-- DATABASE: SQLite
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- 1. CREATE REGIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL,
    country TEXT NOT NULL
);

-- =====================================================
-- 2. CREATE EMPLOYEES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name TEXT NOT NULL,
    department TEXT,
    salary REAL CHECK (salary >= 0),
    region_id INTEGER,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- =====================================================
-- 3. CREATE CUSTOMERS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    email TEXT UNIQUE,
    city TEXT,
    registration_date TEXT
);

-- =====================================================
-- 4. CREATE PRODUCTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    unit_price REAL CHECK (unit_price >= 0)
);

-- =====================================================
-- 5. CREATE ORDERS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    employee_id INTEGER,
    region_id INTEGER,
    order_date TEXT NOT NULL,
    quantity INTEGER CHECK (quantity > 0),
    unit_price REAL CHECK (unit_price >= 0),
    discount_pct REAL DEFAULT 0
        CHECK (discount_pct BETWEEN 0 AND 100),
    order_status TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- =====================================================
-- 6. INSERT REGION DATA
-- =====================================================

INSERT OR IGNORE INTO regions VALUES
(1, 'South', 'India'),
(2, 'North', 'India'),
(3, 'West', 'India'),
(4, 'East', 'India');

-- =====================================================
-- 7. INSERT EMPLOYEE DATA
-- =====================================================

INSERT OR IGNORE INTO employees VALUES
(101, 'Rahul Sharma', 'Sales', 55000, 1),
(102, 'Priya Reddy', 'Sales', 60000, 2),
(103, 'Arjun Kumar', 'Marketing', 48000, 3),
(104, 'Sneha Patel', 'Sales', 65000, 4);

-- =====================================================
-- 8. INSERT CUSTOMER DATA
-- =====================================================

INSERT OR IGNORE INTO customers VALUES
(1, 'Amit Verma', 'amit@email.com', 'Hyderabad', '2025-01-10'),
(2, 'Sneha Rao', 'sneha@email.com', 'Bangalore', '2025-02-15'),
(3, 'Rahul Mehta', 'rahul@email.com', 'Mumbai', '2025-03-20'),
(4, 'Priya Singh', 'priya@email.com', 'Delhi', '2025-04-05'),
(5, 'Kiran Reddy', 'kiran@email.com', 'Chennai', '2025-05-12'),
(6, 'Anjali Das', 'anjali@email.com', 'Kolkata', '2025-06-18'),
(7, 'Vikram Rao', 'vikram@email.com', 'Pune', '2025-07-22'),
(8, 'Neha Sharma', 'neha@email.com', 'Hyderabad', '2025-08-01');

-- =====================================================
-- 9. INSERT PRODUCT DATA
-- =====================================================

INSERT OR IGNORE INTO products VALUES
(201, 'Laptop', 'Electronics', 55000),
(202, 'Mobile Phone', 'Electronics', 25000),
(203, 'Office Chair', 'Furniture', 8000),
(204, 'Desk', 'Furniture', 12000),
(205, 'Headphones', 'Accessories', 2500),
(206, 'Keyboard', 'Accessories', 1500);

-- =====================================================
-- 10. INSERT ORDER DATA
-- =====================================================

INSERT OR IGNORE INTO orders VALUES
(1001, 1, 201, 101, 1, '2025-01-15', 1, 55000, 5, 'Completed'),
(1002, 2, 202, 102, 2, '2025-01-20', 2, 25000, 0, 'Completed'),
(1003, 3, 203, 103, 3, '2025-02-05', 3, 8000, 10, 'Completed'),
(1004, 4, 204, 104, 4, '2025-02-12', 1, 12000, 5, 'Completed'),
(1005, 5, 205, 101, 1, '2025-03-01', 4, 2500, 0, 'Completed'),
(1006, 1, 202, 102, 2, '2025-03-10', 1, 25000, 5, 'Completed'),
(1007, 6, 201, 103, 3, '2025-03-18', 2, 55000, 10, 'Completed'),
(1008, 7, 206, 104, 4, '2025-04-02', 5, 1500, 0, 'Completed'),
(1009, 8, 203, 101, 1, '2025-04-15', 2, 8000, 5, 'Completed'),
(1010, 2, 204, 102, 2, '2025-05-05', 3, 12000, 10, 'Completed'),
(1011, 3, 205, 103, 3, '2025-05-12', 2, 2500, 0, 'Cancelled'),
(1012, 4, 201, 104, 4, '2025-06-08', 1, 55000, 5, 'Completed'),
(1013, 5, 202, 101, 1, '2025-06-20', 2, 25000, 0, 'Completed'),
(1014, 6, 206, 102, 2, '2025-07-03', 4, 1500, 5, 'Completed'),
(1015, 7, 203, 103, 3, '2025-07-19', 1, 8000, 0, 'Pending'),
(1016, 8, 204, 104, 4, '2025-08-01', 2, 12000, 5, 'Completed'),
(1017, 1, 205, 101, 1, '2025-08-15', 3, 2500, 0, 'Completed'),
(1018, 2, 201, 102, 2, '2025-09-05', 1, 55000, 10, 'Completed'),
(1019, 3, 202, 103, 3, '2025-09-20', 2, 25000, 5, 'Completed'),
(1020, 4, 206, 104, 4, '2025-10-10', 6, 1500, 0, 'Completed');

-- =====================================================
-- 11. VALIDATE TABLE RECORD COUNTS
-- =====================================================

SELECT 'Regions' AS table_name, COUNT(*) AS total_records
FROM regions

UNION ALL

SELECT 'Employees', COUNT(*) FROM employees

UNION ALL

SELECT 'Customers', COUNT(*) FROM customers

UNION ALL

SELECT 'Products', COUNT(*) FROM products

UNION ALL

SELECT 'Orders', COUNT(*) FROM orders;

-- =====================================================
-- END OF DATABASE CREATION SCRIPT
-- =====================================================
