SELECT c.customer_name, SUM(s.total_amount) AS total_purchase_amount
FROM sales s
JOIN customer c ON s.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_purchase_amount DESC
LIMIT 3;
