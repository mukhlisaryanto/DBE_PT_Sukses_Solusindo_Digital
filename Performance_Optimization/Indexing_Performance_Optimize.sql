CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_date_id ON sales(date_id);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
