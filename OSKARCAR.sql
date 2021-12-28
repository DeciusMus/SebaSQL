/*PRESS F5*/

CREATE DATABASE OSKARCARS
GO 

USE OSKARCARS
GO

CREATE SCHEMA OSKAR
GO


CREATE TABLE Oskar.Employees
(EmpID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
 EmpName varchar(450) NOT NULL, 
 EmpMidName varchar(450) NULL,
 EmpLastName varchar(450) NOT NULL,
 EmpPhone CHAR(9) NULL CHECK (EmpPhone NOT LIKE '%[^0-9]%'),
 EmpPESEL CHAR(11) NULL CHECK (EmpPESEL NOT LIKE '%[^0-9]%'), 
 CONSTRAINT U0001 UNIQUE (EmpName, EmpMidName, EmpLastName),
 CONSTRAINT U0002 UNIQUE (EmpPESEL))

 go

CREATE TABLE Oskar.DimPhoneNumbers
(PhoneUserID INT IDENTITY (1, 1), 
 GivenNumber CHAR(6)  CHECK (GivenNumber NOT LIKE '%[^0-9]%') DEFAULT '789600',
 RandomNumber INT CHECK(RandomNumber NOT LIKE '%[^0-9]%'),
 FullNumber AS (GivenNumber + RandomNumber), 
 CONSTRAINT FK0001 FOREIGN KEY (PhoneUserID) REFERENCES Oskar.Employees(EmpID)) 

 go

CREATE PROCEDURE PHONENUMBERSENDING AS 
BEGIN
    SET IDENTITY_INSERT Oskar.DimPhoneNumbers OFF
    INSERT INTO Oskar.DimPhoneNumbers (RandomNumber)
    VALUES (FLOOR(RAND()*(999-100+1))+100)
	SET IDENTITY_INSERT Oskar.DimPhoneNumbers ON
END 

go

CREATE TRIGGER TRG0001
ON [OSKAR].[Employees]
AFTER INSERT
AS
BEGIN
EXEC dbo.PHONENUMBERSENDING
END

go

CREATE TABLE Oskar.Warehouse
 (EmpName VARCHAR(450) NOT NULL,
 EmpPESEL CHAR(11) CHECK (EmpPESEL NOT LIKE '%[^0-9]%') NULL, 
 WarehouseID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
 CONSTRAINT FK0002 FOREIGN KEY (EmpPESEL) REFERENCES Oskar.Employees(EmpPESEL),
 )

 GO

CREATE TRIGGER TRG0002 ON Oskar.Employees FOR INSERT AS
BEGIN 
     SET IDENTITY_INSERT Oskar.Warehouse OFF 
     INSERT Oskar.Warehouse
	 SELECT EmpName, EmpPESEL FROM INSERTED
	 SET IDENTITY_INSERT Oskar.Warehouse ON
END

GO
 

 CREATE PROCEDURE CLEANINGLADY 
 AS 
 BEGIN 
 DELETE FROM Oskar.Warehouse  
 WHERE EmpPESEL IS NULL
 END

 GO

 CREATE TRIGGER TRG0003 ON Oskar.Warehouse AFTER INSERT AS
 BEGIN 
 EXEC CLEANINGLADY
 END

 GO

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Oskar', 'Dynamo', 'Herczyk', '576754219', '97060188889')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Zbigniew', 'Tornado', 'Herczyk', '576754219', '97060190000')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Zenon', '£ubudu', 'Herczyk', '609091199', '76032300078')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Julka', 'Dej3Stuwy', 'Ztwittera', '607899004', '03020100001')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Don', 'Kasjo', 'Kasjusz', '789300009', '95043088903')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Seba', 'GOTTENDAMERUNG', 'Olchawa', '665484000', '81113055555')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Roki', 'A³abaj', 'Olchawa', '665484001', '17120400001')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Zosia', 'S³onina', 'Olchawa', '665484002', '13050100003')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Luna', 'TIGER', 'Olchawa', '665484003', '15040100003')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Austrian', 'Aldi', 'Aquarellist', '888888888', '89042088888')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Marjan', 'SUPERMAN', 'Smith', '768453990', '89042009088')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Saint', 'Presents', 'Nicolaus', '000000000', '00000099999')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Stary', 'Tajny Cios', 'Muranski', '567900435', '76101987045')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Aniela', 'Lil Masti', 'Bogusz', '878900223', '90040356032')

 INSERT INTO Oskar.Employees ( Empname, EmpMidName, EmpLastName, EmpPhone, EmpPESEL)
 VALUES ('Pawe³', 'Popek', 'Krul Albanii', '600976300', '78120203226')


 GO

 CREATE TABLE Manf
 (
  CarManufacturer varchar(450),
  WarehouseID INT NOT NULL,
  CONSTRAINT FK0003 FOREIGN KEY (WarehouseID) REFERENCES Oskar.Warehouse(WarehouseID)
  )

 GO

CREATE FUNCTION dbo.RANDBETWEEN(@minval TINYINT, @maxval TINYINT, @random NUMERIC(18,10))
RETURNS TINYINT
AS
BEGIN
  RETURN (SELECT CAST(((@maxval + 1) - @minval) * @random + @minval AS TINYINT))
END
GO

DECLARE @i int = 0
WHILE @i < 250 
BEGIN
    SET @i = @i + 1
    INSERT INTO Manf(CarManufacturer, WarehouseID)
SELECT TOP 10       
 CASE
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Audi'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Bentley'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'BMW'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Masseratti'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Mercedes'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Renault'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Volkswagen'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Ford'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Porshe'
        WHEN dbo.RANDBETWEEN(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Seat'
  ELSE 'Skoda' END AS CarManufacturer,
  dbo.RANDBETWEEN(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
    FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

go

 CREATE TABLE Models
 (
  Carmodel varchar(450),
  WarehouseID INT
  )

GO

CREATE FUNCTION dbo.MODEL300(@minval TINYINT, @maxval TINYINT, @random NUMERIC(18,10))
RETURNS TINYINT
AS
BEGIN
  RETURN (SELECT CAST(((@maxval + 1) - @minval) * @random + @minval AS TINYINT))
END
GO


GO



DECLARE @X INT = 0
WHILE @X < 5
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Audi A1'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Audi A3'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Audi A4'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Audi A5'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Audi A6'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Audi A8'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Audi Q5'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Audi RS'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Audi GT'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Audi E'
ELSE 'Audi Q7' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END


GO


DECLARE @X INT = 0
WHILE @X < 5
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Bentley Bentayga V8'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Bentley Flying Spur V8'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Bentley Continental GT V8'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Bentley Continental GT'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Bentley Continental GT Mulliner'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Bentley Flying Spur'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Bentley Bentayga First Edition'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Bentley Bentayga Speed'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Bentley Continental GT V8 Convertible'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Bentley Continental GT Mulliner Convertible E'
ELSE 'Bentley Flying Spur' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO


DECLARE @X INT = 0
WHILE @X < 5
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'BMW X1 (F48)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'BMW 7 Series (G11)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'BMW 5 Series (G31)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'BMW 6 Series (G32)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'BMW X2 (F39)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'BMW X4 (G02)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'BMW 8 Series (G16)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'BMW 8 Series (G15)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'BMW Z4 (G29)'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'BMW 3 Series (G21)'
ELSE 'BMW X1 (F48)' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO


DECLARE @X INT = 0
WHILE @X < 4
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Maseratti Quattroporte V S'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Maseratti GranTurismo'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Maseratti GranTurismo S'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Maseratti GranCabrio'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Maseratti Ghibli III'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Maseratti Ghibli III S'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Maseratti Ghibli III Diesel'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Maseratti Quattroporte VI S'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Maseratti Quattroporte VI GTS'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Maseratti Quattroporte VI Diesel'
ELSE 'Maseratti MC20' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 5
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Mercedes W213 E-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Mercedes C257 CLS-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Mercedes W167 GLE-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Mercedes W247 B-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Mercedes C118 CLA-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Mercedes X167 GLS-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Mercedes W223 S-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Mercedes W206 C-Class'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Mercedes X243 EQB'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Mercedes V295 EQE'
ELSE 'Mercedes-AMG One' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 10
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Renault Clio'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Renault Fluence Z.E.'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Renault Logan'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Renault Mégane'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Renault Talisman'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Renault Zoe'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Renault Alaskan'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Renault Espace'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Renault Scénic'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Renault Arkana'
ELSE 'Renault Koleos' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 10
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Volkswagen Golf'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Volkswagen ID.3'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Volkswagen Polo'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Volkswagen Up'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Volkswagen Arteon'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Volkswagen Passat'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Volkswagen ID.4'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Volkswagen T-Cross'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Volkswagen T-Roc'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Volkswagen Tiguan'
ELSE 'Volkswagen Touareg' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 10
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Ford Fiesta'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Ford Focus'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Ford Escort'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Ford Puma'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Ford Mondeo'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Ford Taurus'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Ford Bronco'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Ford Bronco Sport'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Ford Equator'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Ford Evos'
ELSE 'Ford Mustang Mach-E' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 3
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Porshe Boxster'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Porshe 911'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Porshe Cayenne'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Porshe Macan'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Porshe Panamera'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Porshe Taycan'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Porshe 918 Spyder'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Porshe Carrera GT'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Porshe 911 GT1 Straßenversion'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Porshe 968'
ELSE 'Porshe Speedster (991.2)' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 7
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Seat Mii Electric'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Seat Ibiza'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Seat León'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Seat Arona'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Seat Panamera'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Seat Ateca'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Seat Tarraco'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Seat León'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Seat Ateca'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Seat Formentor'
ELSE 'Seat Born' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

DECLARE @X INT = 0
WHILE @X < 12
BEGIN 
SET @X = @X + 1
    INSERT INTO Models(Carmodel, WarehouseID)
SELECT TOP 10
	CASE 
	WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 0 THEN 'Skoda Citigo'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 1 THEN 'Skoda Fabia'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 2 THEN 'Skoda Scala'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 3 THEN 'Skoda Rapid'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 4 THEN 'Skoda Octavia'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 5 THEN 'Skoda Superb'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 6 THEN 'Skoda Enyaq'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 7 THEN 'Skoda Kamiq'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 8 THEN 'Skoda Karoq'
    WHEN dbo.MODEL300(0,9,RAND(CHECKSUM(NEWID()))) = 9 THEN 'Skoda Kodiaq'
ELSE 'Skoda Kushaq' END AS Model,
dbo.MODEL300(1,15,RAND(CHECKSUM(NEWID()))) as WarehouseID
FROM sys.all_objects a
CROSS JOIN sys.all_objects b
END

GO

CREATE TABLE GREATCARTABLE (CarManufacturer varchar(450), CarModel varchar(450), WarehouseID INT, SPECIALCODE varchar(450) UNIQUE 
,CONSTRAINT FK0004 FOREIGN KEY (WarehouseID) REFERENCES Oskar.Warehouse(WarehouseID))

GO

INSERT INTO GREATCARTABLE (CarManufacturer, CarModel, WarehouseID, SPECIALCODE)
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Audi' AND B.CarModel LIKE '%Audi%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Bentley' And B.CarModel LIKE '%Bentley%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'BMW' AND B.CarModel LIKE '%BMW%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Masseratti' AND B.CarModel LIKE '%Maseratti%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Mercedes' AND B.CarModel LIKE '%Mercedes%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Renault' AND B.CarModel LIKE '%Renault%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Volkswagen' AND B.CarModel LIKE '%Volkswagen'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Ford' AND B.CarModel LIKE '%Ford%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Porshe' AND B.CarModel LIKE '%Porshe'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Seat' AND B.CarModel LIKE '%Seat%'
UNION
SELECT A.CarManufacturer, B.CarModel, A.WarehouseID, LEFT(newid(),8) AS SPECIALCODE
FROM Manf AS A
INNER JOIN Models AS B ON B.WarehouseID = A.WarehouseID
WHERE A.CarManufacturer LIKE 'Skoda' AND B.CarModel LIKE '%Skoda%'

GO

CREATE TABLE CARPRICE
(SPECIALCODE VARCHAR(450) PRIMARY KEY,
 CarModel varchar(450),
 BasePrice Money,
 ModelPrice Money,
 AdditionalStuff Money,
 Konckdown Money, 
 TotalPrice Money,
 WarehouseID INT,
 CONSTRAINT FK0005 FOREIGN KEY (SPECIALCODE) REFERENCES GREATCARTABLE(Specialcode) ON UPDATE CASCADE ON DELETE CASCADE) 

 GO

 INSERT INTO Carprice (SPECIALCODE, CARMODEL, WarehouseID) 
 SELECT Specialcode, Carmodel, WarehouseID FROM GREATCARTABLE
 ORDER BY CarModel ASC

 GO

 UPDATE carprice
 SET Baseprice = CASE 
 WHEN CarModel LIKE '%Renault%' THEN 40000
 WHEN CarModel LIKE '%Skoda%' THEN 42000
 WHEN CarModel LIKE '%Audi%' THEN 45000
 WHEN CarModel LIKE '%Seat%' THEN 47000
 WHEN CarModel LIKE '%Ford%' THEN 49000
 WHEN CarModel LIKE '%Volkswagen%' THEN 53000
 WHEN CarModel LIKE '%BMW%' THEN 75000
 WHEN CarModel LIKE '%Mercedes%' THEN 80000
 WHEN CarModel LIKE '%Porshe%' THEN 175000
 WHEN CarModel LIKE '%Maseratti%' THEN 230000
 WHEN CarModel LIKE '%Bentley%' THEN 500000
 END 

 GO

 UPDATE CarPrice 
 SET ModelPrice = CASE
     WHEN CarModel LIKE 'Audi A1' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Audi A3' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Audi A4' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Audi A5' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Audi A6' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Audi A8' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'Audi Q5' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Audi RS' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Audi GT' THEN CAST(RAND()*130000 AS INT) 
     WHEN CarModel LIKE 'Audi E'  THEN CAST(RAND()*56000 AS INT)
     WHEN CarModel LIKE 'Audi Q7' THEN CAST(RAND()*120000 AS INT) 
	 
	 WHEN CarModel LIKE 'Bentley Bentayga V8' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur V8' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT V8' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT' THEN CAST(RAND()*200000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT Mulliner' THEN CAST(RAND()*250000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur' THEN CAST(RAND()*170000 AS INT)
     WHEN CarModel LIKE 'Bentley Bentayga First Edition' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Bentley Bentayga Speed' THEN CAST(RAND()*180000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT V8 Convertible' THEN CAST(RAND()*280000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT Mulliner Convertible E' THEN CAST(RAND()*300000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur' THEN CAST(RAND()*320000 AS INT)
  	 
	 WHEN CarModel LIKE 'BMW X1 (F48)' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'BMW 7 Series (G11)' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'BMW 5 Series (G31)' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'BMW 6 Series (G32)' THEN CAST(RAND()*95000 AS INT)
     WHEN CarModel LIKE 'BMW X2 (F39)' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'BMW X4 (G02)' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'BMW 8 Series (G16)' THEN CAST(RAND()*200000 AS INT)
     WHEN CarModel LIKE 'BMW 8 Series (G15)' THEN CAST(RAND()*220000 AS INT)
     WHEN CarModel LIKE 'BMW Z4 (G29)' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'BMW 3 Series (G21)' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'BMW X1 (F48)' THEN CAST(RAND()*27000 AS INT)
    
	 WHEN CarModel LIKE 'Maseratti Quattroporte V S' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranTurismo' THEN CAST(RAND()*130000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranTurismo S' THEN CAST(RAND()*134000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranCabrio' THEN CAST(RAND()*170000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III' THEN CAST(RAND()*110000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III S' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III Diesel' THEN CAST(RAND()*140000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI S' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI GTS' THEN CAST(RAND()*155000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI Diesel' THEN CAST(RAND()*170000 AS INT)
     WHEN CarModel LIKE 'Maseratti MC20' THEN CAST(RAND()*200000 AS INT)

	 WHEN CarModel LIKE 'Mercedes W213 E-Class' THEN CAST(RAND()*180000 AS INT)
     WHEN CarModel LIKE 'Mercedes C257 CLS-Class' THEN CAST(RAND()*75000 AS INT)
     WHEN CarModel LIKE 'Mercedes W167 GLE-Class' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Mercedes W247 B-Class' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Mercedes C118 CLA-Class' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Mercedes X167 GLS-Class' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Mercedes W223 S-Class' THEN CAST(RAND()*200000 AS INT)
     WHEN CarModel LIKE 'Mercedes W206 C-Class' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Mercedes X243 EQB' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Mercedes V295 EQE' THEN CAST(RAND()*140000 AS INT)
     WHEN CarModel LIKE 'Mercedes-AMG One' THEN CAST(RAND()*280000 AS INT)

	 WHEN CarModel LIKE 'Renault Clio' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Renault Fluence Z.E.' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Renault Logan' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Renault Mégane' THEN CAST(RAND()*35000 AS INT)
     WHEN CarModel LIKE 'Renault Talisman' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Renault Zoe' THEN CAST(RAND()*45000 AS INT)
     WHEN CarModel LIKE 'Renault Alaskan' THEN CAST(RAND()*55000 AS INT)
     WHEN CarModel LIKE 'Renault Espace' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Renault Scénic' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Renault Arkana' THEN CAST(RAND()*75000 AS INT)
     WHEN CarModel LIKE 'Renault Koleos' THEN CAST(RAND()*80000 AS INT)
	
	 WHEN CarModel LIKE 'Volkswagen Golf' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Volkswagen ID.3' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Polo' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Up' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Arteon' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Passat' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Volkswagen ID.4' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'Volkswagen T-Cross' THEN CAST(RAND()*90000 AS INT)
     WHEN CarModel LIKE 'Volkswagen T-Roc' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Tiguan' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Touareg' THEN CAST(RAND()*120000 AS INT)

	 WHEN CarModel LIKE 'Ford Fiesta' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Ford Focus' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Ford Escort' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Ford Puma' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Ford Mondeo' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Ford Taurus' THEN CAST(RAND()*90000 AS INT)
     WHEN CarModel LIKE 'Ford Bronco' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Ford Bronco Sport' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'Ford Equator' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Ford Evos' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Ford Mustang Mach-E' THEN CAST(RAND()*230000 AS INT) 

	 WHEN CarModel LIKE 'Porshe Boxster' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Porshe 911' THEN CAST(RAND()*220000 AS INT)
     WHEN CarModel LIKE 'Porshe Cayenne' THEN CAST(RAND()*98000 AS INT)
     WHEN CarModel LIKE 'Porshe Macan' THEN CAST(RAND()*130000 AS INT)
     WHEN CarModel LIKE 'Porshe Panamera' THEN CAST(RAND()*170000 AS INT)
     WHEN CarModel LIKE 'Porshe Taycan' THEN CAST(RAND()*110000 AS INT)
     WHEN CarModel LIKE 'Porshe 918 Spyder' THEN CAST(RAND()*250000 AS INT)
     WHEN CarModel LIKE 'Porshe Carrera GT' THEN CAST(RAND()*300000 AS INT)
     WHEN CarModel LIKE 'Porshe 911 GT1 Straßenversion' THEN CAST(RAND()*330000 AS INT)
     WHEN CarModel LIKE 'Porshe 968' THEN CAST(RAND()*340000 AS INT)
     WHEN CarModel LIKE 'Porshe Speedster (991.2)' THEN CAST(RAND()*400000 AS INT)

	 WHEN CarModel LIKE 'Seat Mii Electric' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Seat Ibiza' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Seat León' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Seat Arona' THEN CAST(RAND()*45000 AS INT)
     WHEN CarModel LIKE 'Seat Panamera' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Seat Ateca' THEN CAST(RAND()*55000 AS INT)
     WHEN CarModel LIKE 'Seat Tarraco' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Seat León' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Seat Ateca' THEN CAST(RAND()*76000 AS INT)
     WHEN CarModel LIKE 'Seat Formentor' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Seat Born' THEN CAST(RAND()*83000 AS INT)
	
     WHEN CarModel LIKE 'Skoda Citigo' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Skoda Fabia' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Skoda Scala' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Skoda Rapid' THEN CAST(RAND()*62000 AS INT)
     WHEN CarModel LIKE 'Skoda Octavia' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Skoda Superb' THEN CAST(RAND()*100000 AS INT) 
     WHEN CarModel LIKE 'Skoda Enyaq' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Skoda Kamiq' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Skoda Karoq' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Skoda Kodiaq' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Skoda Kushaq' THEN CAST(RAND()*90000 AS INT)
	 END

GO

 UPDATE CarPrice 
 SET AdditionalStuff = CASE
     WHEN CarModel LIKE 'Audi A1' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Audi A3' THEN CAST(RAND()*12000 AS INT)
     WHEN CarModel LIKE 'Audi A4' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Audi A5' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Audi A6' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Audi A8' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Audi Q5' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Audi RS' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Audi GT' THEN CAST(RAND()*70000 AS INT) 
     WHEN CarModel LIKE 'Audi E'  THEN CAST(RAND()*3000 AS INT)
     WHEN CarModel LIKE 'Audi Q7' THEN CAST(RAND()*60000 AS INT) 
	 
	 WHEN CarModel LIKE 'Bentley Bentayga V8' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur V8' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT V8' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT Mulliner' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Bentley Bentayga First Edition' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Bentley Bentayga Speed' THEN CAST(RAND()*90000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT V8 Convertible' THEN CAST(RAND()*140000 AS INT)
     WHEN CarModel LIKE 'Bentley Continental GT Mulliner Convertible E' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Bentley Flying Spur' THEN CAST(RAND()*160000 AS INT)
  	 
	 WHEN CarModel LIKE 'BMW X1 (F48)' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'BMW 7 Series (G11)' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'BMW 5 Series (G31)' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'BMW 6 Series (G32)' THEN CAST(RAND()*5000 AS INT)
     WHEN CarModel LIKE 'BMW X2 (F39)' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'BMW X4 (G02)' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'BMW 8 Series (G16)' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'BMW 8 Series (G15)' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'BMW Z4 (G29)' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'BMW 3 Series (G21)' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'BMW X1 (F48)' THEN CAST(RAND()*12000 AS INT)
    
	 WHEN CarModel LIKE 'Maseratti Quattroporte V S' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranTurismo' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranTurismo S' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Maseratti GranCabrio' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III S' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Maseratti Ghibli III Diesel' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI S' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI GTS' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Maseratti Quattroporte VI Diesel' THEN CAST(RAND()*80000 AS INT)
     WHEN CarModel LIKE 'Maseratti MC20' THEN CAST(RAND()*100000 AS INT)

	 WHEN CarModel LIKE 'Mercedes W213 E-Class' THEN CAST(RAND()*90000 AS INT)
     WHEN CarModel LIKE 'Mercedes C257 CLS-Class' THEN CAST(RAND()*35000 AS INT)
     WHEN CarModel LIKE 'Mercedes W167 GLE-Class' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Mercedes W247 B-Class' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Mercedes C118 CLA-Class' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Mercedes X167 GLS-Class' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Mercedes W223 S-Class' THEN CAST(RAND()*100000 AS INT)
     WHEN CarModel LIKE 'Mercedes W206 C-Class' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Mercedes X243 EQB' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Mercedes V295 EQE' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Mercedes-AMG One' THEN CAST(RAND()*140000 AS INT)

	 WHEN CarModel LIKE 'Renault Clio' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Renault Fluence Z.E.' THEN CAST(RAND()*12000 AS INT)
     WHEN CarModel LIKE 'Renault Logan' THEN CAST(RAND()*14000 AS INT)
     WHEN CarModel LIKE 'Renault Mégane' THEN CAST(RAND()*15000 AS INT)
     WHEN CarModel LIKE 'Renault Talisman' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Renault Zoe' THEN CAST(RAND()*22000 AS INT)
     WHEN CarModel LIKE 'Renault Alaskan' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Renault Espace' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Renault Scénic' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Renault Arkana' THEN CAST(RAND()*35000 AS INT)
     WHEN CarModel LIKE 'Renault Koleos' THEN CAST(RAND()*40000 AS INT)
	
	 WHEN CarModel LIKE 'Volkswagen Golf' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Volkswagen ID.3' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Polo' THEN CAST(RAND()*20000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Up' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Arteon' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Passat' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Volkswagen ID.4' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Volkswagen T-Cross' THEN CAST(RAND()*45000 AS INT)
     WHEN CarModel LIKE 'Volkswagen T-Roc' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Tiguan' THEN CAST(RAND()*35000 AS INT)
     WHEN CarModel LIKE 'Volkswagen Touareg' THEN CAST(RAND()*60000 AS INT)

	 WHEN CarModel LIKE 'Ford Fiesta' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Ford Focus' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Ford Escort' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Ford Puma' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Ford Mondeo' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Ford Taurus' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Ford Bronco' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Ford Bronco Sport' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Ford Equator' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Ford Evos' THEN CAST(RAND()*50000 AS INT)
     WHEN CarModel LIKE 'Ford Mustang Mach-E' THEN CAST(RAND()*120000 AS INT) 

	 WHEN CarModel LIKE 'Porshe Boxster' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Porshe 911' THEN CAST(RAND()*110000 AS INT)
     WHEN CarModel LIKE 'Porshe Cayenne' THEN CAST(RAND()*49000 AS INT)
     WHEN CarModel LIKE 'Porshe Macan' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Porshe Panamera' THEN CAST(RAND()*70000 AS INT)
     WHEN CarModel LIKE 'Porshe Taycan' THEN CAST(RAND()*60000 AS INT)
     WHEN CarModel LIKE 'Porshe 918 Spyder' THEN CAST(RAND()*120000 AS INT)
     WHEN CarModel LIKE 'Porshe Carrera GT' THEN CAST(RAND()*150000 AS INT)
     WHEN CarModel LIKE 'Porshe 911 GT1 Straßenversion' THEN CAST(RAND()*160000 AS INT)
     WHEN CarModel LIKE 'Porshe 968' THEN CAST(RAND()*160000 AS INT)
     WHEN CarModel LIKE 'Porshe Speedster (991.2)' THEN CAST(RAND()*200000 AS INT)

	 WHEN CarModel LIKE 'Seat Mii Electric' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Seat Ibiza' THEN CAST(RAND()*15000 AS INT)
     WHEN CarModel LIKE 'Seat León' THEN CAST(RAND()*15000 AS INT)
     WHEN CarModel LIKE 'Seat Arona' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Seat Panamera' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Seat Ateca' THEN CAST(RAND()*25000 AS INT)
     WHEN CarModel LIKE 'Seat Tarraco' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Seat León' THEN CAST(RAND()*35000 AS INT)
     WHEN CarModel LIKE 'Seat Ateca' THEN CAST(RAND()*36000 AS INT)
     WHEN CarModel LIKE 'Seat Formentor' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Seat Born' THEN CAST(RAND()*30000 AS INT)
	
     WHEN CarModel LIKE 'Skoda Citigo' THEN CAST(RAND()*10000 AS INT)
     WHEN CarModel LIKE 'Skoda Fabia' THEN CAST(RAND()*12000 AS INT)
     WHEN CarModel LIKE 'Skoda Scala' THEN CAST(RAND()*15000 AS INT)
     WHEN CarModel LIKE 'Skoda Rapid' THEN CAST(RAND()*32000 AS INT)
     WHEN CarModel LIKE 'Skoda Octavia' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Skoda Superb' THEN CAST(RAND()*50000 AS INT) 
     WHEN CarModel LIKE 'Skoda Enyaq' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Skoda Kamiq' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Skoda Karoq' THEN CAST(RAND()*30000 AS INT)
     WHEN CarModel LIKE 'Skoda Kodiaq' THEN CAST(RAND()*40000 AS INT)
     WHEN CarModel LIKE 'Skoda Kushaq' THEN CAST(RAND()*45000 AS INT)
	 END

GO


UPDATE Carprice
SET Konckdown = 0.08
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 1)

UPDATE Carprice
SET Konckdown = 0.06
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 2)

UPDATE Carprice
SET Konckdown = 0.03
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 3)

UPDATE Carprice
SET Konckdown = 0.07
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 4)

UPDATE Carprice
SET Konckdown = 0.05
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 5)

UPDATE Carprice
SET Konckdown = 0.02
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 6)

UPDATE Carprice
SET Konckdown = 0.08
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 7)

UPDATE Carprice
SET Konckdown = 0.01
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 8)

UPDATE Carprice
SET Konckdown = 0.03
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 9)

UPDATE Carprice
SET Konckdown = 0.09
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 10)

UPDATE Carprice
SET Konckdown = 0.10
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 11)

UPDATE Carprice
SET Konckdown = 0.075
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 12)

UPDATE Carprice
SET Konckdown = 0.08
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 13)

UPDATE Carprice
SET Konckdown = 0.095
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 14)

UPDATE Carprice
SET Konckdown = 0.065
WHERE SPECIALCODE IN (Select SPECIALCODE FROM GREATCARTABLE WHERE WarehouseID = 15)

GO

UPDATE Carprice
SET TotalPrice = (BasePrice + ModelPrIce + AdditionalStuff)*(1-Konckdown) FROM Carprice

GO

CREATE TABLE SOLDCARS
(SPECIALCODE varchar(450) PRIMARY KEY, CarModel Varchar(450), TotalPrice Money, WarehouseID INT, [DATE] Smalldatetime) 

GO

CREATE TRIGGER TRG0004 ON CARPRICE
AFTER DELETE
AS
DECLARE @PRICE Varchar(450)
SELECT @PRICE = TotalPrice FROM CARPRICE
INSERT INTO SOLDCARS SELECT SPECIALCODE, CarModel, TotalPrice, WarehouseID, DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365), '2022-01-01') FROM DELETED
PRINT 'Car sold at' + @PRICE + 'price'

GO

DECLARE @i int = 0
WHILE @i < 300 
BEGIN
    SET @i = @i + 1
DELETE D FROM
(
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as ID, * FROM GREATCARTABLE) D
WHERE ID = (SELECT ROUND(RAND(CHECKSUM(NEWID()))*12500,0))
END

GO

SELECT * FROM SOLDCARS

GO

/* liquidate the * to query the data:

-- Average revenue from a sold car in march

SELECT AVG(TotalPrice) AS average_cost_of_sold_car_in_march FROM SOLDCARS WHERE CAST([DATE] as Date) like '%03%' 

-- Total Revenue from march:

SELECT SUM(TotalPrice) AS total_revenue_from_sold_cars FROM SOLDCARS WHERE CAST([DATE] as Date) like '%03%'

-- Sum of car sold in march (rows):

SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as ID FROM SOLDCARS WHERE CAST([DATE] as Date) like '%03%'

-- Number of cars sold in march: 

SELECT COUNT(ID) FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as ID FROM SOLDCARS WHERE CAST([DATE] as Date) like '%03%') AS ID

-- Employee with highest Revenue in March by ID number (WarehouseID):

SELECT TOP 1 WarehouseID, SUM(TotalPrice) As Emp_Revenue FROM SOLDCARS GROUP BY WarehouseID ORDER BY Emp_Revenue Desc

--Employee with highest Revenuein March by Name:

SELECT TOP 1 E.EmpName, SUM(TotalPrice) As Emp_Revenue FROM SOLDCARS AS O
INNER JOIN Oskar.Warehouse AS E
ON E.WarehouseID = O.WarehouseID
GROUP BY E.EmpName ORDER BY Emp_Revenue desc

GO
