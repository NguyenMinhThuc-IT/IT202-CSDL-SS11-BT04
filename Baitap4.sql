-- PHẦN A. PHÂN TÍCH & ĐỀ XUẤT
-- 1. Định nghĩa Input / Output
/*
INPUT:
- p_patient_id   INT          : Mã bệnh nhân (có thể NULL)
- p_phone        VARCHAR(15)  : Số điện thoại (có thể NULL)

OUTPUT:
- p_total_due    DECIMAL(18,2): Tổng nợ của bệnh nhân
- p_message      VARCHAR(100) : Thông báo trạng thái

=> Sử dụng:
- 2 tham số IN
- 2 tham số OUT
*/


-- 2. Hai giải pháp

/*
Giải pháp 1: IF...ELSE
- Nếu p_patient_id khác NULL thì tìm theo ID.
- Ngược lại nếu p_phone khác NULL thì tìm theo phone.
- Nếu cả hai đều NULL thì báo lỗi.

Giải pháp 2: Truy vấn linh hoạt
- JOIN Patients và Patient_Invoices.
- WHERE (patient_id = p_patient_id OR phone = p_phone)
- Dùng điều kiện IS NOT NULL để tránh lỗi.
*/


-- 3. So sánh

/*
| Tiêu chí            | IF...ELSE                 | WHERE linh hoạt            |
|--------------------|---------------------------|----------------------------|
| Dễ hiểu            | Rất dễ                    | Trung bình                 |
| Dễ bảo trì         | Tốt                       | Tốt                        |
| Mở rộng điều kiện  | Khó hơn                   | Linh hoạt hơn              |
| Nguy cơ lỗi logic  | Thấp                      | Cao hơn nếu viết sai OR    |
| Phù hợp bài toán   | Rất phù hợp               | Phù hợp                    |
*/

-- Lựa chọn: IF...ELSE vì rõ ràng, dễ đọc và dễ kiểm soát.


-- PHẦN B. THIẾT KẾ LUỒNG XỬ LÝ
/*
1. Nếu cả p_patient_id và p_phone đều NULL:
   - total_due = 0
   - message = 'Lỗi: Vui lòng cung cấp ID hoặc số điện thoại'

2. Ngược lại:
   - Tìm tổng nợ theo ID hoặc Phone.

3. Nếu không tìm thấy:
   - total_due = 0
   - message = 'Không tìm thấy bệnh nhân'

4. Nếu tìm thấy:
   - message = 'Tra cứu thành công'
*/


-- PHẦN C. TRIỂN KHAI PROCEDURE

DROP PROCEDURE IF EXISTS GetPatientDebt;

DELIMITER //

CREATE PROCEDURE GetPatientDebt(
    IN p_patient_id INT,
    IN p_phone VARCHAR(15),
    OUT p_total_due DECIMAL(18,2),
    OUT p_message VARCHAR(100)
)
BEGIN
    -- Kiểm tra đầu vào
    IF p_patient_id IS NULL AND p_phone IS NULL THEN
        SET p_total_due = 0;
        SET p_message = 'Lỗi: Vui lòng cung cấp ID hoặc số điện thoại';

    ELSE
        -- Tìm tổng nợ
        SELECT pi.total_due
        INTO p_total_due
        FROM Patients p
        JOIN Patient_Invoices pi
            ON p.patient_id = pi.patient_id
        WHERE (p_patient_id IS NOT NULL AND p.patient_id = p_patient_id)
           OR (p_phone IS NOT NULL AND p.phone = p_phone)
        LIMIT 1;

        -- Nếu không tìm thấy
        IF p_total_due IS NULL THEN
            SET p_total_due = 0;
            SET p_message = 'Không tìm thấy bệnh nhân';
        ELSE
            SET p_message = 'Tra cứu thành công';
        END IF;
    END IF;
END //

DELIMITER ;


-- PHẦN D. NGHIỆM THU

-- 1. Chỉ truyền ID
CALL GetPatientDebt(1, NULL, @debt, @msg);
SELECT @debt AS total_due, @msg AS message;

-- 2. Chỉ truyền Phone
CALL GetPatientDebt(NULL, '0901111222', @debt, @msg);
SELECT @debt AS total_due, @msg AS message;

-- 3. Truyền NULL cả 2
CALL GetPatientDebt(NULL, NULL, @debt, @msg);
SELECT @debt AS total_due, @msg AS message;

-- 4. Dữ liệu không tồn tại
CALL GetPatientDebt(999, NULL, @debt, @msg);
SELECT @debt AS total_due, @msg AS message;