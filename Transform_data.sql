-- Buat tabel akhir jika belum ada
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

CREATE TABLE IF NOT EXISTS sales (
  transaction_id INT PRIMARY KEY,
  product_id INT,
  customer_id INT,
  date_id INT,
  store_id INT,
  quantity INT,
  total_amount DECIMAL
);

-- Pindahkan data dari tabel sementara ke tabel akhir
INSERT INTO product (product_id, product_name, category, price)
SELECT product_id, product_name, category, price FROM product_temp;

INSERT INTO customer (customer_id, customer_name, email, location)
SELECT customer_id, customer_name, email, location FROM customer_temp;

INSERT INTO date (date_id, date, day, month, year)
SELECT date_id, CAST("date" AS DATE), day, month, year FROM date_temp;

INSERT INTO store (store_id, store_name, location)
SELECT store_id, store_name, location FROM store_temp;

INSERT INTO sales (transaction_id, product_id, customer_id, date_id, store_id, quantity, total_amount)
SELECT transaction_id, product_id, customer_id, date_id, store_id, quantity, total_amount FROM sales_temp;

-- Hapus tabel sementara
DROP TABLE IF EXISTS product_temp;
DROP TABLE IF EXISTS customer_temp;
DROP TABLE IF EXISTS date_temp;
DROP TABLE IF EXISTS store_temp;
DROP TABLE IF EXISTS sales_temp;
