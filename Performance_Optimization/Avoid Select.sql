-- Instead of this:
SELECT * FROM sales WHERE product_id = 1;

-- Use this:
SELECT transaction_id, total_amount FROM sales WHERE product_id = 1;
