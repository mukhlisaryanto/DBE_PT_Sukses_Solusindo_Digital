# Jalankan perintah berikut di command line atau terminal untuk menginstal dependencies yang diperlukan dari file requirements.txt:
# pip install -r requirements.txt

import pandas as pd
import psycopg2

# Baca file Excel
excel_file = r"./ecommerce_data.xlsx"
sheets = ['product', 'customer', 'date', 'store', 'sales']

# Membaca setiap sheet ke dalam DataFrame
dfs = {sheet: pd.read_excel(excel_file, sheet_name=sheet) for sheet in sheets}

# Koneksi ke PostgreSQL
try:
    conn = psycopg2.connect(
        dbname="ecommerce_data",
        user="postgres",
        password="root",
        host="localhost",
        port="5432"
    )
    cursor = conn.cursor()
    print("Koneksi ke database berhasil.")
except Exception as e:
    print(f"Error saat menghubungkan ke database: {e}")

# Fungsi untuk menentukan tipe data SQL berdasarkan tipe data pandas
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

# Fungsi untuk memuat DataFrame ke tabel PostgreSQL
def load_to_postgres(df, table_name):
    csv_file = f'{table_name}.csv'
    # Simpan DataFrame sebagai CSV sementara
    df.to_csv(csv_file, index=False, header=False)
    print(f"DataFrame disimpan sebagai {csv_file}")

    # Muat data ke PostgreSQL
    try:
        with open(csv_file, 'r') as f:
            cursor.copy_expert(f"COPY {table_name} FROM STDIN WITH CSV", f)
        conn.commit()
        print(f"Data dimuat ke tabel {table_name}")
    except Exception as e:
        print(f"Error saat memuat data ke tabel {table_name}: {e}")

# Membuat tabel sementara dan memuat data
for sheet, df in dfs.items():
    temp_table = f"{sheet}_temp"
    df.columns = map(str.lower, df.columns)  # Pastikan kolom dalam huruf kecil
    # Buat tabel sementara (sesuaikan tipe data jika diperlukan)
    cursor.execute(f"DROP TABLE IF EXISTS {temp_table}")
    create_table_sql = f"""
    CREATE TABLE {temp_table} (
        {', '.join([f'{col} {get_sql_type(df[col].dtype)}' for col in df.columns])}
    )
    """
    print(f"Membuat tabel: {create_table_sql}")
    cursor.execute(create_table_sql)
    conn.commit()

    # Muat data ke tabel sementara
    load_to_postgres(df, temp_table)

# Tutup koneksi
cursor.close()
conn.close()
print("Proses selesai.")
