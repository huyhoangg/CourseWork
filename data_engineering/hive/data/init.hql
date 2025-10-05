-- Tạo bảng customers
CREATE EXTERNAL TABLE IF NOT EXISTS customers (
  customerid STRING,
  firstname STRING,
  lastname STRING,
  gender STRING,
  birthdate STRING,
  city STRING,
  joindate STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/customers';

LOAD DATA LOCAL INPATH '/init/customers.csv' INTO TABLE customers;


-- Tạo bảng products
CREATE EXTERNAL TABLE IF NOT EXISTS products (
  productid STRING,
  productname STRING,
  category STRING,
  subcategory STRING,
  unitprice DECIMAL(10,2),
  costprice DECIMAL(10,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/products';

LOAD DATA LOCAL INPATH '/init/products.csv' INTO TABLE products;


-- Tạo bảng stores
CREATE EXTERNAL TABLE IF NOT EXISTS stores (
  storeid STRING,
  storename STRING,
  city STRING,
  region STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/stores';

LOAD DATA LOCAL INPATH '/init/stores.csv' INTO TABLE stores;


-- Tạo bảng transactions
CREATE EXTERNAL TABLE IF NOT EXISTS transactions (
  transactionid STRING,
  `date` STRING,
  customerid STRING,
  productid STRING,
  storeid STRING,
  quantity INT,
  discount DECIMAL(10,2),
  paymentmethod STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/transactions';

LOAD DATA LOCAL INPATH '/init/transactions.csv' INTO TABLE transactions;



CREATE EXTERNAL TABLE IF NOT EXISTS bank (
  tx_date STRING,        
  domain STRING,
  location STRING,
  value DECIMAL(18,2),
  tx_count INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/bank';
LOAD DATA LOCAL INPATH '/init/bank.csv' INTO TABLE bank;
