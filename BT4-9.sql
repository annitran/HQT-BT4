CREATE PROC sp_ThemNguoilon
    @newHo VARCHAR(15),
    @newTenlot CHAR(10),
    @newTen VARCHAR(15),
    @newNgaysinh DATETIME,

    @newSonha VARCHAR(15),
    @newDuong VARCHAR(63),
    @newQuan CHAR(10),
    @newDienthoai CHAR(13),
    @newHan_sd DATETIME
AS
BEGIN
    BEGIN TRANSACTION

    DECLARE @newMadocgia SMALLINT

    -- [1] Xác định mã độc giả sẽ cấp cho độc giả người lớn này thoả QĐ-2
    SELECT @newMadocgia = MIN(dg.ma_docgia + 1)
    FROM docgia AS dg
    LEFT JOIN docgia AS dg1 ON (dg.ma_docgia + 1) = dg1.ma_docgia
    WHERE dg1.ma_docgia IS NULL

    -- [2] Thêm 1 bộ dữ liệu vào bảng độc giả
    -- mở chế độ tự động tạm thời
    SET IDENTITY_INSERT docgia ON

    INSERT INTO docgia (ma_docgia, ho, tenlot, ten, ngaysinh)
    VALUES (@newMadocgia, @newHo, @newTenlot, @newTen, @newNgaysinh)

    -- tắt chế độ tự động tạm thời
    SET IDENTITY_INSERT docgia OFF

    -- [3] Kiểm tra tuổi của độc giả này có đủ 18 tuổi
    -- [4] Nếu không đủ tuổi
    IF @newNgaysinh > DATEADD(YEAR, -18, GETDATE())
    BEGIN
        -- [4.1] Thông báo lỗi
        PRINT N'Độc giả vừa thêm chưa đủ 18 tuổi!'
        -- [4.2] Chấm dứt stored proc
        ROLLBACK TRANSACTION
        RETURN
    END

    -- [5] Nếu đủ tuổi thì:
    ELSE
    BEGIN
        -- [5.1] Thêm 1 bộ dữ liệu vào bảng người lớn
        INSERT INTO nguoilon
        VALUES (@newMadocgia, @newSonha, @newDuong, @newQuan, @newDienthoai, @newHan_sd)
        COMMIT TRANSACTION
    END
END