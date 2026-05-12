use rikkeiclinicdb;

DELIMITER //

CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
-- Thao tác 1: Giải phóng giường cũ
UPDATE Beds SET patient_id = NULL WHERE patient_id = p_patient_id;

-- Thao tác 2: Gán giường mới
UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = p_new_bed_id;
END //

DELIMITER ;
-- Phân tích: Hiện tại bệnh nhân lơ lửng là do không có tính nhất quán, sau khi gỡ bỏ bệnh nhân khỏi giường cũ thì chưa kịp gán vào giường với thì bị lỗi, nên không được gán vào giường mới , từ đó gây ra không tìm thấy bệnh nhân 
-- Nó gây ra lỗi A trong ACID rất nghiêm trọng 
drop procedure TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
declare message varchar(50) default 'Sự cố mất kết nối';
start transaction;
-- Thao tác 1: Giải phóng giường cũ
UPDATE Beds SET patient_id = NULL WHERE patient_id = p_patient_id;
if message = 'Sự cố mất kết nối' then rollback;
else
-- Thao tác 2: Gán giường mới
UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = p_new_bed_id;
commit;
end if;
END //

DELIMITER ;
call TransferBed(1,201);