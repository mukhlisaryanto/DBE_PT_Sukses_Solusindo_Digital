SELECT d.month, SUM(s.total_amount) AS monthly_sales_amount
FROM sales s
JOIN date d ON s.date_id = d.date_id
WHERE d.year = 2024 AND d.month IN (1, 2, 3)
GROUP BY d.month
ORDER BY d.month;
