-- Repair partitions
MSCK REPAIR TABLE orders;

-- Drop old curated tables
DROP TABLE IF EXISTS curated_daily_revenue;
DROP TABLE IF EXISTS curated_city_revenue;
DROP TABLE IF EXISTS curated_product_performance;

-- Create curated table
CREATE TABLE curated_daily_revenue
WITH (
    format = 'PARQUET',
    external_location = 's3://e-comm-proj/curated/daily_revenue/',
    partitioned_by = ARRAY['year', 'month']
) AS
SELECT
    order_date,
    SUM(price * quantity) AS daily_revenue, 
    year,
    month
FROM orders
WHERE status = 'delivered'
GROUP BY order_date, year, month;

CREATE TABLE curated_city_revenue
WITH (
    format = 'PARQUET',
    external_location = 's3://e-comm-proj/curated/city_revenue/',
    partitioned_by = ARRAY['year', 'month']
) AS
SELECT
    city,
    SUM(price * quantity) AS revenue,
    year,
    month
FROM orders
WHERE status = 'delivered'
GROUP BY city, year, month;

CREATE TABLE curated_product_performance
WITH (
    format = 'PARQUET',
    external_location = 's3://e-comm-proj/curated/product_performance/',
    partitioned_by = ARRAY['year', 'month']
)
AS
SELECT
    product_name,
    SUM(price * quantity) AS revenue,
    COUNT(order_id) AS total_orders,
    year,
    month
FROM orders
WHERE status = 'delivered'
GROUP BY product_name, year, month;