#!/bin/bash
set -e

echo ">>> Starting Cassandra..."
cassandra -R &

# Chờ Cassandra lên
echo ">>> Waiting for Cassandra to be ready..."
sleep 40

echo ">>> Running init.cql..."
cqlsh -f /init/init.cql

echo ">>> Importing CSV..."
cqlsh -e "COPY retail.customers (customerid, firstname, lastname, gender, birthdate, city, joindate) FROM '/init/customers.csv' WITH HEADER=TRUE;"
cqlsh -e "COPY retail.products (productid, productname, category, subcategory, unitprice, costprice) FROM '/init/products.csv' WITH HEADER=TRUE;"
cqlsh -e "COPY retail.stores (storeid, storename, city, region) FROM '/init/stores.csv' WITH HEADER=TRUE;"
cqlsh -e "COPY retail.transactions (transactionid, customerid, productid, storeid, quantity, totalamount, transactiondate) FROM '/init/transactions.csv' WITH HEADER=TRUE;"

echo ">>> All data imported. Cassandra is ready."

# Giữ container sống
tail -f /dev/null
