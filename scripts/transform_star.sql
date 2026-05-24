-- 1. Таблица измерений: Продукты
CREATE TABLE clickhouse.target_db.dim_products AS
SELECT DISTINCT
    sale_product_id as product_id, product_name, product_category, product_price, product_brand, product_rating
FROM (
    SELECT * FROM postgresql.source_db.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.target_db.mock_data
);

-- 2. Таблица измерений: Клиенты
CREATE TABLE clickhouse.target_db.dim_customers AS
SELECT DISTINCT
    sale_customer_id as customer_id, customer_first_name, customer_last_name, customer_country, customer_email
FROM (
    SELECT * FROM postgresql.source_db.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.target_db.mock_data
);

-- 3. Таблица измерений: Магазины
CREATE TABLE clickhouse.target_db.dim_stores AS
SELECT DISTINCT
    store_name, store_city, store_country, store_email
FROM (
    SELECT * FROM postgresql.source_db.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.target_db.mock_data
);

-- 4. Таблица измерений: Поставщики
CREATE TABLE clickhouse.target_db.dim_suppliers AS
SELECT DISTINCT
    supplier_name, supplier_city, supplier_country
FROM (
    SELECT * FROM postgresql.source_db.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.target_db.mock_data
);

-- 5. Таблица фактов: Продажи
CREATE TABLE clickhouse.target_db.fact_sales AS
SELECT
    id as sale_id,
    date_parse(sale_date, '%m/%d/%Y') as sale_date,
    sale_product_id as product_id,
    sale_customer_id as customer_id,
    store_name, -- используем как ключ
    supplier_name, -- используем как ключ
    sale_quantity,
    sale_total_price,
    product_rating
FROM (
    SELECT * FROM postgresql.source_db.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.target_db.mock_data
);