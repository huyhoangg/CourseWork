CREATE KEYSPACE IF NOT EXISTS retail
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3};

USE retail;


CREATE TABLE IF NOT EXISTS customers (
    customerid text PRIMARY KEY,
    firstname text,
    lastname text,
    gender text,
    birthdate date,
    city text,
    joindate date
);

CREATE TABLE IF NOT EXISTS products (
    productid text PRIMARY KEY,
    productname text,
    category text,
    subcategory text,
    unitprice decimal,
    costprice decimal
);

CREATE TABLE IF NOT EXISTS stores (
    storeid text PRIMARY KEY,
    storename text,
    city text,
    region text
);

CREATE TABLE IF NOT EXISTS transactions (
    transactionid text PRIMARY KEY,
    date date,
    customerid text,
    productid text,
    storeid text,
    quantity int,
    discount decimal,
    paymentmethod text
);

