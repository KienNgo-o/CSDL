USE QuanLyGiaoVu;
--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT * FROM KHOA
WHERE NGTLAP <= ALL (
    SELECT NGTLAP
        FROM KHOA
    )

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(*) AS SOGV FROM  GIAOVIEN
WHERE HOCHAM IN ('GS','PGS')
--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT MAKHOA, HOCVI , COUNT(*) AS SOGV FROM GIAOVIEN
GROUP BY MAKHOA, HOCVI ORDER BY MAKHOA
--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT DEM1.MAMH,SODAT,SOKHONGDAT FROM
             (
                SELECT MAMH, COUNT(DISTINCT MAHV) AS SODAT
                FROM KETQUATHI
                WHERE KQUA = 'DAT'
                GROUP BY MAMH
             ) AS DEM1
INNER JOIN
            (
                SELECT MAMH, COUNT(DISTINCT MAHV) AS SOKHONGDAT
                FROM KETQUATHI KQ1
                WHERE KQUA = 'KHONG DAT' AND MAHV NOT IN (
                    SELECT MAHV
                    FROM KETQUATHI KQ2
                    WHERE KQUA = 'DAT' AND KQ1.MAMH = KQ2.MAMH
                )
            GROUP BY MAMH) AS DEM2
ON  DEM1.MAMH = DEM2.MAMH
--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT DISTINCT MAGVCN,HOTEN FROM
    GIANGDAY INNER JOIN LOP ON GIANGDAY.MAGV = LOP.MAGVCN AND GIANGDAY.MALOP = LOP.MALOP
             INNER JOIN GIAOVIEN G on GIANGDAY.MAGV = G.MAGV
--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HO +' ' + TEN AS HOTEN
FROM HOCVIEN
INNER JOIN
(SELECT TOP 1 WITH TIES TRGLOP FROM LOP
ORDER BY SISO DESC) AS KQ
ON HOCVIEN.MAHV = KQ.TRGLOP
--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).

SELECT MAHV
FROM KETQUATHI KQ INNER JOIN  LOP L ON KQ.MAHV = L.TRGLOP
WHERE KQUA = 'KHONG DAT' AND NOT EXISTS(
        SELECT * FROM KETQUATHI KQ1
                 WHERE KQ.MAHV = KQ1.MAHV AND KQ1.KQUA = 'DAT'
    )
GROUP BY MAHV
HAVING COUNT(DISTINCT MAMH) >3

--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT TOP 1 WITH TIES H.MAHV, H.HO + ' '+  H.TEN AS HOTEN ,COUNT(*) AS SODIEM910
FROM KETQUATHI K INNER JOIN HOCVIEN H ON K.MAHV = H.MAHV
WHERE DIEM BETWEEN 9 AND 10
GROUP BY H.MAHV, HO,TEN
ORDER BY COUNT(*) DESC
--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT H.MAHV, H.HO + ' '+  H.TEN AS HOTEN ,COUNT(*) AS SODIEM910, MALOP
FROM KETQUATHI K INNER JOIN HOCVIEN H ON K.MAHV = H.MAHV
WHERE DIEM BETWEEN 9 AND 10
GROUP BY H.MAHV, HO,TEN,MALOP
HAVING COUNT(*) >= ALL (
        SELECT COUNT(*)
        FROM KETQUATHI K1 INNER JOIN HOCVIEN H1 ON K1.MAHV = H1.MAHV
        WHERE DIEM BETWEEN 9 AND 10 AND H.MALOP = H1.MALOP
        GROUP BY K1.MAHV, H1.MALOP
    )
--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT MAGV,NAM,HOCKY, COUNT(DISTINCT MAMH) AS SOMONPHANCONG, COUNT(MALOP) AS SOLOPPHANCONG
FROM GIANGDAY
GROUP BY MAGV, NAM, HOCKY

--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT MAGV,NAM,HOCKY, COUNT(*) AS SOLOPPHANCONG
FROM GIANGDAY G1
GROUP BY MAGV, NAM, HOCKY
HAVING COUNT(*) >= ALL (
        SELECT COUNT(*) AS SOLOPPHANCONG
        FROM GIANGDAY G2
        WHERE G1.HOCKY = G2.HOCKY AND G1.NAM = G2.NAM
        GROUP BY MAGV, NAM, HOCKY
    )
--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.

SELECT TOP 1 WITH TIES K.MAMH, TENMH
FROM KETQUATHI K INNER JOIN MONHOC M ON K.MAMH = M.MAMH
WHERE LANTHI = 1 AND KQUA = 'KHONG DAT'
GROUP BY K.MAMH, TENMH
ORDER BY COUNT(MAHV) DESC


--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT MAHV
FROM KETQUATHI K1
WHERE LANTHI = 1 AND KQUA = 'DAT' AND NOT EXISTS (
        SELECT *
        FROM KETQUATHI K2
        WHERE K2.KQUA = 'KHONG DAT' AND K1.MAHV = K2.MAHV
    )
GROUP BY MAHV
--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT DISTINCT MAHV
FROM KETQUATHI K1
WHERE NOT EXISTS(SELECT *
                 FROM KETQUATHI K2
                 WHERE K1.MAHV = K2.MAHV
                   AND K2.KQUA = 'KHONG DAT'
                   AND K2.LANTHI = (SELECT MAX(LANTHI)
                                    FROM KETQUATHI K3
                                    WHERE K2.MAHV = K3.MAHV
                                      AND K2.MAMH = K3.MAMH
                                    GROUP BY K3.MAHV, K3.MAMH))
--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1).
SELECT DISTINCT MAHV
FROM HOCVIEN H
WHERE NOT EXISTS(
    SELECT *
    FROM MONHOC m
    WHERE NOT EXISTS (
        SELECT *
        FROM KETQUATHI k
        WHERE k.MAMH = m.MAMH AND k.MAHV = h.MAHV AND KQUA = 'dat' AND LANTHI = 1
        )
)

--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng).
SELECT distinct MAHV
FROM HOCVIEN H
WHERE NOT EXISTS(select *
                 from MONHOC m
                 where not exists (select *
                                   from KETQUATHI k
                                   where k.MAMH = m.MAMH
                                     and k.MAHV = h.MAHV
                                     and KQUA = 'dat'
                                     and LANTHI = (select max(lanthi)
                                                   from KETQUATHI k1
                                                   where k1.MAHV = k.MAHV
                                                     and k.mamh = k1.MAmh)))
--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng)
SELECT *
FROM
    KETQUATHI k1
JOIN
(SELECT MAMH , MAX(diem) AS diem
FROM KETQUATHI
GROUP BY MAMH) AS kq
ON kq.MAMH = k1.MAMH and k1.DIEM = kq.diem
WHERE LANTHI = (
    SELECT MAX(lanthi)
    FROM KETQUATHI k2
    WHERE k1.MAMH = k2.MAMH and k1.mahv = k2.MAHV
    )