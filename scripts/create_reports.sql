-- 1. Витрина продаж по продуктам
CREATE TABLE clickhouse.target_db.report_product_sales AS
SELECT
    product_name,
    SUM(sale_total_price) as total_revenue,
    SUM(sale_quantity) as total_quantity,
    AVG(product_rating) as avg_rating
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_products p ON f.product_id = p.product_id
GROUP BY product_name;

-- 2. Витрина продаж по клиентам
CREATE TABLE clickhouse.target_db.report_customer_sales AS
SELECT
    customer_first_name, customer_last_name,
    SUM(sale_total_price) as total_spent,
    COUNT(sale_id) as orders_count,
    AVG(sale_total_price) as avg_check
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_customers c ON f.customer_id = c.customer_id
GROUP BY customer_first_name, customer_last_name;

-- 3. Витрина продаж по времени
CREATE TABLE clickhouse.target_db.report_time_sales AS
SELECT
    extract(year from sale_date) as year,
    extract(month from sale_date) as month,
    SUM(sale_total_price) as monthly_revenue,
    AVG(sale_total_price) as avg_order_size
FROM clickhouse.target_db.fact_sales
GROUP BY 1, 2;

-- 4. Витрина продаж по магазинам
CREATE TABLE clickhouse.target_db.report_store_sales AS
SELECT
    s.store_name, s.store_city,
    SUM(sale_total_price) as store_revenue,
    AVG(sale_total_price) as store_avg_check
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_stores s ON f.store_name = s.store_name
GROUP BY s.store_name, s.store_city;

-- 5. Витрина продаж по поставщикам
CREATE TABLE clickhouse.target_db.report_supplier_sales AS
SELECT
    sup.supplier_name,
    SUM(f.sale_total_price) as supplier_revenue,
    AVG(p.product_price) as avg_unit_price
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_suppliers sup ON f.supplier_name = sup.supplier_name
JOIN clickhouse.target_db.dim_products p ON f.product_id = p.product_id
GROUP BY sup.supplier_name;

-- 6. Витрина качества продукции
CREATE TABLE clickhouse.target_db.report_product_quality AS
SELECT
    p.product_name,
    p.product_rating,
    SUM(f.sale_quantity) as total_sold,
    CORR(p.product_rating, f.sale_quantity) OVER () as rating_sales_correlation
FROM clickhouse.target_db.fact_sales f
JOIN clickhouse.target_db.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_name, p.product_rating, f.sale_quantity;