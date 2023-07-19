USE QLDT

CREATE VIEW DANHSACHDETAI_REPORT
AS
SELECT DETAI.MSDT, TENDT, GIAOVIEN.MSGV, TENGV FROM DETAI JOIN GV_HDDT ON DETAI.MSDT = GV_HDDT.MSDT
JOIN GIAOVIEN ON GIAOVIEN.MSGV = GV_HDDT.MSGV

SELECT * FROM DANHSACHDETAI_REPORT

CREATE VIEW HD_DT
AS SELECT HOIDONG.MSHD, PHONG, TENDT, DETAI.MSDT, QUYETDINH
FROM HOIDONG, HOIDONG_DT, DETAI
WHERE HOIDONG.MSHD=HOIDONG_DT.MSHD
AND HOIDONG_DT.MSDT=DETAI.MSDT

SELECT * FROM HD_DT


CREATE FUNCTION TINHDTB (@MSDT CHAR(6))
RETURNS FLOAT 
AS
BEGIN 
	DECLARE @DIEM FLOAT
	SELECT @DIEM = (SUM(GV_HDDT.DIEM) + SUM(GV_UVDT.DIEM) + SUM(GV_PBDT.DIEM)) / (COUNT(GV_HDDT.DIEM) + COUNT(GV_UVDT.DIEM) + COUNT(GV_PBDT.DIEM))
	FROM DETAI AS DT JOIN GV_HDDT ON DT.MSDT = GV_HDDT.MSDT
	JOIN GV_UVDT ON DT.MSDT = GV_UVDT.MSDT
	JOIN GV_PBDT ON DT.MSDT = GV_PBDT.MSDT
	WHERE DT.MSDT = @MSDT
	IF (@DIEM IS NULL)
		SET @DIEM = 0
	RETURN @DIEM
END
CREATE TABLE DETAI_DIEM
(
	MSDT CHAR(6) PRIMARY KEY,
	DIEMTB FLOAT
)
--Cursor
DECLARE C CURSOR FOR SELECT MSDT, dbo.TINHDTB(MSDT) AS DIEMTB FROM DETAI
DECLARE @ms CHAR(6), @dtb FLOAT
OPEN C
FETCH C INTO @ms, @dtb
WHILE (@@FETCH_STATUS = 0)
BEGIN 
INSERT INTO DETAI_DIEM(MSDT,DIEMTB) VALUES (@ms, @dtb)
FETCH NEXT FROM C INTO @ms, @dtb
END
CLOSE C

SELECT * FROM DETAI_DIEM
--view
create view DETAI_DTB
as select DETAI.MSDT, TENDT, DIEMTB
from DETAI, DETAI_DIEM
where DETAI.MSDT=DETAI_DIEM.MSDT

SELECT *  from DETAI_DTB