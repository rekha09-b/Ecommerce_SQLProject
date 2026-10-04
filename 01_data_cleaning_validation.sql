create database ecommerce;
use ecommerce;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- A. Verify the row counts

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- B. Clean and validate the data
-- Check for duplicate IDs
SELECT customer_id, COUNT(*) AS row_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS row_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS row_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id, product_id, COUNT(*) AS row_count
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    product_id,
    COUNT(*) AS row_count,
    GROUP_CONCAT(quantity ORDER BY quantity) AS quantities,
    GROUP_CONCAT(price ORDER BY quantity) AS prices
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

--  Check for missing values
-- Customers
SELECT
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country,
    SUM(signup_date IS NULL) AS missing_signup_date
FROM customers;

-- Products
SELECT
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_name IS NULL OR TRIM(product_name) = '') AS missing_product_name,
    SUM(category IS NULL OR TRIM(category) = '') AS missing_category
FROM products;

-- Orders
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(status IS NULL OR TRIM(status) = '') AS missing_status
FROM orders;

-- Order items
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(price IS NULL) AS missing_price
FROM order_items;

-- Check quantities and prices
SELECT *
FROM order_items
WHERE quantity <= 0
   OR price <= 0;
   
-- Check order statuses
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;

-- Validate table relationships
-- Check that the relationships match

-- Orders whose customer is missing
SELECT o.*
FROM orders AS o
LEFT JOIN customers AS c 
ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Items whose order is missing
SELECT oi.*
FROM order_items AS oi
LEFT JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;

-- Items whose product is missing
SELECT oi.*
FROM order_items AS oi
LEFT JOIN products AS p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;
-- or --
-- Items whose order or product is missing
SELECT oi.*
FROM order_items AS oi
LEFT JOIN orders AS o
    ON o.order_id = oi.order_id
LEFT JOIN products AS p
    ON p.product_id = oi.product_id
WHERE o.order_id IS NULL
   OR p.product_id IS NULL;

-- Find orders with no item rows
SELECT
    o.status,
    COUNT(*) AS orders_without_items
FROM orders AS o
LEFT JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
GROUP BY o.status
ORDER BY o.status;

-- this are the order id list which has no item rows in order_item table.
SELECT o.order_id, o.status, o.order_date
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
ORDER BY o.order_id;
