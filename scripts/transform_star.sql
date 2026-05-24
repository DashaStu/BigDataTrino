DROP TABLE IF EXISTS clickhouse.target_db.dim_customers;
CREATE TABLE clickhouse.target_db.dim_customers AS
SELECT DISTINCT
    customer_first_name, customer_last_name, customer_country, customer_email
FROM (
    SELECT customer_first_name, customer_last_name, customer_country, customer_email FROM postgresql.public.mock_data
    UNION ALL
    SELECT customer_first_name, customer_last_name, customer_country, customer_email FROM clickhouse.target_db.mock_data
);

DROP TABLE IF EXISTS clickhouse.target_db.dim_products;
CREATE TABLE clickhouse.target_db.dim_products AS
SELECT DISTINCT
    product_name, product_category, CAST(product_price AS DOUBLE) as product_price, product_brand
FROM (
    SELECT product_name, product_category, product_price, product_brand FROM postgresql.public.mock_data
    UNION ALL
    SELECT product_name, product_category, product_price, product_brand FROM clickhouse.target_db.mock_data
);

DROP TABLE IF EXISTS clickhouse.target_db.fact_sales;
CREATE TABLE clickhouse.target_db.fact_sales AS
SELECT
    id as sale_id,
    date_parse(sale_date, '%m/%d/%Y') as sale_date,
    product_name,
    customer_email,
    CAST(sale_quantity AS BIGINT) as sale_quantity,
    CAST(sale_total_price AS DOUBLE) as sale_total_price,
    CAST(product_rating AS DOUBLE) as product_rating
FROM (
    SELECT id, sale_date, product_name, customer_email, sale_quantity, sale_total_price, product_rating FROM postgresql.public.mock_data
    UNION ALL
    SELECT id, sale_date, product_name, customer_email, sale_quantity, sale_total_price, product_rating FROM clickhouse.target_db.mock_data
);