SELECT p.category, SUM(s.total_amount) AS total_sales_amount
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales_amount DESC;
