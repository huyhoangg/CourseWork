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

* Top 5 sản phẩm bán chạy nhất (tính theo số lượng):

```sql
SELECT
  p.productid,
  p.productname,
  SUM(t.quantity) AS total_quantity_sold
FROM
  transactions t
JOIN
  products p ON t.productid = p.productid
GROUP BY
  p.productid, p.productname
ORDER BY
  total_quantity_sold DESC
LIMIT 5;
```

* Số lượng khách hàng theo thành phố

```sql
SELECT
  city,
  COUNT(DISTINCT customerid) AS total_customers
FROM
  customers
GROUP BY
  city
ORDER BY
  total_customers DESC;
```

---

### 5. **Top 5 khách hàng chi tiêu nhiều nhất trong một cửa hàng cụ thể (VD: `storeid = 'S001'`)**

```sql
SELECT
  c.customerid,
  c.firstname,
  c.lastname,
  ROUND(SUM(t.quantity * (p.unitprice - t.discount)), 2) AS total_spent
FROM
  transactions t
JOIN
  customers c ON t.customerid = c.customerid
JOIN
  products p ON t.productid = p.productid
WHERE
  t.storeid = 'S001'
GROUP BY
  c.customerid, c.firstname, c.lastname
ORDER BY
  total_spent DESC
LIMIT 5;
```
---

* Tỷ lệ sử dụng phương thức thanh toán

```sql
SELECT
  paymentmethod,
  COUNT(*) AS total_transactions,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM
  transactions
GROUP BY
  paymentmethod;
```

---

---

# Hive Demo — Phân Tích Dữ Liệu Giao Dịch `bank.csv`

> **Tập dữ liệu**: `bank.csv` (5 cột)



## 3. Xem thử dữ liệu

```sql
SELECT * FROM bank LIMIT 10;
```

---

## 4. Tổng quan dữ liệu

### 4.1 Tổng số giao dịch và tổng giá trị

```sql
SELECT 
  SUM(tx_count) AS total_transactions,
  ROUND(SUM(value), 2) AS total_value
FROM bank;
```
---

## 5. Phân tích theo thời gian

### Tổng giao dịch theo tháng


```sql
SELECT
  FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM') AS month,
  SUM(tx_count) AS total_transactions,
  ROUND(SUM(value), 2) AS total_value
FROM bank
GROUP BY FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM')
ORDER BY month;
```

---

### 5.2 Tăng trưởng giá trị giao dịch qua từng tháng

```sql
WITH monthly AS (
  SELECT
    FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM') AS month,
    SUM(value) AS total_value
  FROM bank
  GROUP BY FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM')
)
SELECT
  month,
  total_value,
  LAG(total_value) OVER (ORDER BY month) AS prev_value,
  ROUND(
    (total_value - LAG(total_value) OVER (ORDER BY month)) 
    / LAG(total_value) OVER (ORDER BY month) * 100,
    2
  ) AS growth_percent
FROM monthly;
```

---

## 6. Phân tích theo `domain`

### 6.1 Top 5 domain có giá trị giao dịch lớn nhất

```sql
SELECT
  domain,
  ROUND(SUM(value), 2) AS total_value
FROM bank
GROUP BY domain
ORDER BY total_value DESC
LIMIT 5;
```

---

### 6.2 Tỷ trọng mỗi domain theo tháng

```sql
WITH monthly_totals AS (
  SELECT
    FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM') AS month,
    domain,
    SUM(value) AS domain_value
  FROM bank
  GROUP BY FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM'), domain
),
total_per_month AS (
  SELECT
    month,
    SUM(domain_value) AS total_value
  FROM monthly_totals
  GROUP BY month
)
SELECT
  m.month,
  m.domain,
  ROUND(m.domain_value, 2) AS domain_value,
  ROUND((m.domain_value / t.total_value) * 100, 2) AS contribution_percent
FROM
  monthly_totals m
JOIN
  total_per_month t ON m.month = t.month
ORDER BY
  m.month, contribution_percent DESC;
```

---

### 6.3 Xếp hạng domain theo giá trị giao dịch mỗi tháng

```sql
SELECT
  month,
  domain,
  domain_value,
  RANK() OVER (PARTITION BY month ORDER BY domain_value DESC) AS domain_rank
FROM (
  SELECT
    FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM') AS month,
    domain,
    SUM(value) AS domain_value
  FROM bank
  GROUP BY FROM_UNIXTIME(UNIX_TIMESTAMP(tx_date, 'MM/dd/yyyy'), 'yyyy-MM'), domain
) t
ORDER BY month, domain_rank;
```

## 🧾 Kết luận

* Dữ liệu `bank.csv` là một ví dụ đơn giản nhưng thực tế cho phân tích giao dịch
* Hive + HiveQL có thể truy vấn, tổng hợp, xếp hạng và tính tỷ trọng dễ dàng
* Có thể mở rộng demo này với visualization (Superset, Tableau, etc.)

---

## 📦 Bonus: Xuất kết quả sang CSV

```sql
INSERT OVERWRITE LOCAL DIRECTORY '/output/bank_summary'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT domain, SUM(value) FROM bank GROUP BY domain;
```

---

Nếu bạn muốn mình chuyển kịch bản này thành **file `.md` thực tế** hoặc tích hợp luôn với **Jupyter Notebook Hive**, mình có thể giúp tiếp. Cần không?




Nếu bạn cần **tạo dashboard**, bạn có thể kết hợp Hive với **Apache Superset**, **Tableau**, hoặc dùng **Beeline + terminal** để hiển thị bảng cho demo.

Bạn muốn mình gợi ý thêm query theo hướng nào? (VD: theo thời gian, phân tích theo giới tính, khu vực, v.v.)



---

## 5. Kết luận

* **Hive** thích hợp cho các bài toán phân tích dữ liệu lớn, báo cáo tổng hợp, OLAP, xử lý batch với dữ liệu dạng bảng.
* **Cassandra** thích hợp với các ứng dụng cần xử lý dữ liệu tốc độ cao, phân tán và sẵn sàng chịu lỗi như hệ thống thời gian thực, lưu trữ log, IoT.

Bạn có thể kết hợp cả hai tùy nhu cầu: Dữ liệu ghi nhanh bằng Cassandra, xử lý và phân tích batch bằng Hive.