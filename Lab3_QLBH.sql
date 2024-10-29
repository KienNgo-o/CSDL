USE QuanLyBanHang;
--CAU 12 PHAN III QUANLYBANHANG
(SELECT SOHD FROM CTHD
WHERE MASP='BB01' AND SL BETWEEN 10 AND 20)
UNION
(SELECT SOHD FROM CTHD
WHERE MASP='BB02' AND SL BETWEEN 10 AND 20);

--CAU 13 PHAN III QUANLYBANHANG
(SELECT SOHD FROM CTHD
WHERE MASP='BB01' AND SL BETWEEN 10 AND 20)
INTERSECT
(SELECT SOHD FROM CTHD
WHERE MASP='BB02' AND SL BETWEEN 10 AND 20);


--Bai 14
--C1
SELECT DISTINCT SP.MASP, TENSP
FROM SANPHAM SP
     left join
     (SELECT MASP, NGHD
      FROM CTHD C
               INNER JOIN
           HOADON H on C.SOHD = H.SOHD) as CHM ON SP.MASP = CHM.MASP
WHERE NUOCSX = 'Trung Quoc'
   OR NGHD = '2007-01-01';
--C2
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX='Trung Quoc' 
OR MASP IN ( SELECT MASP FROM CTHD
			WHERE SOHD IN ( SELECT SOHD FROM HOADON
							WHERE NGHD = '2007-01-01')
			)

--Bai 15

SELECT SP.MASP, TENSP
FROM SANPHAM SP
         INNER JOIN
     (SELECT MASP
      FROM SANPHAM
      EXCEPT
      SELECT DISTINCT MASP
      FROM CTHD) AS SPCT
     ON SP.MASP = SPCT.MASP;

--Bai 16
SELECT SP.MASP, TENSP
FROM SANPHAM SP
         INNER JOIN
     (SELECT MASP
      FROM SANPHAM
      EXCEPT
      SELECT DISTINCT C.MASP
      FROM (
               CTHD C
                   INNER JOIN
                   HOADON H
               ON C.SOHD = H.SOHD
               )
      WHERE YEAR(NGHD) = '2006') AS SPCT
     ON SP.MASP = SPCT.MASP;

--Bai 17

SELECT SP.MASP, TENSP
FROM SANPHAM SP
         INNER JOIN
     (SELECT MASP
      FROM SANPHAM
      WHERE NUOCSX = 'Trung Quoc'
      EXCEPT
      SELECT DISTINCT C.MASP
      FROM (
               CTHD C
                   INNER JOIN
                   HOADON H
               ON C.SOHD = H.SOHD
               )
      WHERE YEAR(NGHD) = '2006') AS SPCT
     ON SP.MASP = SPCT.MASP;

--Bai 18
WITH SingaporeProducts AS (
    SELECT MASP
    FROM SANPHAM
    WHERE NUOCSX = 'Singapore'
),
InvoiceProductCounts AS (
    SELECT h.SOHD, COUNT(DISTINCT c.MASP) AS ProductCount
    FROM HOADON h
    JOIN CTHD c ON h.SOHD = c.SOHD
    JOIN SingaporeProducts sp ON c.MASP = sp.MASP
    GROUP BY h.SOHD
),
TotalSingaporeProducts AS (
    SELECT COUNT(*) AS TotalProducts
    FROM SingaporeProducts
)
SELECT h.SOHD AS Số_Hóa_Đơn
FROM InvoiceProductCounts ipc
JOIN TotalSingaporeProducts tsp ON ipc.ProductCount = tsp.TotalProducts
JOIN HOADON h ON ipc.SOHD = h.SOHD
WHERE YEAR(h.NGHD) = 2006;