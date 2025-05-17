CREATE PROC sp_ThemTreEm
    @newHo VARCHAR(15),
    @newTenlot CHAR(10),
    @newTen VARCHAR(15),
    @newNgaysinh DATETIME,
    @new_Madocgia_nguoilon SMALLINT
AS
BEGIN
    BEGIN TRANSACTION

    DECLARE @newMadocgia SMALLINT
    -- [1] Xác định mã độc giả sẽ cấp cho độc giả trẻ em này thoả QĐ-2
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

    -- [3] Đếm số trẻ em của độc giả người lớn bảo lãnh trẻ em mới này
    DECLARE @Soluong_treem_duoc_baolanh INT

    SELECT @Soluong_treem_duoc_baolanh = COUNT(*) FROM treem AS te 
    JOIN nguoilon AS nl ON nl.ma_docgia = te.ma_docgia_nguoilon
    WHERE te.ma_docgia_nguoilon = @new_Madocgia_nguoilon
    GROUP BY te.ma_docgia_nguoilon

    -- [4] Kiểm tra, nếu không thoả QĐ-1 thì:
    IF @Soluong_treem_duoc_baolanh > 1
    BEGIN
        -- [4.1] Thông báo lỗi
        PRINT N'Độc giả người lớn này đã bảo lãnh đủ 2 trẻ em!'
        -- [4.2] Chấm dứt stored proc
        ROLLBACK TRANSACTION
        RETURN
    END

    -- [5] Nếu thoả QĐ-1 thì: Thêm 1 bộ dữ liệu vào bảng trẻ em
    ELSE
    BEGIN
        INSERT INTO treem 
        VALUES (@newMadocgia, @new_Madocgia_nguoilon, @newNgaysinh)
        COMMIT TRANSACTION
    END
END
