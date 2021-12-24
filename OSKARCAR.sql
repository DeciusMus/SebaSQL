

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

CREATE TABLE GREATCARTABLE (CarManufacturer varchar(450), CarModel varchar(450), WarehouseID INT, SPECIALCODE varchar(450)
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




