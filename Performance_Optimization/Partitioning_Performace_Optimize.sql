CREATE TABLE sales_partitioned (
    transaction_id INT,
    product_id INT,
    customer_id INT,
    date_id INT,
    store_id INT,
    quantity INT,
    total_amount DECIMAL
) PARTITION BY RANGE (date_id);

CREATE TABLE sales_2024 PARTITION OF sales_partitioned FOR VALUES FROM (20240101) TO (20241231);
