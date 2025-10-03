# Hướng Dẫn Khởi Động Docker Hive và Demo Truy Vấn HiveQL

## 1. Mô tả chung

Bộ công cụ này sử dụng **Apache Hive** chạy trong container Docker, phục vụ cho việc phân tích dữ liệu lớn dạng bảng, dựa trên file CSV mẫu. Bạn sẽ được hướng dẫn cách khởi động Hive, load dữ liệu, và chạy các truy vấn HiveQL cơ bản đến nâng cao.

---

## 2. Khởi động Hive bằng Docker Compose

1. **Chuẩn bị thư mục và dữ liệu:**

- Đảm bảo thư mục `./data` chứa các file dữ liệu:
  - `customers.csv`
  - `products.csv`
  - `stores.csv`
  - `transactions.csv`
  - `init.hql` (file chứa các câu lệnh tạo bảng và load dữ liệu)

2. **File `docker-compose.yml`:**

Đã có cấu hình sẵn cho 2 service:

- `hive-server`: chạy HiveServer2
- `hive-init`: chạy script khởi tạo dữ liệu bằng Beeline

3. **Khởi động dịch vụ:**

```bash
docker-compose up -d
````

4. **Kiểm tra container đang chạy:**

```bash
docker ps
```

Bạn sẽ thấy container `hive3` (hive-server) và `hive-init`.

---

## 3. Truy cập vào Hive để chạy truy vấn

1. Vào container HiveServer:

```bash
docker exec -it hive3 bash
```

2. Kết nối Beeline tới HiveServer2:

```bash
beeline -u jdbc:hive2://localhost:10000 -n hive
```

3. Ví dụ chạy truy vấn đơn giản:

```sql
SHOW TABLES;

SELECT * FROM customers LIMIT 10;

SELECT
  c.customerid,
  c.firstname,
  c.lastname,
  COUNT(t.transactionid) AS total_transactions,
  ROUND(SUM(t.quantity * (p.unitprice - t.discount)), 2) AS total_spent
FROM
  customers c
LEFT JOIN
  transactions t ON c.customerid = t.customerid
LEFT JOIN
  products p ON t.productid = p.productid
GROUP BY
  c.customerid, c.firstname, c.lastname
ORDER BY
  total_spent DESC
LIMIT 10;
```

4. Thoát Beeline:

```sql
!quit
```

5. Thoát container:

```bash
exit
```

---

## 4. Một số truy vấn demo khác

* Đếm số khách hàng theo giới tính:

```sql
SELECT gender, COUNT(*) FROM customers GROUP BY gender;
```

* Tổng số sản phẩm đã bán theo từng sản phẩm:

```sql
SELECT productid, SUM(quantity) AS total_sold
FROM transactions
GROUP BY productid
ORDER BY total_sold DESC;
```
---

## 5. Kết luận

* **Hive** thích hợp cho các bài toán phân tích dữ liệu lớn, báo cáo tổng hợp, OLAP, xử lý batch với dữ liệu dạng bảng.
* **Cassandra** thích hợp với các ứng dụng cần xử lý dữ liệu tốc độ cao, phân tán và sẵn sàng chịu lỗi như hệ thống thời gian thực, lưu trữ log, IoT.

Bạn có thể kết hợp cả hai tùy nhu cầu: Dữ liệu ghi nhanh bằng Cassandra, xử lý và phân tích batch bằng Hive.