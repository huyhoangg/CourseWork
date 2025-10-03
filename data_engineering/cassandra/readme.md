# Cassandra Cluster Demo – Quick Start

Hướng dẫn khởi chạy Cassandra 3 node bằng Docker Compose và thực hiện các thao tác để **trình bày ưu điểm và nhược điểm** của Cassandra trong môi trường phân tán.

## 0. Kien truc tong quan Cassandra Cluster


                   +----------------------+
                   |   Ứng dụng (Client)  |
                   +----------+-----------+
                              |
                              v
               +--------------+--------------+
               |  Cassandra Cluster (3 Node) |
               +--------------+--------------+
                              |
     +----------------+       |       +----------------+
     |  cassandra-node1|<----->----->|  cassandra-node2|
     +----------------+       |       +----------------+
               ^              |              ^
               |              |              |
               +--------------+--------------+
                              |
                     +----------------+
                     | cassandra-node3|
                     +----------------+

                <--> Các node đồng bộ dữ liệu qua nhau peer-to-peer

---

## 1. Khởi động dịch vụ Cassandra Cluster

```bash
docker compose up -d
```

##  2. Dừng toàn bộ dịch vụ

```bash
docker compose down -v
```

## 3. Import schema và dữ liệu mẫu
File init/init.cql chứa schema
Lệnh import data từ file init.sh

Dữ liệu CSV đặt trong thư mục ./init/:
- customers.csv
- products.csv
- stores.csv
- transactions.csv

docker-compose da import du lieu mock test


## 4. Kiểm tra dữ liệu & Query thử
```bash
# Truy cập cqlsh của từng node:
docker exec -it cassandra-node1 cqlsh
docker exec -it cassandra-node2 cqlsh
docker exec -it cassandra-node3 cqlsh

# Chạy các câu lệnh SELECT cơ bản:
USE retail;

SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM stores LIMIT 5;
SELECT * FROM transactions LIMIT 5;
```

## Câu query phức tạp sẽ lỗi (điểm yếu của Cassandra):
-- Cassandra không hỗ trợ GROUP BY truyền thống

```bash
SELECT productid, COUNT(*) AS sales
FROM transactions
GROUP BY productid
LIMIT 5;
```
-- Cassandra không hỗ trợ aggregation nâng cao

```bash
SELECT dateOf(date) AS day, SUM(quantity) AS total_sales
FROM transactions
GROUP BY dateOf(date);
```



## 5. Kiểm tra trạng thái cluster

```bash
# Trạng thái các node
docker exec -it cassandra-node1 nodetool status

# Gossip giữa các node
docker exec -it cassandra-node1 nodetool gossipinfo

```

## 6. Kiểm tra tính replication và dữ liệu trên từng node

```bash
docker exec -it cassandra-node1 cqlsh -e "SELECT * FROM retail.customers LIMIT 3;"
docker exec -it cassandra-node2 cqlsh -e "SELECT * FROM retail.customers LIMIT 3;"
docker exec -it cassandra-node3 cqlsh -e "SELECT * FROM retail.customers LIMIT 3;"

```

## 7. Mô phỏng khả năng chịu lỗi

```bash
# gia lap su co
docker stop cassandra-node2

# du lieu van query duoc
docker exec -it cassandra-node1 cqlsh -e "SELECT * FROM retail.customers LIMIT 3;"

# gia lap khi node hoi phuc
docker start cassandra-node2

# kiem tra du lieu tren node do
docker exec -it cassandra-node2 cqlsh -e "SELECT * FROM retail.customers LIMIT 3;"

```

## 9. Tổng kết demo Cassandra

### Ưu điểm Cassandra

| Ưu điểm                    | Demo thể hiện                                         |
|----------------------------|-------------------------------------------------------|
| Khả năng mở rộng ngang     | Thêm node mới mà không cần downtime                   |
| Replication tự động        | Dữ liệu tự sao chép sang các node khác                |
| Chịu lỗi tốt               | Node bị tắt không ảnh hưởng truy vấn                  |
| Luôn sẵn sàng              | Tự động failover, không có single point of failure    |

### Nhược điểm Cassandra

| Nhược điểm                 | Minh họa                                               |
|----------------------------|--------------------------------------------------------|
| Không hỗ trợ JOIN          | Không thể JOIN nhiều bảng như SQL truyền thống         |
| Không hỗ trợ GROUP BY      | Các query aggregation phức tạp không dùng được         |
| Không ACID                 | Không phù hợp       |
