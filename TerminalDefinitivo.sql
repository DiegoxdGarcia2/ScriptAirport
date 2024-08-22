-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Terminal6')
BEGIN
	USE master;
    DROP DATABASE Terminal6;
END

-- Crear la base de datos
CREATE DATABASE Terminal6;
go
USE Terminal6;
go

-- Crear las tablas y relaciones
CREATE TABLE FrequentFlyerCard (
    FFC_Number INT PRIMARY KEY,
    Miles INT,
    MealCode VARCHAR(50)
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    DateOfBirth DATE,
    [Name] VARCHAR(50),
    FFC_Number INT NULL,
    FOREIGN KEY (FFC_Number) REFERENCES FrequentFlyerCard(FFC_Number)
);

CREATE TABLE Airport (
    AirportID INT PRIMARY KEY,
    [Name] VARCHAR(50)
);

CREATE TABLE PlaneModel (
    ModelID INT PRIMARY KEY,
    [Description] VARCHAR(50),
    Graphic VARCHAR(MAX)
);

CREATE TABLE Airplane (
    RegistrationNumber VARCHAR(50) PRIMARY KEY,
    BeginOfOperation DATE,
    [Status] VARCHAR(50),
    ModelID INT,
    FOREIGN KEY (ModelID) REFERENCES PlaneModel(ModelID)
);

CREATE TABLE Seat (
    SeatID INT, 
    Size VARCHAR(50),
    Number INT,
    [Location] VARCHAR(50),
    ModelID INT,
    FOREIGN KEY (ModelID) REFERENCES PlaneModel(ModelID),
    PRIMARY KEY (SeatID, ModelID)
);

CREATE TABLE FlightNumber (
    FlightNumberID INT PRIMARY KEY,
    [Description] VARCHAR(50),
    Type VARCHAR(50),
    Airline VARCHAR(50),
    DepartureTime DATETIME,
    StartAirportID INT,
    GoalAirportID INT,
    PlaneModelID INT,
    FOREIGN KEY (StartAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (GoalAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(ModelID)
);

CREATE TABLE Flight (
    FlightID INT PRIMARY KEY,
    FlightDate DATE,
    BoardingTime DATETIME,
    Gate VARCHAR(50),
    CheckInCounter VARCHAR(50),
    FlightNumberID INT,
    FOREIGN KEY (FlightNumberID) REFERENCES FlightNumber(FlightNumberID)
);

CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY,
    TicketingCode VARCHAR(50),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Coupon (
    CouponID INT,
    DateOfRedemption DATE,
    [Class] VARCHAR(50),
    [Standby] BIT,
    MealCode VARCHAR(50),
    TicketID INT,
    FlightID INT,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    PRIMARY KEY (CouponID, TicketID)
);

CREATE TABLE AvailableSeat (
    FlightID INT,
    SeatID INT,
    ModelID INT,
    TicketID INT,
    CouponID INT,
    FOREIGN KEY (CouponID, TicketID) REFERENCES Coupon(CouponID, TicketID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    FOREIGN KEY (SeatID, ModelID) REFERENCES Seat(SeatID, ModelID),
    PRIMARY KEY (FlightID, SeatID, ModelID)
);

CREATE TABLE PiecesOfLuggage (
    LuggageID INT PRIMARY KEY,
    Number INT,
    [Weight] DECIMAL(10, 2),
    CouponID INT,
    TicketID INT,
    FOREIGN KEY (CouponID, TicketID) REFERENCES Coupon(CouponID, TicketID)
);

CREATE TABLE Country (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(50)
);

CREATE TABLE City (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(50),
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

-- Añadir la columna CityID a la tabla Airport
ALTER TABLE Airport 
ADD CityID INT;

-- Añadir la relación de clave foránea entre Airport y City
ALTER TABLE Airport 
ADD CONSTRAINT FK_CityID FOREIGN KEY (CityID) REFERENCES City(CityID);

CREATE TABLE IdentificationDocument (
    DocumentID INT PRIMARY KEY,
    DocumentType VARCHAR(50),  -- Ej: Pasaporte, Documento de identidad, etc.
    DocumentNumber VARCHAR(50),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE CarnetIdentidad (
    NroIDCarnet INT, 
    DocumentID INT, 
    ExpirationDate DATE,           -- Fecha de vencimiento del carnet
    IssuingAuthority VARCHAR(50),  -- Autoridad emisora (ej: SEGIP)
    PlaceOfIssueCityID INT,        -- Ciudad de emisión
    PlaceOfIssueCountryID INT,     -- País de emisión
    FOREIGN KEY (DocumentID) REFERENCES IdentificationDocument(DocumentID),
    FOREIGN KEY (PlaceOfIssueCityID) REFERENCES City(CityID),
    FOREIGN KEY (PlaceOfIssueCountryID) REFERENCES Country(CountryID),
    PRIMARY KEY (NroIDCarnet, DocumentID)
);

CREATE TABLE Passport (
    NroPassport INT,
    DocumentID INT, 
    ExpirationDate DATE,           -- Fecha de vencimiento del pasaporte
    PassportType VARCHAR(50),      -- Tipo de pasaporte (ej: Ordinario)
    Nationality VARCHAR(50),       -- Nacionalidad (ej: Boliviana)
    PlaceOfIssueCityID INT,        -- Ciudad de emisión
    PlaceOfIssueCountryID INT,     -- País de emisión
    FOREIGN KEY (DocumentID) REFERENCES IdentificationDocument(DocumentID),
    FOREIGN KEY (PlaceOfIssueCityID) REFERENCES City(CityID),
    FOREIGN KEY (PlaceOfIssueCountryID) REFERENCES Country(CountryID),
    PRIMARY KEY (NroPassport, DocumentID)
);

CREATE TABLE TicketCategory (
    TicketCategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50)  -- Ej: Económica, Business, Primera Clase
);

-- Añadir la columna TicketCategoryID a la tabla Ticket
ALTER TABLE Ticket 
ADD TicketCategoryID INT;

-- Añadir la relación de clave foránea entre Ticket y TicketCategory
ALTER TABLE Ticket
ADD CONSTRAINT FK_TicketCategoryID FOREIGN KEY (TicketCategoryID) REFERENCES TicketCategory(TicketCategoryID);

CREATE TABLE CustomerCategory (
    CustomerCategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50)  -- Ej: Regular, VIP, Premium
);

-- Añadir la columna CustomerCategoryID a la tabla Customer
ALTER TABLE Customer 
ADD CustomerCategoryID INT;

-- Añadir la relación de clave foránea entre Customer y CustomerCategory
ALTER TABLE Customer
ADD CONSTRAINT FK_CustomerCategoryID FOREIGN KEY (CustomerCategoryID) REFERENCES CustomerCategory(CustomerCategoryID);
