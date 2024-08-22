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


Go
-- Insertar datos
INSERT INTO Country (CountryID, CountryName) VALUES
(1, 'México'),
(2, 'Bolivia'),
(3, 'Estados Unidos'),
(4, 'España');

INSERT INTO City (CityID, CityName, CountryID) VALUES
(1, 'Ciudad de México', 1),
(2, 'La Paz', 2),
(3, 'Nueva York', 3),
(4, 'Madrid', 4);

INSERT INTO Airport (AirportID, [Name], CityID) VALUES
(1, 'Aeropuerto Internacional de la Ciudad de México', 1),
(2, 'Aeropuerto Internacional El Alto', 2),
(3, 'Aeropuerto Internacional John F. Kennedy', 3),
(4, 'Aeropuerto Adolfo Suárez Madrid-Barajas', 4);

INSERT INTO PlaneModel (ModelID, [Description], Graphic) VALUES
(1, 'Boeing 737', NULL),
(2, 'Airbus A320', NULL),
(3, 'Boeing 777', NULL),
(4, 'Airbus A380', NULL);

INSERT INTO Airplane (RegistrationNumber, BeginOfOperation, [Status], ModelID) VALUES
('XA-ABC', '2020-01-15', 'Operativo', 1),
('CP-1234', '2019-06-23', 'En Mantenimiento', 2),
('N-5678', '2018-03-10', 'Operativo', 3),
('EC-9876', '2021-12-01', 'Operativo', 4);

INSERT INTO Seat (SeatID, Size, Number, [Location], ModelID) VALUES
(1, 'Regular', 1, 'Ventana', 1),
(2, 'Regular', 2, 'Pasillo', 1),
(3, 'Regular', 1, 'Ventana', 2),
(4, 'Regular', 2, 'Pasillo', 2);

INSERT INTO FlightNumber (FlightNumberID, Description, Type, Airline, DepartureTime, StartAirportID, GoalAirportID, PlaneModelID) VALUES
(1, 'Vuelo Ciudad de México a La Paz', 'Comercial', 'Aeroméxico', '2024-09-15 08:00:00', 1, 2, 1),
(2, 'Vuelo La Paz a Nueva York', 'Comercial', 'Boliviana de Aviación', '2024-09-16 14:00:00', 2, 3, 2),
(3, 'Vuelo Nueva York a Madrid', 'Comercial', 'American Airlines', '2024-09-17 18:00:00', 3, 4, 3),
(4, 'Vuelo Madrid a Ciudad de México', 'Comercial', 'Iberia', '2024-09-18 10:00:00', 4, 1, 4);

INSERT INTO Flight (FlightID, FlightDate, BoardingTime, Gate, CheckInCounter, FlightNumberID) VALUES
(1, '2024-09-15', '07:30:00', 'A1', 'Counter 1', 1),
(2, '2024-09-16', '13:30:00', 'B2', 'Counter 3', 2),
(3, '2024-09-17', '17:30:00', 'C4', 'Counter 5', 3),
(4, '2024-09-18', '09:30:00', 'D6', 'Counter 7', 4);

INSERT INTO FrequentFlyerCard (FFC_Number, Miles, MealCode) VALUES
(1, 12000, 'Vegetariano'),
(2, 5000, 'Vegano'),
(3, 25000, 'Kosher'),
(4, 8000, 'Regular');

INSERT INTO CustomerCategory (CustomerCategoryID, CategoryName) VALUES
(1, 'Regular'),
(2, 'VIP'),
(3, 'Premium');

INSERT INTO Customer (CustomerID, DateOfBirth, [Name], FFC_Number, CustomerCategoryID) VALUES
(1, '1990-05-15', 'Juan Pérez', 1, 1),
(2, '1985-11-23', 'Ana Gómez', 2, 2),
(3, '1975-07-12', 'Carlos Sánchez', 3, 3),
(4, '2000-02-18', 'María Fernández', 4, 1);

INSERT INTO TicketCategory (TicketCategoryID, CategoryName) VALUES
(1, 'Económica'),
(2, 'Business'),
(3, 'Primera Clase');

INSERT INTO Ticket (TicketID, TicketingCode, CustomerID, TicketCategoryID) VALUES
(1, 'MX1234', 1, 1),
(2, 'BO5678', 2, 2),
(3, 'US9101', 3, 3),
(4, 'ES1121', 4, 1);

INSERT INTO Coupon (CouponID, DateOfRedemption, Class, [Standby], MealCode, TicketID, FlightID) VALUES
(1, '2024-09-15', 'Económica', 0, 'Vegetariano', 1, 1),
(2, '2024-09-16', 'Business', 1, 'Vegano', 2, 2),
(3, '2024-09-17', 'Primera Clase', 0, 'Kosher', 3, 3),
(4, '2024-09-18', 'Económica', 1, 'Regular', 4, 4);

INSERT INTO PiecesOfLuggage (LuggageID, Number, [Weight], CouponID, TicketID) VALUES
(1, 2, 23.5, 1, 1),
(2, 1, 18.0, 2, 2),
(3, 3, 30.2, 3, 3),
(4, 1, 20.0, 4, 4);

INSERT INTO IdentificationDocument (DocumentID, DocumentType, DocumentNumber, CustomerID) VALUES
(1, 'Pasaporte', 'P123456', 1),
(2, 'Carnet de Identidad', 'CI654321', 2),
(3, 'Pasaporte', 'P987654', 3),
(4, 'Carnet de Identidad', 'CI123987', 4);

INSERT INTO CarnetIdentidad (NroIDCarnet, DocumentID, ExpirationDate, IssuingAuthority, PlaceOfIssueCityID, PlaceOfIssueCountryID) VALUES
(1, 2, '2025-12-31', 'SEGIP', 2, 2),
(2, 4, '2026-07-01', 'SEGIP', 2, 2);

INSERT INTO Passport (NroPassport, DocumentID, ExpirationDate, PassportType, Nationality, PlaceOfIssueCityID, PlaceOfIssueCountryID) VALUES
(1, 1, '2025-05-15', 'Ordinario', 'Mexicana', 1, 1),
(2, 3, '2026-10-20', 'Ordinario', 'Boliviana', 3, 3);
