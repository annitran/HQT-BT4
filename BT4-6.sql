CREATE PROC sp_CapnhatTrangthaiDausach
AS
BEGIN
    -- [1] Xác định số cuốn sách hiện giờ còn trong thư viện của đầu sách có isbn
    SELECT c.isbn, COUNT(*) AS SoLuongConLai
    FROM cuonsach AS c 
    WHERE c.tinhtrang = 'Y'
    GROUP BY c.isbn

    -- [2] Nếu không còn quyển nào:
        -- [2.1] Cập nhật tình trạng đầu sách là no
    UPDATE dausach
        SET trangthai = 'N'
        WHERE isbn NOT IN (
            SELECT c1.isbn 
            FROM cuonsach AS c1
            WHERE c1.tinhtrang = 'Y'
            GROUP BY c1.isbn
        )
    -- [3] Nếu còn ít nhất 1 quyển thì:
        -- [3.1] Cập nhật tình trạng đầu sách là yes
    UPDATE dausach
        SET trangthai = 'Y'
        WHERE isbn IN (
            SELECT c2.isbn 
            FROM cuonsach AS c2
            WHERE c2.tinhtrang = 'Y'
            GROUP BY c2.isbn
        )
END