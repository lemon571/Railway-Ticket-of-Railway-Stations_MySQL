--1
--�������� ��������� pr_ChangePhone ��� ��������� ������ �������� ���������
--������ ��������� ����������, ��� ��� �������� ����� �������� ���� ����� ������������ ��� ���������� ������
GO
CREATE PROC pr_ChangePhone (@TravelerID int, @NewPhone char(100))
AS
BEGIN
	UPDATE dbo.Traveler
	SET Phone = @NewPhone
	WHERE TravelerID = @TravelerID
END
GO

--������������ �������� ��������� pr_ChangePhone
SELECT TravelerID, Phone FROM dbo.Traveler -- �������� ������� (��� ���������)
BEGIN TRAN
EXEC pr_ChangePhone 1, '+7 (917) 777-44-19' -- ����� ����������
SELECT TravelerID, Phone FROM dbo.Traveler
ROLLBACK TRAN
--
GO
EXEC pr_ChangePhone 1, '+7 (917) 777-44-11'
SELECT TravelerID, Phone FROM dbo.Traveler
--DROP PROCEDURE pr_ChangePhone


--2
--�������� ��������� pr_ChangeSeats ��� ��������� ������ ����� ���������.
--������ ��������� ����������, ��� ��� �������� ����� �������� ����� ����� ������� ����� ���� �� ����� �������, ������� �� ������ �����.
GO
CREATE PROC pr_ChangeSeats (@TicketID int, @NewNubmer char(100))
AS
BEGIN
	UPDATE dbo.Ticket
	SET PlaceNumber = @NewNubmer
	WHERE TicketID = @TicketID
	--������� ������ ����������� �����
	SELECT PlaceNumber, 
	   COUNT(*) AS counting
	FROM Ticket
	WHERE PlaceNumber IS NOT NULL
	GROUP BY PlaceNumber
	ORDER BY PlaceNumber;
END
GO

--������������ �������� ��������� pr_ChangeSeats
GO
EXEC pr_ChangeSeats 1, 15

--DROP PROCEDURE pr_ChangeSeats



--3
--�������� ��������� pr_TypeCar ��� ��������� ���������� � ������������� ������������� ���� ������
CREATE PROC pr_TypeCar
@Type nchar(100)
AS
IF exists(
   SELECT TOP 1 Car.Type
   FROM Car
   INNER JOIN Build ON Car.BuildID = Build.BuildID
   WHERE Car.Type LIKE '%' + @Type + '%'

)
BEGIN
   PRINT 1
END
ELSE
BEGIN
   PRINT 0
END

--������������ �������� ��������� pr_TypeCar
exec dbo.pr_TypeCar N'CV' - ������������ ��� ������

--DROP PROP dbo.pr_TypeCar



--4
--�������� ��������� pr_AddNewTicket, ����������� ����� �����
--� ������ ������� ������, ������������� � ���� ��������� ����� ��������� ������ ���������
GO
CREATE PROC pr_AddNewTicket(@TravelerID int, @TimetableID int, @CarNumber int, @PlaceNumber int, @Price float, @PointsDestroyed int, @TimeSale nchar(100))
AS
BEGIN
	INSERT dbo.Ticket(TravelerID, TimetableID, CarNumber, PlaceNumber, Price, PointsDestroyed, TimeSale)
	VALUES (@TravelerID, @TimetableID, @CarNumber, @PlaceNumber, @Price, @PointsDestroyed, @TimeSale)
END

--������������ �������� ��������� pr_AddNewTicket
SELECT * FROM dbo.Ticket ORDER BY TravelerID
BEGIN TRAN
EXEC pr_AddNewTicket 5, 2, 3, 6, 789.90, 0, '23:44 22.10.2022'
SELECT * FROM dbo.Ticket ORDER BY TravelerID
ROLLBACK TRAN

--DROP PROCEDURE pr_AddNewTicket



--5
--�������� ��������� pr_ActualTicket, ����������� ������ ������������ �� ����� � ���������.
--�� �������������� ��������� ��������� ������� ��������� � ������ ������, ������������� ���.
GO
CREATE PROC pr_ActualTicket
@ID int
AS 
BEGIN 
	DECLARE CURS CURSOR
	FOR (SELECT TRY_CAST(TI.TimeSale AS time), TI.TicketID FROM Ticket AS TI
		JOIN Traveler AS TR ON TI.TravelerID = TR.TravelerID
		WHERE TR.TravelerID = @ID)
	OPEN CURS

	DECLARE @TIME nchar(100)
	DECLARE @TicketNumber int

	DECLARE @IS nchar(100)
	DECLARE @COUNT int = (SELECT COUNT(TicketID) FROM dbo.fn_GetTicket(@ID))
	
	WHILE @COUNT > 0
	BEGIN
		FETCH NEXT FROM CURS INTO @TIME, @TicketNumber
		IF TRY_CAST(@TIME AS time) > CONVERt(time, GETDATE())
			SET @IS = '����� ����� � �������������'
			                   -- TRY_CAST(@TicketNumber AS nchar (100))
		ELSE
			SET @IS = '����� �����'
			                    --TRY_CAST(@TicketNumber AS nchar(100))
		SET @COUNT = @COUNT - 1
		PRINT @IS
	END;

	CLOSE CURS
	DEALLOCATE CURS
END;

--������������ �������� ��������� pr_ActualTicket
GO
EXEC pr_ActualTicket 1

--DROP PROCEDURE pr_ActualTicket

