DROP TABLE IF EXISTS clickhouse.target_db.report_1;
CREATE TABLE clickhouse.target_db.report_1 AS
SELECT p.product_name, SUM(f.sale_total_price) as revenue, SUM(f.sale_quantity) as quantity, AVG(p.product_rating) as rating
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_name;

DROP TABLE IF EXISTS clickhouse.target_db.report_2;
CREATE TABLE clickhouse.target_db.report_2 AS
SELECT c.customer_first_name, c.customer_last_name, SUM(f.sale_total_price) as spent, COUNT(f.sale_key) as orders_count, AVG(f.sale_total_price) as avg_check
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.customer_first_name, c.customer_last_name;

DROP TABLE IF EXISTS clickhouse.target_db.report_3;
CREATE TABLE clickhouse.target_db.report_3 AS
SELECT extract(year from sale_date) as year, extract(month from sale_date) as month, SUM(sale_total_price) as revenue
FROM clickhouse.target_db.fact_sales GROUP BY 1, 2;

DROP TABLE IF EXISTS clickhouse.target_db.report_4;
CREATE TABLE clickhouse.target_db.report_4 AS
SELECT s.store_name, SUM(f.sale_total_price) as revenue
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_stores s ON f.store_id = s.store_id
GROUP BY s.store_name;

DROP TABLE IF EXISTS clickhouse.target_db.report_5;
CREATE TABLE clickhouse.target_db.report_5 AS
SELECT sup.supplier_name, SUM(f.sale_total_price) as revenue
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_suppliers sup ON f.supplier_id = sup.supplier_id
GROUP BY sup.supplier_name;

DROP TABLE IF EXISTS clickhouse.target_db.report_6;
CREATE TABLE clickhouse.target_db.report_6 AS
SELECT p.product_name, p.product_rating, COUNT(*) as sales_count
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_name, p.product_rating;