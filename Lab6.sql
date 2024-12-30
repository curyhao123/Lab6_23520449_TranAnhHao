-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE HOMEWORK
GO
-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.--
SELECT *
FROM CHUYENGIA
--2. Hiển thị tên và email của các chuyên gia nữ.--
SELECT HOTEN,EMAIL
FROM CHUYENGIA
WHERE GIOITINH = N'Nữ'
--3. Liệt kê các công ty có trên 100 nhân viên.--
SELECT *
FROM CONGTY
WHERE CongTy.SoNhanViEn > 100
--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.--
SELECT TENDUAN,NGAYBATDAU
FROM DUAN
WHERE YEAR(NGAYBATDAU) = 2023
5 Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT CHUYENNGANH, COUNT(MACHUYENGIA) AS SLCG
FROM CHUYENGIA
GROUP BY CHUYENNGANH

-- Trung cấp:
6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HOTEN, COUNT(MADUAN) AS SOLUONGDUAN
FROM CHUYENGIA_DUAN
JOIN CHUYENGIA ON CHUYENGIA.MACHUYENGIA = CHUYENGIA_DUAN.MACHUYENGIA
GROUP BY HOTEN

7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT DISTINCT D.MADUAN,TENDUAN
FROM DUAN D
JOIN CHUYENGIA_DUAN CD ON CD.MADUAN = D.MADUAN
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia
	FROM CHUYENGIA_KYNANG
	JOIN KYNANG ON KYNANG.MaKyNAng = CHUYENGIA_KYNANG.Makynang
	WHERE TENKYNANG = 'Python' AND CAPDO >= 4
)

8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TENCONGTY,COUNT(MADUAN) AS SLDA
FROM CONGTY
JOIN DUAN ON DUAN.MACONGTY = CONGTY.MACONGTY
WHERE TRANGTHAI = N'Đang thực hiện'
GROUP BY TENCONGTY


9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
SELECT MaChuyenGia, Hoten, ChuyenNganh, NamKinhNghiem
FROM ChuyenGia CG1
WHERE NamKinhNghiem = (
    SELECT MAX(CG2.NamKinhNghiem)
    FROM ChuyenGia CG2
    WHERE CG2.ChuyenNganh = CG1.ChuyenNganh
);
10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.

SELECT DISTINCT 
    CG3.HoTen AS ChuyenGia1, 
    CG4.HoTen AS ChuyenGia2,
	DA.TENDUAN
FROM ChuyenGia_DuAn CG1
JOIN ChuyenGia_DuAn CG2 ON CG1.MaDuAn = CG2.MaDuAn AND CG1.MaChuyenGia < CG2.MaChuyenGia
JOIN ChuyenGia CG3 ON CG1.MaChuyenGia = CG3.MaChuyenGia
JOIN ChuyenGia CG4 ON CG2.MaChuyenGia = CG4.MaChuyenGia
JOIN DUAN DA ON DA.MADUAN = CG1.MADUAN

-- Nâng cao:
11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT CG.HoTen,
       SUM(DATEDIFF(DAY, CGDA.NgayThamGia, COALESCE(CGDA.NgayKetThuc, GETDATE()))) AS TongThoiGian
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen;

12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
WITH DuAnStats AS (
    SELECT MaCongTy,
           COUNT(*) AS TotalProjects,
           SUM(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) AS CompletedProjects
    FROM DuAn
    GROUP BY MaCongTy
)
SELECT CongTy.TenCongTy, 
       (CAST(DuAnStats.CompletedProjects AS FLOAT) / DuAnStats.TotalProjects) * 100 AS TyLeHoanThanh
FROM CongTy
JOIN DuAnStats ON CongTy.MaCongTy = DuAnStats.MaCongTy
WHERE (CAST(DuAnStats.CompletedProjects AS FLOAT) / DuAnStats.TotalProjects) > 0.9;

13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
WITH KyNangYeuCau AS (
    SELECT KN.MaKyNang, KN.TenKyNang, COUNT(DISTINCT DA.MaDuAn) AS SoLanYeuCau
    FROM KyNang KN
    JOIN ChuyenGia_KyNang CGKN ON KN.MaKyNang = CGKN.MaKyNang
    JOIN ChuyenGia_DuAn CGDA ON CGKN.MaChuyenGia = CGDA.MaChuyenGia
    JOIN DuAn DA ON CGDA.MaDuAn = DA.MaDuAn
    GROUP BY KN.MaKyNang, KN.TenKyNang
)
SELECT TOP 3 TenKyNang, SoLanYeuCau
FROM KyNangYeuCau
ORDER BY SoLanYeuCau DESC;

14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT 
    CASE 
        WHEN NamKinhNghiem <= 2 THEN 'Junior'
        WHEN NamKinhNghiem <= 5 THEN 'Middle'
        ELSE 'Senior'
    END AS CapDo,
    AVG(Luong) AS LuongTrungBinh
FROM ChuyenGia
GROUP BY 
    CASE 
        WHEN NamKinhNghiem <= 2 THEN 'Junior'
        WHEN NamKinhNghiem <= 5 THEN 'Middle'
        ELSE 'Senior'
    END;

15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
WITH SpecializationCount AS (
    SELECT COUNT(DISTINCT ChuyenNganh) AS TotalSpecializations
    FROM ChuyenGia
), ProjectSpecializations AS (
    SELECT DA.MaDuAn, COUNT(DISTINCT CG.ChuyenNganh) AS SpecializationsCount
    FROM DuAn DA
    JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
    JOIN ChuyenGia CG ON CGDA.MaChuyenGia = CG.MaChuyenGia
    GROUP BY DA.MaDuAn
)
SELECT DA.TenDuAn
FROM DuAn DA
JOIN ProjectSpecializations PS ON DA.MaDuAn = PS.MaDuAn
CROSS JOIN SpecializationCount
WHERE PS.SpecializationsCount = SpecializationCount.TotalSpecializations;


-- Trigger:
16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
CREATE TRIGGER DEMDUAN
ON DUAN
FOR INSERT,DELETE
AS
BEGIN
	UPDATE CONGTY
	SET SODUAN = SODUAN + 1
	FROM INSERTED
	WHERE CONGTY.MACONGTY = INSERTED.MACONGTY

	UPDATE CONGTY
	SET SODUAN = SODUAN - 1
	FROM DELETED
	WHERE CONGTY.MACONGTY = DELETED.MACONGTY
END



17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE ChuyenGiaLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    HanhDong NVARCHAR(10),
    NgayThayDoi DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER LOG_CG
ON CHUYENGIA
FOR INSERT,DELETE,UPDATE
AS
BEGIN
	DECLARE @HANHDONG NVARCHAR(10)
	IF EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
		SET @HANHDONG = 'UPDATE'
	ELSE IF EXISTS (SELECT 1 FROM INSERTED)
		SET @HANHDONG = 'INSERT'
	ELSE
		SET @HANHDONG = 'DELETE'
	INSERT INTO ChuyenGiaLog (MaChuyenGia, HanhDong)
    SELECT MaChuyenGia, @HanhDong
    FROM inserted
    UNION ALL
    SELECT MaChuyenGia, @HanhDong
    FROM deleted;
END

18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER KOTG_5DUAN1
ON CHUYENGIA_DUAN
FOR UPDATE,INSERT,DELETE
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM CHUYENGIA_DUAN
		GROUP BY MACHUYENGIA
		HAVING COUNT (DISTINCT MADUAN) > 5
	)
	BEGIN
		ROLLBACK TRANSACTION
		PRINT('KO HOP LE')
	END
END
19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
CREATE TRIGGER TRNGTHAIDUAN
ON CHUYENGIA_DUAN
FOR UPDATE
AS
BEGIN
	UPDATE DUAN
	SET TRANGTHAI = N'Hoàn thành'
	WHERE MADUAN IN (
		SELECT MADUAN
		FROM CHUYENGIA_DUAN
		GROUP BY MADUAN
		HAVING COUNT(*) = SUM(CASE WHEN NgayKetThuc IS NOT NULL THEN 1 ELSE 0 END)
    )
    AND TrangThai != N'Hoàn thành';
END

20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
