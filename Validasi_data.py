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

# Fungsi untuk menjalankan query validasi
def validate_query(query):
    cursor.execute(query)
    return cursor.fetchone()[0]

# 1. Periksa Jumlah Baris
print("Jumlah baris di tabel product:", validate_query("SELECT COUNT(*) FROM product"))
print("Jumlah baris di tabel customer:", validate_query("SELECT COUNT(*) FROM customer"))
print("Jumlah baris di tabel date:", validate_query("SELECT COUNT(*) FROM date"))
print("Jumlah baris di tabel store:", validate_query("SELECT COUNT(*) FROM store"))
print("Jumlah baris di tabel sales:", validate_query("SELECT COUNT(*) FROM sales"))

# 2. Periksa Data Sampel
def sample_data(table_name, limit=5):
    cursor.execute(f"SELECT * FROM {table_name} LIMIT {limit}")
    return cursor.fetchall()

print("Sampel data dari tabel product:")
for row in sample_data("product"):
    print(row)

print("Sampel data dari tabel customer:")
for row in sample_data("customer"):
    print(row)

print("Sampel data dari tabel date:")
for row in sample_data("date"):
    print(row)

print("Sampel data dari tabel store:")
for row in sample_data("store"):
    print(row)

print("Sampel data dari tabel sales:")
for row in sample_data("sales"):
    print(row)

# Tutup koneksi
cursor.close()
conn.close()
