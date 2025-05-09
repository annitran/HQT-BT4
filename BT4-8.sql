CREATE PROC sp_ThemCuonSach
    @newISBN INT
AS
BEGIN
    DECLARE @newMacuonsach SMALLINT

    -- [1] Kiểm tra mã isbn nếu không tồn tại thì thông báo & ngừng xử lý
    IF NOT EXISTS (
        SELECT 1
        FROM dausach
        WHERE isbn = @newISBN
    )
    BEGIN
        PRINT(N'Mã isbn này không tồn tại!!!')
        RETURN
    END

    -- [2] Xác định mã cuốn sách sẽ cấp cho cuốn sách này thoả quy định QĐ-3
    SELECT @newMacuonsach = MIN(cs.ma_cuonsach + 1)
    FROM cuonsach AS cs
    WHERE cs.isbn = @newISBN
        AND NOT EXISTS (
        SELECT 1
        FROM cuonsach AS cs1
        WHERE cs1.isbn = @newISBN
            AND cs1.ma_cuonsach = cs.ma_cuonsach + 1
    )
    -- Nếu không có ma_cuonsach nào bị thiếu thì gán giá trị tiếp theo
    IF @newMacuonsach IS NULL
    BEGIN
        SELECT @newMacuonsach = ISNULL(MAX(ma_cuonsach), 0) + 1
        FROM cuonsach
        WHERE isbn = @newISBN
    END

    -- [3] Thêm cuốn sách mới với mã cuốn sách đã xác định và tình trạng là yes
    IF @newMacuonsach IS NOT NULL
    BEGIN
        SET IDENTITY_INSERT cuonsach ON
        INSERT INTO cuonsach(isbn, ma_cuonsach, tinhtrang)
            VALUES (@newISBN, @newMacuonsach, 'Y')
        SET IDENTITY_INSERT cuonsach OFF

    -- [4] Thay đổi trạng thái của đầu sách là yes
        UPDATE dausach
        SET trangthai = 'Y'
        WHERE isbn = @newISBN
    END
END
