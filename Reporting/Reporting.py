import pandas as pd
import psycopg2

# Koneksi ke PostgreSQL
conn = psycopg2.connect(
    dbname="ecommerce_data",
    user="postgres",
    password="root",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# Menjalankan Query untuk Laporan
query = """
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
"""

# Mengambil Data ke DataFrame
sales_report_df = pd.read_sql_query(query, conn)

# Tutup Koneksi
cursor.close()
conn.close()

# Tampilkan DataFrame
print(sales_report_df)

# Simpan DataFrame ke Excel (opsional)
sales_report_df.to_excel("sales_performance_report.xlsx", index=False)

import matplotlib.pyplot as plt

# Membuat Pivot Table untuk Visualisasi
pivot_df = sales_report_df.pivot(index='store_name', columns='category', values='total_sales_amount')

# Membuat Bar Plot
pivot_df.plot(kind='bar', figsize=(12, 8))
plt.title('Sales Performance by Store and Product Category')
plt.xlabel('Store Name')
plt.ylabel('Total Sales Amount')
plt.legend(title='Product Category')
plt.tight_layout()
plt.show()
