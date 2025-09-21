#!/bin/bash
set -e

echo "Running schema + import..."

cqlsh cassandra-node1 -f /init/init.cql

cqlsh cassandra-node1 -e "COPY retail.customers (customerid, firstname, lastname, gender, birthdate, city, joindate) FROM '/init/customers.csv' WITH HEADER=TRUE;"
cqlsh cassandra-node1 -e "COPY retail.products (productid, productname, category, subcategory, unitprice, costprice) FROM '/init/products.csv' WITH HEADER=TRUE;"
cqlsh cassandra-node1 -e "COPY retail.stores (storeid, storename, city, region) FROM '/init/stores.csv' WITH HEADER=TRUE;"
cqlsh cassandra-node1 -e "COPY retail.transactions (transactionid, date, customerid, productid, storeid, quantity, discount, paymentmethod) FROM '/init/transactions.csv' WITH HEADER=TRUE;"
