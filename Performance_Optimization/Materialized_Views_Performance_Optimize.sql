CREATE MATERIALIZED VIEW mv_sales_summary AS
SELECT product_id, customer_id, date_id, store_id, SUM(total_amount) AS total_sales
FROM sales
GROUP BY product_id, customer_id, date_id, store_id;
