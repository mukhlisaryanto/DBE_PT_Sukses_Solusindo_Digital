CREATE DATABASE ecommerce_data;

\c ecommerce_data_copy

CREATE TABLE  IF NOT EXISTS "sales" (
  "transaction_id" int PRIMARY KEY,
  "product_id" int,
  "customer_id" int,
  "date_id" int,
  "store_id" int,
  "quantity" int,
  "total_amount" decimal
);

CREATE TABLE  IF NOT EXISTS "product" (
  "product_id" int PRIMARY KEY,
  "product_name" varchar,
  "category" varchar,
  "price" decimal
);

CREATE TABLE  IF NOT EXISTS "customer" (
  "customer_id" int PRIMARY KEY,
  "customer_name" varchar,
  "email" varchar,
  "location" varchar
);

CREATE TABLE  IF NOT EXISTS "date" (
  "date_id" int PRIMARY KEY,
  "date" date,
  "day" int,
  "month" int,
  "year" int
);

CREATE TABLE  IF NOT EXISTS "store" (
  "store_id" int PRIMARY KEY,
  "store_name" varchar,
  "location" varchar
);

ALTER TABLE "sales" ADD FOREIGN KEY ("product_id") REFERENCES "product" ("product_id");
ALTER TABLE "sales" ADD FOREIGN KEY ("customer_id") REFERENCES "customer" ("customer_id");
ALTER TABLE "sales" ADD FOREIGN KEY ("date_id") REFERENCES "date" ("date_id");
ALTER TABLE "sales" ADD FOREIGN KEY ("store_id") REFERENCES "store" ("store_id");
