# DBE_PT_Sukses_Solusindo_Digital

## Technical Test for Database Engineer at PT Sukses Solusindo Digital

**Candidate Name:** Mukhlis Aryanto  
**Email:** aryantomukhlis@gmail.com  
**Phone:** 083869756993  
**Github Project:** [DBE_PT_Sukses_Solusindo_Digital](https://github.com/mukhlisaryanto/DBE_PT_Sukses_Solusindo_Digital)

---

### Table of Contents
1. [Preparation](#preparation)
2. [Data Warehouse Design](#data-warehouse-design)
3. [ETL Process](#etl-process)
4. [Data Analysis SQL Queries](#data-analysis-sql-queries)
5. [Performance Optimization](#performance-optimization)
6. [Reporting](#reporting)

---

### Preparation
**Environment:**
- **DBMS:** PostgreSQL version 16 & PgAdmin version 8.2
- **Code Editor:** PyCharm version 2024.1.1
- **Python:** 3.13.3

All project files are organized in one folder: `PT_Sukses_Solusindo_Digital`.

---

### Data Warehouse Design
**Star Schema Design:**
Designed a star schema for an e-commerce platform using provided raw data. Fact and dimension tables are identified and created in `ecommerce_data.sql`.

**SQL Script to Create Data Warehouse:**
```sql
CREATE DATABASE ecommerce_data;
\c ecommerce_data

CREATE TABLE IF NOT EXISTS sales (
  transaction_id INT PRIMARY KEY,
  product_id INT,
  customer_id INT,
  date_id INT,
  store_id INT,
  quantity INT,
  total_amount DECIMAL
);

CREATE TABLE IF NOT EXISTS product (
  product_id INT PRIMARY KEY,
  product_name VARCHAR,
  category VARCHAR,
  price DECIMAL
);

CREATE TABLE IF NOT EXISTS customer (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR,
  email VARCHAR,
  location VARCHAR
);

CREATE TABLE IF NOT EXISTS date (
  date_id INT PRIMARY KEY,
  date DATE,
  day INT,
  month INT,
  year INT
);

CREATE TABLE IF NOT EXISTS store (
  store_id INT PRIMARY KEY,
  store_name VARCHAR,
  location VARCHAR
);

ALTER TABLE sales ADD FOREIGN KEY (product_id) REFERENCES product (product_id);
ALTER TABLE sales ADD FOREIGN KEY (customer_id) REFERENCES customer (customer_id);
ALTER TABLE sales ADD FOREIGN KEY (date_id) REFERENCES date (date_id);
ALTER TABLE sales ADD FOREIGN KEY (store_id) REFERENCES store (store_id);
```

---

### ETL Process
**Extract and Load Data Using Python Script:**
Dependencies: `openpyxl`, `psycopg2`, `pandas`
Script file: `Extract_Load_data.py`
```python
import pandas as pd
import psycopg2

# Read Excel file
excel_file = r"./ecommerce_data.xlsx"
sheets = ['product', 'customer', 'date', 'store', 'sales']
dfs = {sheet: pd.read_excel(excel_file, sheet_name=sheet) for sheet in sheets}

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="ecommerce_data", user="postgres", password="root", host="localhost", port="5432"
)
cursor = conn.cursor()

# Function to determine SQL type from pandas dtype
def get_sql_type(dtype):
    if pd.api.types.is_integer_dtype(dtype):
        return 'INT'
    elif pd.api.types.is_float_dtype(dtype):
        return 'DECIMAL'
    elif pd.api.types.is_bool_dtype(dtype):
        return 'BOOLEAN'
    elif pd.api.types.is_datetime64_any_dtype(dtype):
        return 'DATE'
    else:
        return 'VARCHAR'

# Function to load DataFrame to PostgreSQL table
def load_to_postgres(df, table_name):
    csv_file = f'{table_name}.csv'
    df.to_csv(csv_file, index=False, header=False)
    with open(csv_file, 'r') as f:
        cursor.copy_expert(f"COPY {table_name} FROM STDIN WITH CSV", f)
    conn.commit()

# Create temporary tables and load data
for sheet, df in dfs.items():
    temp_table = f"{sheet}_temp"
    df.columns = map(str.lower, df.columns)
    cursor.execute(f"DROP TABLE IF EXISTS {temp_table}")
    create_table_sql = f"""
    CREATE TABLE {temp_table} (
        {', '.join([f'{col} {get_sql_type(df[col].dtype)}' for col in df.columns])}
    )
    """
    cursor.execute(create_table_sql)
    conn.commit()
    load_to_postgres(df, temp_table)

# Close connection
cursor.close()
conn.close()
```

**Transform Data:**
Script file: `Transform_data.sql`
```sql
-- Create final tables if they don't exist
CREATE TABLE IF NOT EXISTS product (product_id INT PRIMARY KEY, product_name VARCHAR, category VARCHAR, price DECIMAL);
CREATE TABLE IF NOT EXISTS customer (customer_id INT PRIMARY KEY, customer_name VARCHAR, email VARCHAR, location VARCHAR);
CREATE TABLE IF NOT EXISTS date (date_id INT PRIMARY KEY, date DATE, day INT, month INT, year INT);
CREATE TABLE IF NOT EXISTS store (store_id INT PRIMARY KEY, store_name VARCHAR, location VARCHAR);
CREATE TABLE IF NOT EXISTS sales (transaction_id INT PRIMARY KEY, product_id INT, customer_id INT, date_id INT, store_id INT, quantity INT, total_amount DECIMAL);

-- Move data from temporary tables to final tables
INSERT INTO product (product_id, product_name, category, price) SELECT product_id, product_name, category, price FROM product_temp;
INSERT INTO customer (customer_id, customer_name, email, location) SELECT customer_id, customer_name, email, location FROM customer_temp;
INSERT INTO date (date_id, date, day, month, year) SELECT date_id, CAST("date" AS DATE), day, month, year FROM date_temp;
INSERT INTO store (store_id, store_name, location) SELECT store_id, store_name, location FROM store_temp;
INSERT INTO sales (transaction_id, product_id, customer_id, date_id, store_id, quantity, total_amount) SELECT transaction_id, product_id, customer_id, date_id, store_id, quantity, total_amount FROM sales_temp;

-- Drop temporary tables
DROP TABLE IF EXISTS product_temp;
DROP TABLE IF EXISTS customer_temp;
DROP TABLE IF EXISTS date_temp;
DROP TABLE IF EXISTS store_temp;
DROP TABLE IF EXISTS sales_temp;
```

**Data Validation:**
```python
import psycopg2

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="ecommerce_data", user="postgres", password="root", host="localhost", port="5432"
)
cursor = conn.cursor()

# Function to run validation query
def validate_query(query):
    cursor.execute(query)
    return cursor.fetchone()[0]

# Check row counts
print("Number of rows in product table:", validate_query("SELECT COUNT(*) FROM product"))
print("Number of rows in customer table:", validate_query("SELECT COUNT(*) FROM customer"))
print("Number of rows in date table:", validate_query("SELECT COUNT(*) FROM date"))
print("Number of rows in store table:", validate_query("SELECT COUNT(*) FROM store"))
print("Number of rows in sales table:", validate_query("SELECT COUNT(*) FROM sales"))

# Close connection
cursor.close()
conn.close()
```

---

### Data Analysis SQL Queries
1. **Total Sales Amount Per Product Category:**
   ```sql
   SELECT p.category, SUM(s.total_amount) AS total_sales_amount
   FROM sales s
   JOIN product p ON s.product_id = p.product_id
   GROUP BY p.category
   ORDER BY total_sales_amount DESC;
   ```

2. **Top 3 Customers Based on Total Purchase Amount:**
   ```sql
   SELECT c.customer_name, SUM(s.total_amount) AS total_purchase_amount
   FROM sales s
   JOIN customer c ON s.customer_id = c.customer_id
   GROUP BY c.customer_name
   ORDER BY total_purchase_amount DESC
   LIMIT 3;
   ```

3. **Monthly Sales Trend for the First Quarter of 2024:**
   ```sql
   SELECT d.month, SUM(s.total_amount) AS monthly_sales_amount
   FROM sales s
   JOIN date d ON s.date_id = d.date_id
   WHERE d.year = 2024 AND d.month IN (1, 2, 3)
   GROUP BY d.month
   ORDER BY d.month;
   ```

4. **Total Quantity Sold Per Store:**
   ```sql
   SELECT st.store_name, SUM(s.quantity) AS total_quantity_sold
   FROM sales s
   JOIN store st ON s.store_id = st.store_id
   GROUP BY st.store_name
   ORDER BY total_quantity_sold DESC;
   ```

---

### Performance Optimization
**Indexing:**
```sql
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_date_id ON sales(date_id);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
```

**Partitioning:**
```sql
CREATE TABLE sales_partitioned (
    transaction_id INT,
    product_id INT,
    customer_id INT,
    date_id INT,
    store_id INT,
    quantity INT,
    total_amount DECIMAL
) PARTITION BY RANGE (date_id);

CREATE TABLE sales_2024 PARTITION OF sales_partitioned FOR VALUES FROM (20240101) TO (20241231);
```

**Denormalization:**
```sql
CREATE MATERIALIZED VIEW mv_sales_summary AS
SELECT

 product_id, customer_id, date_id, store_id, SUM(total_amount) AS total_sales
FROM sales
GROUP BY product_id, customer_id, date_id, store_id;
```

**Query Optimization:**
```sql
-- Avoid SELECT *:
SELECT transaction_id, total_amount FROM sales WHERE product_id = 1;

-- Use Joins Efficiently:
SELECT s.transaction_id, p.product_name
FROM sales s
JOIN product p ON s.product_id = p.product_id
WHERE s.date_id BETWEEN '2024-01-01' AND '2024-03-31';
```

---

### Reporting
**SQL Query for Reporting:**
```sql
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
```

**Export to Excel and Visualize using Python:**
Script file: `Reporting.py`
```python
import pandas as pd
import psycopg2
import matplotlib.pyplot as plt

# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="ecommerce_data", user="postgres", password="root", host="localhost", port="5432"
)
cursor = conn.cursor()

# Run query for report
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

# Fetch data into DataFrame
sales_report_df = pd.read_sql_query(query, conn)

# Close connection
cursor.close()
conn.close()

# Save DataFrame to Excel (optional)
sales_report_df.to_excel("sales_performance_report.xlsx", index=False)

# Create Pivot Table for Visualization
pivot_df = sales_report_df.pivot(index='store_name', columns='category', values='total_sales_amount')

# Create Bar Plot
pivot_df.plot(kind='bar', figsize=(12, 8))
plt.title('Sales Performance by Store and Product Category')
plt.xlabel('Store Name')
plt.ylabel('Total Sales Amount')
plt.legend(title='Product Category')
plt.tight_layout()
plt.show()
```
