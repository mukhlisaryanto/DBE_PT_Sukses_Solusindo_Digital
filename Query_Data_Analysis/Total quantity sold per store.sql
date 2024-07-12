SELECT st.store_name, SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN store st ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY total_quantity_sold DESC;
