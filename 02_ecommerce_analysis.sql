-- ------------------------------- C. Analysis --------------------------------------------------

-- 1. Count of orders with no item rows :
SELECT
    o.status,
    COUNT(*) AS orders_without_items
FROM orders AS o
LEFT JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
GROUP BY o.status
ORDER BY o.status;

-- The order id list which has no item rows in order_item table.
SELECT o.order_id, o.status, o.order_date
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
ORDER BY o.order_id;


-- 2.Analyze order status
-- Count orders by status with item rows :
SELECT
    status,
     COUNT(DISTINCT o.order_id) AS completed_orders_with_items
FROM orders AS o
JOIN order_items AS oi
ON o.order_id = oi.order_id
GROUP BY status
ORDER BY completed_orders_with_items DESC;

-- 3. How many orders are in each status? What are the rates?
WITH orders_with_items AS (
    SELECT DISTINCT
        o.order_id,
        o.status
    FROM orders AS o
    JOIN order_items AS oi
        ON oi.order_id = o.order_id
),
status_counts AS (
    SELECT
        status,
        COUNT(*) AS order_count
    FROM orders_with_items
    GROUP BY status
)
SELECT
    status,
    order_count,
    ROUND(
        100.0 * order_count / SUM(order_count) OVER (),
        2
    ) AS rate_pct
FROM status_counts
ORDER BY order_count DESC;

-- 4.Total Quantity by order status for available item rows.
SELECT
    o.status,
    SUM(oi.quantity) AS total_quantity
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY o.status
ORDER BY total_quantity DESC;

-- 5.Total Quantity and Revenue for Completed orders with available item rows.
SELECT
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.price) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS completed_orders_with_items
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Analyze monthly sales :
-- 6. Completed revenue and units by month:
-- (These queries use date functions: YEAR, MONTH, MONTHNAME, and DATE_FORMAT)
SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    MONTHNAME(o.order_date) AS month_name,
    DATE_FORMAT(o.order_date, '%Y-%m') AS yr_month,
    SUM(oi.quantity * oi.price) AS completed_revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS completed_orders_with_items
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date),
    MONTHNAME(o.order_date),
    DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_year, order_month;

-- Analyze products and categories :
-- 7. Which product categories have the highest Completed revenue?
SELECT
    p.category,
    SUM(oi.quantity * oi.price) AS completed_revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS orders_with_category
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
JOIN products AS p
    ON p.product_id = oi.product_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY completed_revenue DESC;

-- 8. Which products have the highest Completed revenue? 
-- (These queries use JOIN, SUM, AVG, COUNT(DISTINCT), GROUP BY, ORDER BY, and LIMIT.)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity * oi.price) AS completed_revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
JOIN products AS p
    ON p.product_id = oi.product_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY completed_revenue DESC;

-- Analyze revenue by country :
-- 9. Which countries have the highest Completed revenue?
-- NULLIF(x, 0) returns NULL when x is zero, preventing a division-by-zero error.
SELECT 
    c.country,
    COUNT(DISTINCT o.order_id) AS completed_orders_with_items,
    COUNT(DISTINCT c.customer_id) AS customers_with_completed_orders,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.price) AS completed_revenue,
    ROUND(SUM(oi.quantity * oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0),
            2) AS revenue_per_order
FROM
    customers AS c
        JOIN
    orders AS o ON o.customer_id = c.customer_id
        JOIN
    order_items AS oi ON oi.order_id = o.order_id
WHERE
    o.status = 'Completed'
GROUP BY c.country
ORDER BY completed_revenue DESC;

-- Find repeat customers :
-- 10. Which customers have multiple Completed orders?
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS completed_order_count,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY o.customer_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_revenue DESC;

-- Rank products with CTEs and window functions :
-- 11. Which top 5 products rank highest by revenue?
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.price) AS completed_revenue
    FROM orders AS o
    JOIN order_items AS oi
        ON oi.order_id = o.order_id
    JOIN products AS p
        ON p.product_id = oi.product_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category
),
product_ranking AS (
SELECT
    product_id,
    product_name,
    category,
    completed_revenue,
    RANK() OVER (ORDER BY completed_revenue DESC) AS revenue_rank
FROM product_sales)
SELECT * FROM product_ranking
WHERE revenue_rank <= 5
ORDER BY revenue_rank, product_id;

