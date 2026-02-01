
CREATE TABLE fact_daily_revenue (
    order_date DATE,
    daily_revenue DOUBLE PRECISION,
    year VARCHAR,
    month VARCHAR
);

COPY fact_daily_revenue 
FROM 's3://e-comm-proj/curated/daily_revenue/' 
IAM_ROLE 'arn:aws:iam::437799327577:role/redshift-role' 
FORMAT AS PARQUET;


CREATE TABLE fact_city_revenue (
    city VARCHAR,
    revenue DOUBLE PRECISION,
    year VARCHAR,
    month VARCHAR
);

COPY fact_city_revenue 
FROM 's3://e-comm-proj/curated/city_revenue/' 
IAM_ROLE 'arn:aws:iam::437799327577:role/redshift-role' 
FORMAT AS PARQUET;


CREATE TABLE fact_product_performance (
    product_name VARCHAR(100),
    total_orders INTEGER,
    revenue DOUBLE PRECISION
);

COPY fact_product_performance
FROM 's3://e-comm-proj/curated/product_performance/'
IAM_ROLE 'arn:aws:iam::437799327577:role/redshift-role'
FORMAT AS PARQUET;