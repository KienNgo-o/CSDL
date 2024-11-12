USE QuanLyBanHang;
--19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(*) AS SoHoaDonKhongPhaiCuaKHDK FROM HOADON WHERE MAKH IS NULL

--20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(*) AS SANPHAMKHACNHAU FROM CTHD
WHERE SOHD IN (SELECT SOHD FROM HOADON WHERE YEAR(NGHD)=2006)
--21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
SELECT MAX(TRIGIA) AS TRIGIACAONHAT FROM HOADON
SELECT MIN(TRIGIA) AS TRIGIATHAPNHAT FROM HOADON
--22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) AS TRIGIATRUNGBINHNAM2006 FROM HOADON
WHERE YEAR(NGHD)=2006
--23. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) AS DOANHTHUNAM2006 FROM HOADON
WHERE YEAR(NGHD)=2006
--24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT MAX(TRIGIA) AS TRIGIACAONHAT2006 FROM HOADON
WHERE YEAR(NGHD)=2006
--25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT HOTEN FROM KHACHHANG
WHERE MAKH IN (SELECT MAKH FROM HOADON
			   WHERE TRIGIA IN (SELECT MAX(TRIGIA) AS TRIGIACAONHAT2006 FROM HOADON
								WHERE YEAR(NGHD)=2006))
--26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT TOP 3 HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC
--27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT TOP 3 MASP,TENSP FROM SANPHAM
ORDER BY GIA DESC
--28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP,TENSP
FROM SANPHAM
WHERE NUOCSX='THAI LAN' AND GIA IN(
    SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC
    )

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP FROM SANPHAM
WHERE NUOCSX='Trung Quoc'
AND GIA IN(
    SELECT DISTINCT TOP 3 GIA FROM SANPHAM 
	WHERE NUOCSX='Trung Quoc'
    )
	ORDER BY GIA DESC
--30. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC
--31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(*) AS 'So san pham' FROM SANPHAM WHERE NUOCSX = 'TRUNG QUOC'
--32. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX,COUNT(*) AS 'So san pham' FROM SANPHAM
GROUP BY NUOCSX
--33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX, MAX(GIA) AS CAONHAT, MIN(GIA) AS THAPNHAT,AVG(GIA) TRUNGBINH
FROM SANPHAM
GROUP BY NUOCSX
--34. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD,SUM(TRIGIA) AS DOANHTHU
FROM HOADON
GROUP BY NGHD
ORDER BY NGHD ASC

--35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT MASP,SUM(SL) AS SOLUONG FROM CTHD
WHERE SOHD IN (SELECT SOHD FROM HOADON
               WHERE MONTH(NGHD)=10 AND YEAR(NGHD)=2006)
GROUP BY MASP

--36. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD),SUM(TRIGIA) AS DOANHTHU FROM HOADON
WHERE YEAR(NGHD)=2006
GROUP BY MONTH(NGHD)

--37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD
FROM CTHD
GROUP BY SOHD
HAVING COUNT(*) >= 4 

--38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD
FROM CTHD C JOIN SANPHAM S  ON C.MASP = S.MASP
WHERE NUOCSX = 'VIET NAM'
GROUP BY SOHD
HAVING COUNT(C.MASP) = 3

--39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT H.MAKH , HOTEN
FROM HOADON H JOIN KHACHHANG K on H.MAKH = K.MAKH
GROUP BY H.MAKH, HOTEN
HAVING COUNT(SOHD) >= ALL(
    SELECT COUNT(SOHD) FROM HOADON GROUP BY MAKH
    )

--40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT MONTH(NGHD) THANGDOANHSOCAONHAT FROM HOADON
WHERE YEAR(NGHD)=2006
GROUP BY MONTH(NGHD)
HAVING SUM(TRIGIA) >= ALL(SELECT SUM(TRIGIA) FROM HOADON
						  WHERE YEAR(NGHD)=2006
						  GROUP BY MONTH(NGHD)
						  )
SELECT TOP 1 WITH TIES MONTH(NGHD) AS THANG
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY  SUM(TRIGIA) DESC
--41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT CT.MASP, TENSP FROM CTHD CT
JOIN SANPHAM SP ON SP.MASP=CT.MASP
WHERE SOHD IN (SELECT SOHD FROM HOADON WHERE YEAR(NGHD)=2006)
GROUP BY CT.MASP, TENSP
HAVING SUM(SL)<=ALL(SELECT SUM(SL) FROM CTHD
					GROUP BY MASP)

--42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT SANPHAM.NUOCSX, MASP,TENSP, GIA
FROM SANPHAM
JOIN
(SELECT NUOCSX, MAX(GIA) AS GIACAONHAT
FROM SANPHAM
GROUP BY NUOCSX) AS CAONHAT
ON CAONHAT.NUOCSX = SANPHAM.NUOCSX AND GIA =GIACAONHAT
--43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(GIA) >= 3

--44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
SELECT TOP 1 MAKH FROM HOADON
WHERE MAKH IN (SELECT TOP 10 MAKH FROM KHACHHANG
			   
			   ORDER BY DOANHSO DESC)
GROUP BY MAKH
ORDER BY COUNT(SOHD) DESC


