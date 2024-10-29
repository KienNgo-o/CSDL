USE QLCT;

-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo FROM KyNang KN
INNER JOIN ChuyenGia_KyNang CGKN ON CGKN.MaKyNang=KN.MaKyNang
WHERE MaChuyenGia=1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM ChuyenGia_DuAn WHERE MaDuAn=2) 

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn FROM DuAn DA
INNER JOIN  CongTy CT ON CT.MaCongTy=DA.MaCongTy

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh,COUNT(MaChuyenGia) SLCG FROM ChuyenGia
GROUP BY ChuyenNganh

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT * FROM ChuyenGia
WHERE NamKinhNghiem=(SELECT MAX(NamKinhNghieM) FROM ChuyenGia)
-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) SLDA FROM ChuyenGia CG
INNER JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia=CGDA.MaChuyenGia
GROUP BY HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy,COUNT(MaDuAn) SLDA FROM CONGTY CT
INNER JOIN DuAn DA ON CT.MaCongTy=DA.MaCongTy
GROUP BY TenCongTy
-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TenKyNang, SL.SLCG FROM KyNang
INNER JOIN
(SELECT MaKyNang,COUNT(MaChuyenGia) SLCG FROM ChuyenGia_KyNang
GROUP BY MaKyNang
HAVING COUNT(MaChuyenGia)>=ALL(SELECT COUNT(SLK.MaChuyenGia) FROM ChuyenGia_KyNang SLK GROUP BY MaKyNang)
)AS SL
ON SL.MaKyNang=KyNang.MaKyNang


-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen  FROM ChuyenGia 
WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM ChuyenGia_KyNang
					  WHERE CapDo>=4
					  AND MaKyNang IN (SELECT MaKyNang FROM KyNang
									   WHERE TenKyNang='PyThon')
									   )

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TenDuAn FROM DuAn
INNER JOIN
(SELECT MaDuAn,COUNT(MaChuyenGia) SLCG FROM ChuyenGia_DuAn
GROUP BY MaDuAn
HAVING COUNT(MaChuyenGia)>=ALL(SELECT COUNT(SL.MaChuyenGia) FROM ChuyenGia_DuAn SL
GROUP BY MaDuAn)) AS SLN
ON SLN.MaDuAn=DuAn.MaDuAn

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT HoTen, COUNT(MaKyNang) SLKN FROM ChuyenGia_KyNang CGKN
INNER JOIN ChuyenGia CG ON CG.MaChuyenGia=CGKN.MaChuyenGia
GROUP BY HoTen
-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT 
    cgd1.MaChuyenGia AS MaChuyenGia1, 
    cg1.HoTen AS HoTen1, 
    cgd2.MaChuyenGia AS MaChuyenGia2, 
    cg2.HoTen AS HoTen2, 
    cgd1.MaDuAn, 
    da.TenDuAn
FROM 
    ChuyenGia_DuAn cgd1
JOIN 
    ChuyenGia_DuAn cgd2 ON cgd1.MaDuAn = cgd2.MaDuAn 
                       AND cgd1.MaChuyenGia < cgd2.MaChuyenGia
JOIN 
    ChuyenGia cg1 ON cgd1.MaChuyenGia = cg1.MaChuyenGia
JOIN 
    ChuyenGia cg2 ON cgd2.MaChuyenGia = cg2.MaChuyenGia
JOIN 
    DuAn da ON cgd1.MaDuAn = da.MaDuAn
ORDER BY 
    cgd1.MaDuAn, cgd1.MaChuyenGia, cgd2.MaChuyenGia;
-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT HoTen, COUNT(MaKyNang) SLKNC5 FROM ChuyenGia CG
INNER JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia=CG.MaChuyenGia
WHERE CGKN.CapDo=5
GROUP BY HoTen
-- 21. Tìm các công ty không có dự án nào.
SELECT * FROM CongTy
WHERE MaCongTy NOT IN (SELECT MaCongTy FROM DUAN)

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT HoTen, TenDuAn FROM ChuyenGia CG
LEFT OUTER JOIN 
(ChuyenGia_DuAn CGDA 
INNER JOIN DuAn DA ON DA.MaDuAn=CGDA.MaDuAn)
ON CGDA.MaChuyenGia=CG.MaChuyenGia
-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT HoTen FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia=CG.MaChuyenGia
GROUP BY HoTen
HAVING COUNT(MaKyNang)>=3

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(NamKinhNghiem) AS TONGKINHNGHIEM FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy=CT.MaCongTy
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn=DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia=CGDA.MaChuyenGia
GROUP BY TenCongTy

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT * FROM ChuyenGia CG
WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM ChuyenGia_KyNang
					  WHERE MaKyNang IN (SELECT MaKyNang FROM KyNang WHERE TenKyNang='Java')
					  )
EXCEPT
SELECT * FROM ChuyenGia CG
WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM ChuyenGia_KyNang
					  WHERE MaKyNang IN (SELECT MaKyNang FROM KyNang WHERE TenKyNang='Python')
					  )
-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT HOTEN, COUNT(MaKyNang) SLKNNN FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia=CG.MaChuyenGia
GROUP BY HOTEN
HAVING COUNT(MaKyNang)>=ALL (SELECT COUNT(MaKyNang) FROM ChuyenGia_KyNang GROUP BY MaChuyenGia)

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT 
    cg1.MaChuyenGia AS MaChuyenGia1, 
    cg1.HoTen AS HoTen1, 
    cg2.MaChuyenGia AS MaChuyenGia2, 
    cg2.HoTen AS HoTen2, 
    cg1.ChuyenNganh
FROM 
    ChuyenGia cg1
JOIN 
    ChuyenGia cg2 ON cg1.ChuyenNganh = cg2.ChuyenNganh 
                 AND cg1.MaChuyenGia < cg2.MaChuyenGia
ORDER BY 
    cg1.ChuyenNganh, cg1.MaChuyenGia, cg2.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TenCongTy FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy=CT.MaCongTy
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn=DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia=CGDA.MaChuyenGia
GROUP BY TenCongTy
HAVING SUM(NamKinhNghiem)>=ALL (SELECT SUM(NamKinhNghiem) AS TONGKINHNGHIEM FROM CongTy CT
								JOIN DuAn DA ON DA.MaCongTy=CT.MaCongTy
								JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn=DA.MaDuAn
								JOIN ChuyenGia CG ON CG.MaChuyenGia=CGDA.MaChuyenGia
								GROUP BY TenCongTy)
-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT KN.MaKyNang FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaKyNang=KN.MaKyNang
GROUP BY KN.MaKyNang
HAVING COUNT(MaChuyenGia) = (SELECT COUNT(MaChuyenGia) FROM ChuyenGia)





