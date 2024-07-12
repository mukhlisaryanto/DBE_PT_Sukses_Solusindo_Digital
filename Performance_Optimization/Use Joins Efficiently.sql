SELECT s.transaction_id, p.product_name
FROM sales s
JOIN product p ON s.product_id = p.product_id
WHERE s.date_id BETWEEN '2024-01-01' AND '2024-03-31';
