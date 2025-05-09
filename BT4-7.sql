CREATE PROC sp_ThemTuaSach
    @newTuasach VARCHAR(63),
    @newTacgia VARCHAR(31),
    @newTomtat VARCHAR(MAX)
AS
BEGIN
    -- [1] Xác định mã tựa sách sẽ cấp cho tựa sách này thoả quy định QĐ-2
    DECLARE @newMatuasach INT
    SELECT @newMatuasach = MIN(ts.ma_tuasach + 1)
    FROM tuasach AS ts
    WHERE NOT EXISTS (
        SELECT 1
        FROM tuasach AS ts1
        WHERE ts1.ma_tuasach = ts.ma_tuasach + 1
    )
    -- Nếu không có ma_tuasach nào bị thiếu:
    IF @newMatuasach IS NULL
    BEGIN
        SELECT @newMatuasach = MAX(ts2.ma_tuasach + 1)
        FROM tuasach AS ts2
    END
    
    -- [2] Kiểm tra phải có ít nhất 1 trong 3 thuộc tính tựa sách, tác giả, tóm tắt
    -- khác với các bộ trong bảng tựa sách đã có
    IF NOT EXISTS (
        SELECT 1
        FROM tuasach
        WHERE @newTuasach = tuasach AND @newTacgia = tacgia AND @newTomtat = CAST(tomtat AS VARCHAR(MAX))
    )

    -- [3] Nếu thoả điều kiện này thì:
    BEGIN
        -- mở chế độ tự động tạm thời
        SET IDENTITY_INSERT tuasach ON
        -- [3.1] Thêm vào tựa sách
        INSERT INTO tuasach(ma_tuasach, tuasach, tacgia, tomtat)
            VALUES (@newMatuasach, @newTuasach, @newTacgia, @newTomtat)
        -- tắt chế độ tự động tạm thời
        SET IDENTITY_INSERT tuasach OFF
    END

    -- [4] Nếu không thoả điều kiện thì:
    ELSE
    BEGIN
        -- [4.1] Thông báo lỗi
        PRINT(N'Tựa sách này đã tồn tại!!!')
        -- [4.2] Chấm dứt stored procedure
        RETURN
    END
END