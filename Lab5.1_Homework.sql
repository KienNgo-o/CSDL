USE QLCT;
-- Câu hỏi và ví dụ về Triggers (101-110)

-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
-- Thêm cột NgayCapNhat vào bảng ChuyenGia
ALTER TABLE ChuyenGia ADD NgayCapNhat DATE;

-- Tạo trigger để cập nhật NgayCapNhat
CREATE TRIGGER trg_UpdateNgayCapNhat
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    UPDATE ChuyenGia
    SET NgayCapNhat = GETDATE()
    FROM inserted
    WHERE ChuyenGia.MaChuyenGia = inserted.MaChuyenGia;
END;

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TABLE DuAn_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaDuAn INT,
    TenDuAn NVARCHAR(200),
    MaCongTy INT,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    TrangThai NVARCHAR(50),
    NgayThayDoi DATETIME,
    HanhDong NVARCHAR(50)
);
CREATE TRIGGER trg_LogDuAnChanges
ON DuAn
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Ghi log cho các hành động INSERT
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO DuAn_Log(MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, NgayThayDoi, HanhDong)
        SELECT MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, GETDATE(), 'INSERT'
        FROM inserted;
    END

    -- Ghi log cho các hành động UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO DuAn_Log (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, NgayThayDoi, HanhDong)
        SELECT MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, GETDATE(), 'UPDATE'
        FROM inserted;
    END

    -- Ghi log cho các hành động DELETE
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO DuAn_Log (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, NgayThayDoi, HanhDong)
        SELECT MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai, GETDATE(), 'DELETE'
        FROM deleted;
    END
END;

-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_C103 ON CHUYENGIA_DUAN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MACHUYENGIA INT
	DECLARE @SLDA INT

	SELECT @MACHUYENGIA=MACHUYENGIA FROM inserted

	SELECT @SLDA=COUNT(*) FROM ChuyenGia_DuAn WHERE @MACHUYENGIA=MaChuyenGia
	IF(@SLDA>5)
	BEGIN
		PRINT 'THEM KHONG THANH CONG'
		ROLLBACK TRAN
	END
END
-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
ALTER TABLE ChuyenGia ADD MaCongTy INT;

CREATE TRIGGER trg_UpdateSoNhanVien
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Cập nhật số lượng nhân viên sau khi chèn bản ghi mới
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        UPDATE CongTy
        SET SoNhanVien = (SELECT COUNT(*) FROM ChuyenGia WHERE MaCongTy = inserted.MaCongTy)
        FROM inserted
        WHERE CongTy.MaCongTy = inserted.MaCongTy;
    END

    -- Cập nhật số lượng nhân viên sau khi xóa bản ghi
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE CongTy
        SET SoNhanVien = (SELECT COUNT(*) FROM ChuyenGia WHERE MaCongTy = deleted.MaCongTy)
        FROM deleted
        WHERE CongTy.MaCongTy = deleted.MaCongTy;
    END
END;
-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER trg_C105 ON DUAN
FOR DELETE
AS
BEGIN
	DECLARE @MADUAN INT
	DECLARE @TRANGTHAI NVARCHAR(50)

	SELECT @MADUAN=MADUAN FROM deleted
	SELECT @TRANGTHAI=TRANGTHAI FROM deleted
	IF(@TRANGTHAI=N'Hoàn thành')
	BEGIN
		PRINT'XOA KHONG THANH CONG'
		ROLLBACK TRAN
	END
END

-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.
CREATE TRIGGER trg_UpdateSkillLevel
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    DECLARE @MaDuAn INT;

    -- Lấy mã chuyên gia và mã dự án từ bản ghi vừa được chèn
    SELECT @MaChuyenGia = inserted.MaChuyenGia, @MaDuAn = inserted.MaDuAn
    FROM inserted;

    -- Giả sử mỗi lần tham gia dự án mới, cấp độ kỹ năng của chuyên gia tăng thêm 1
    UPDATE ChuyenGia_KyNang
    SET CapDo = CapDo + 1
    WHERE MaChuyenGia = @MaChuyenGia;
END;

-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE KyNang_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    MaKyNang INT,
    CapDoCu INT,
    CapDoMoi INT,
    NgayThayDoi DATETIME,
    HanhDong NVARCHAR(50)
);

CREATE TRIGGER trg_LogSkillLevelChanges
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    INSERT INTO KyNang_Log (MaChuyenGia, MaKyNang, CapDoCu, CapDoMoi, NgayThayDoi, HanhDong)
    SELECT 
        deleted.MaChuyenGia, 
        deleted.MaKyNang, 
        deleted.CapDo AS CapDoCu, 
        inserted.CapDo AS CapDoMoi, 
        GETDATE() AS NgayThayDoi, 
        'UPDATE' AS HanhDong
    FROM inserted
    JOIN deleted ON inserted.MaChuyenGia = deleted.MaChuyenGia AND inserted.MaKyNang = deleted.MaKyNang;
END;
-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER trg_C108 ON DUAN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGAYBATDAU DATE
	DECLARE @NGAYKETTHUC DATE

	SELECT @NGAYBATDAU=NGAYBATDAU FROM inserted
	SELECT @NGAYKETTHUC=NGAYKETTHUC FROM inserted
	IF(@NGAYBATDAU>=@NGAYKETTHUC)
	BEGIN
		PRINT'NGAY BAT DAU PHAI NHO HON NGAY KET THUC'
		ROLLBACK TRAN
	END
END
-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER trg_DeleteRelatedChuyenGiaKyNang
ON KyNang
AFTER DELETE
AS
BEGIN
    DELETE FROM ChuyenGia_KyNang
    WHERE MaKyNang IN (SELECT MaKyNang FROM deleted);
END;

-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER trg_C110 ON DUAN
FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @MACONGTY INT
	DECLARE @SLDA INT

	SELECT @MACONGTY=MACONGTY FROM inserted
	SELECT @SLDA=COUNT(MADUAN) FROM inserted WHERE @MACONGTY=MaCongTy AND TrangThai=N'Đang thực hiện'
	IF(@SLDA>10)
	BEGIN
		PRINT'Một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.'
		ROLLBACK TRAN
	END
END

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.

-
-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).

-- Tạo bảng ThongBao nếu chưa có


-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.


-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.

-- Tạo bảng ThongKeChuyenNganh nếu chưa có

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.

-- Tạo bảng DuAnHoanThanh nếu chưa có


-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.



-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.



-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.



-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.



-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.


-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.



-- 133. (tiếp tục) Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.


-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).


-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.


-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.


-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.


-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.


