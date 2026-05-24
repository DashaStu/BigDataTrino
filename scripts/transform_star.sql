CALL postgresql.system.flush_metadata_cache();
CALL clickhouse.system.flush_metadata_cache();

DROP TABLE IF EXISTS clickhouse.target_db.dim_customers;
DROP TABLE IF EXISTS clickhouse.target_db.dim_products;
DROP TABLE IF EXISTS clickhouse.target_db.dim_stores;
DROP TABLE IF EXISTS clickhouse.target_db.dim_suppliers;
DROP TABLE IF EXISTS clickhouse.target_db.fact_sales;

CREATE TABLE clickhouse.target_db.dim_customers AS
SELECT customer_id, customer_first_name, customer_last_name, customer_country
FROM (
    SELECT
        sale_customer_id AS customer_id,
        customer_first_name,
        customer_last_name,
        customer_country,
        ROW_NUMBER() OVER (PARTITION BY sale_customer_id ORDER BY id) AS rn
    FROM (
        SELECT id, sale_customer_id, customer_first_name, customer_last_name, customer_country FROM postgresql.public.mock_data
        UNION ALL
        SELECT id, sale_customer_id, customer_first_name, customer_last_name, customer_country FROM clickhouse.target_db.mock_data
    )
) WHERE rn = 1;

CREATE TABLE clickhouse.target_db.dim_products AS
SELECT product_id, product_name, product_category, product_price, product_rating
FROM (
    SELECT
        sale_product_id AS product_id,
        product_name,
        product_category,
        CAST(product_price AS DOUBLE) AS product_price,
        CAST(product_rating AS DOUBLE) AS product_rating,
        ROW_NUMBER() OVER (PARTITION BY sale_product_id ORDER BY id) AS rn
    FROM (
        SELECT id, sale_product_id, product_name, product_category, product_price, product_rating FROM postgresql.public.mock_data
        UNION ALL
        SELECT id, sale_product_id, product_name, product_category, product_price, product_rating FROM clickhouse.target_db.mock_data
    )
) WHERE rn = 1;

CREATE TABLE clickhouse.target_db.dim_stores AS
SELECT
    CAST(ROW_NUMBER() OVER () AS INT) AS store_id,
    store_name,
    store_city,
    store_country
FROM (
    SELECT store_name, store_city, store_country,
           ROW_NUMBER() OVER (PARTITION BY store_name ORDER BY id) AS rn
    FROM (
        SELECT id, store_name, store_city, store_country FROM postgresql.public.mock_data
        UNION ALL
        SELECT id, store_name, store_city, store_country FROM clickhouse.target_db.mock_data
    )
) WHERE rn = 1;

CREATE TABLE clickhouse.target_db.dim_suppliers AS
SELECT
    CAST(ROW_NUMBER() OVER () AS INT) AS supplier_id,
    supplier_name,
    supplier_country
FROM (
    SELECT supplier_name, supplier_country,
           ROW_NUMBER() OVER (PARTITION BY supplier_name ORDER BY id) AS rn
    FROM (
        SELECT id, supplier_name, supplier_country FROM postgresql.public.mock_data
        UNION ALL
        SELECT id, supplier_name, supplier_country FROM clickhouse.target_db.mock_data
    )
) WHERE rn = 1;

CREATE TABLE clickhouse.target_db.fact_sales AS
SELECT
    CAST(ROW_NUMBER() OVER () AS INT) AS sale_key,
    CAST(date_parse(raw.sale_date, '%m/%d/%Y') AS DATE) AS sale_date,
    raw.sale_customer_id AS customer_id,
    raw.sale_product_id AS product_id,
    s.store_id,
    sup.supplier_id,
    CAST(raw.sale_quantity AS INTEGER) AS sale_quantity,
    CAST(raw.sale_total_price AS DOUBLE) AS sale_total_price
FROM (
    SELECT id, sale_date, sale_customer_id, sale_product_id, store_name, supplier_name, sale_quantity, sale_total_price
    FROM postgresql.public.mock_data
    UNION ALL
    SELECT id, sale_date, sale_customer_id, sale_product_id, store_name, supplier_name, sale_quantity, sale_total_price
    FROM clickhouse.target_db.mock_data
) raw
LEFT JOIN clickhouse.target_db.dim_stores s ON raw.store_name = s.store_name
LEFT JOIN clickhouse.target_db.dim_suppliers sup ON raw.supplier_name = sup.supplier_name;