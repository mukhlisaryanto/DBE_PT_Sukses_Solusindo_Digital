SELECT
    st.store_name,
    p.category,
    SUM(s.total_amount) AS total_sales_amount,
    SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN store st ON s.store_id = st.store_id
GROUP BY
    st.store_name, p.category
ORDER BY
    st.store_name, p.category;
