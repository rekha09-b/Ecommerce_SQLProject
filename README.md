

# # Ecommerce Data Analysis with MySQL
## Project Summary

A completed ecommerce data analytics project using MySQL and MySQL Workbench. The project moves from importing and validating four related CSV files to answering sales, order, product, and customer questions with SQL.

**Revenue definition:** `quantity * price`. The main revenue analysis includes available item rows from Completed orders.

## Dataset and Tables

- **`customers`** — customer ID, country, and signup date; used for customer and country analysis.
- **`products`** — product ID, product name, and category; used for product and category analysis.
- **`orders`** — order ID, customer ID, order date, and status; used for order activity and status analysis.
- **`order_items`** — order ID, product ID, quantity, and price; used to calculate units and revenue.

**Dataset size:** 300 customers, 50 products, 1,000 orders, and 2,000 order-item rows. Orders are dated in 2024.

Work Completed

### Data cleaning and validation

- Verified imported row counts against the source files.
- Checked all four tables for missing or blank values.
- Checked customer, product, and order IDs for duplicates.
- Reviewed repeated `order_id` and `product_id` pairs in `order_items`.
- Checked order statuses, positive quantities and prices, and table relationships.
- Used a left join to identify orders without matching item rows.

### SQL analysis

- Counted orders by status and calculated status rates.
- Calculated quantity with `SUM(quantity)` and revenue with `SUM(quantity * price)`.
- Compared order counts, revenue, and quantity by month.
- Analyzed revenue and quantity by product and category.
- Compared Completed order activity and revenue by customer and country.
- Ranked products by revenue and identified repeat customers with multiple Completed orders.

## Business Questions

- How many orders are Completed, Cancelled, and Returned?
- What are the cancellation and return rates?
- How many orders have item details, and how many are missing them?
- What quantity and revenue are represented by available Completed-order item rows?
- How do order counts, revenue, and quantity vary by month?
- Which products and categories generate the most revenue and units?
- Which countries and customers have the most Completed order activity and revenue?
- Which products rank highest by revenue?
- Which customers placed multiple Completed orders with item details?

Key Findings

- **Orders without item rows:** 139 total: 110 Completed, 20 Cancelled, and 9 Returned.
- **Status among orders with item details:** 861 distinct orders: 695 Completed (80.72%), 83 Cancelled (9.64%), and 83 Returned (9.64%). The denominator is the 861 orders with item details.
- **Top products by available Completed-order revenue:** Product_16 (Makeup), Product_45 (Body), Product_25 (Hair), Product_23 (Body), and Product_6 (Body). Product_16 ranked first.

SQL Concepts Used

- **Joins:** `JOIN`, `LEFT JOIN`
- **Filtering and grouping:** `WHERE`, `GROUP BY`, `HAVING`
- **Aggregations:** `SUM`, `COUNT`, `COUNT(DISTINCT ...)`, `AVG`
- **Conditional calculations:** `CASE` and conditional expressions
- **Date analysis:** `YEAR`, `MONTH`, `MONTHNAME`, `DATE_FORMAT`
- **Null and safe-division handling:** `COALESCE`, `NULLIF`
- **Advanced querying:** Common table expressions (CTEs), `RANK()` window function
- **Result ordering:** `ORDER BY`, `LIMIT

Limitations

- 110 Completed orders have no item rows, so item-based revenue and quantity may be incomplete.
- Returned item values are not confirmed refund amounts.
- Product names are generic, limiting product-level interpretation.
- Cost data is unavailable, so profit cannot be calculated.

## Repository Contents

- `01_data_cleaning_validation.sql` — data-quality and validation queries.
- `02_ecommerce_analysis.sql` — SQL queries used to answer the business questions.
- `data/` — optional source CSV files; include only if redistribution is permitted.

**Tools:** MySQL, MySQL Workbench.
