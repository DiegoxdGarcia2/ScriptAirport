-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Terminal7')
BEGIN
	USE master;
    DROP DATABASE Terminal7;
END

-- Crear la base de datos
CREATE DATABASE Terminal7;
go
USE Terminal7;
go

-- Crear las tablas y relaciones
CREATE TABLE TarjetaFrecuente (
    NumeroTarjetaFrecuente INT PRIMARY KEY,
    Millas INT CHECK (Millas >= 0),  -- Las millas no pueden ser negativas
    CodigoComida VARCHAR(50) NOT NULL  -- No permitir valores nulos
);

CREATE TABLE Cliente (
    IdCliente INT PRIMARY KEY,
    FechaNacimiento DATE NOT NULL CHECK (FechaNacimiento <= GETDATE()),  -- La fecha de nacimiento debe ser anterior o igual a la actual
    Nombre VARCHAR(50) NOT NULL,
    NumeroTarjetaFrecuente INT NULL,
    FOREIGN KEY (NumeroTarjetaFrecuente) REFERENCES TarjetaFrecuente(NumeroTarjetaFrecuente)
);

CREATE TABLE Aeropuerto (
    IdAeropuerto INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL  -- No permitir valores nulos
);

CREATE TABLE ModeloAvion (
    IdModeloAvion INT PRIMARY KEY,
    Descripcion VARCHAR(50) NOT NULL,
    Grafico VARCHAR(MAX) NULL
);

CREATE TABLE Avion (
    NumeroRegistroAvion VARCHAR(50) PRIMARY KEY,
    FechaInicioOperacion DATE CHECK (FechaInicioOperacion <= GETDATE()),  -- La fecha de inicio debe ser anterior o igual a la actual
    Estado VARCHAR(50) CHECK (Estado IN ('Activo', 'Inactivo')),  -- Restringir los valores a 'Activo' o 'Inactivo'
    IdModeloAvion INT NOT NULL,
    FOREIGN KEY (IdModeloAvion) REFERENCES ModeloAvion(IdModeloAvion)
);

CREATE TABLE Asiento (
    IdAsiento INT, 
    Tamano VARCHAR(50) NOT NULL,
    Numero INT NOT NULL CHECK (Numero > 0),  -- El número del asiento debe ser positivo
    Ubicacion VARCHAR(50) NOT NULL,
    IdModeloAvion INT NOT NULL,
    FOREIGN KEY (IdModeloAvion) REFERENCES ModeloAvion(IdModeloAvion),
    PRIMARY KEY (IdAsiento, IdModeloAvion)
);

CREATE TABLE NumeroVuelo (
    IdNumeroVuelo INT PRIMARY KEY,
    Descripcion VARCHAR(50) NOT NULL,
    Tipo VARCHAR(50) NOT NULL,
    Aerolinea VARCHAR(50) NOT NULL,
    HoraSalida DATETIME NOT NULL CHECK (HoraSalida > GETDATE()),  -- La hora de salida debe ser futura
    IdAeropuertoInicio INT NOT NULL,
    IdAeropuertoDestino INT NOT NULL,
    IdModeloAvion INT NOT NULL,
    FOREIGN KEY (IdAeropuertoInicio) REFERENCES Aeropuerto(IdAeropuerto),
    FOREIGN KEY (IdAeropuertoDestino) REFERENCES Aeropuerto(IdAeropuerto),
    FOREIGN KEY (IdModeloAvion) REFERENCES ModeloAvion(IdModeloAvion),
    CHECK (IdAeropuertoInicio <> IdAeropuertoDestino)  -- El aeropuerto de inicio y destino no pueden ser iguales
);

CREATE TABLE Vuelo (
    IdVuelo INT PRIMARY KEY,
    FechaVuelo DATE NOT NULL CHECK (FechaVuelo >= GETDATE()),  -- La fecha del vuelo debe ser hoy o en el futuro
    HoraEmbarque DATETIME NOT NULL,
    PuertaEmbarque VARCHAR(50) NOT NULL,
    MostradorCheckIn VARCHAR(50) NOT NULL,
    IdNumeroVuelo INT NOT NULL,
    FOREIGN KEY (IdNumeroVuelo) REFERENCES NumeroVuelo(IdNumeroVuelo)
);

CREATE TABLE Boleto (
    IdBoleto INT PRIMARY KEY,
    CodigoBoleto VARCHAR(50) NOT NULL,
    IdCliente INT NOT NULL,
    FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);

CREATE TABLE Cupon (
    IdCupon INT,
    FechaRedencion DATE CHECK (FechaRedencion >= GETDATE()),  -- La fecha de redención debe ser hoy o en el futuro
    Clase VARCHAR(50) NOT NULL CHECK (Clase IN ('Económica', 'Business', 'Primera Clase')),  -- Restringir los valores posibles de la clase
    Standby BIT NOT NULL,
    CodigoComida VARCHAR(50) NULL,
    IdBoleto INT NOT NULL,
    IdVuelo INT NOT NULL,
    FOREIGN KEY (IdBoleto) REFERENCES Boleto(IdBoleto),
    FOREIGN KEY (IdVuelo) REFERENCES Vuelo(IdVuelo),
    PRIMARY KEY (IdCupon, IdBoleto)
);

CREATE TABLE AsientoDisponible (
    IdVuelo INT,
    IdAsiento INT,
    IdModeloAvion INT,
    IdBoleto INT,
    IdCupon INT,
    FOREIGN KEY (IdCupon, IdBoleto) REFERENCES Cupon(IdCupon, IdBoleto),
    FOREIGN KEY (IdVuelo) REFERENCES Vuelo(IdVuelo),
    FOREIGN KEY (IdAsiento, IdModeloAvion) REFERENCES Asiento(IdAsiento, IdModeloAvion),
    PRIMARY KEY (IdVuelo, IdAsiento, IdModeloAvion)
);

CREATE TABLE Equipaje (
    IdEquipaje INT PRIMARY KEY,
    Numero INT CHECK (Numero >= 1),  -- Al menos debe haber una pieza de equipaje
    Peso DECIMAL(10, 2) CHECK (Peso >= 0),  -- El peso no puede ser negativo
    IdCupon INT NOT NULL,
    IdBoleto INT NOT NULL,
    FOREIGN KEY (IdCupon, IdBoleto) REFERENCES Cupon(IdCupon, IdBoleto)
);

CREATE TABLE Pais (
    IdPais INT PRIMARY KEY,
    NombrePais VARCHAR(50) NOT NULL
);

CREATE TABLE Ciudad (
    IdCiudad INT PRIMARY KEY,
    NombreCiudad VARCHAR(50) NOT NULL,
    IdPais INT NOT NULL,
    FOREIGN KEY (IdPais) REFERENCES Pais(IdPais)
);

-- Añadir la columna IdCiudad a la tabla Aeropuerto
ALTER TABLE Aeropuerto 
ADD IdCiudad INT NOT NULL;

-- Añadir la relación de clave foránea entre Aeropuerto y Ciudad
ALTER TABLE Aeropuerto 
ADD CONSTRAINT FK_IdCiudad FOREIGN KEY (IdCiudad) REFERENCES Ciudad(IdCiudad);

CREATE TABLE DocumentoIdentidad (
    IdDocumentoIdentidad INT PRIMARY KEY,
    TipoDocumento VARCHAR(50) NOT NULL CHECK (TipoDocumento IN ('Pasaporte', 'Carnet de Identidad')),  -- Tipos de documentos permitidos
    NumeroDocumento VARCHAR(50) NOT NULL,
    IdCliente INT NOT NULL,
    FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);

CREATE TABLE CarnetIdentidad (
    NumeroCarnet INT, 
    IdDocumentoIdentidad INT, 
    FechaVencimiento DATE NOT NULL CHECK (FechaVencimiento >= GETDATE()),  -- La fecha de vencimiento debe ser futura
    AutoridadEmisora VARCHAR(50) NOT NULL,  -- No permitir valores nulos
    IdCiudadEmision INT NOT NULL,
    IdPaisEmision INT NOT NULL,
    FOREIGN KEY (IdDocumentoIdentidad) REFERENCES DocumentoIdentidad(IdDocumentoIdentidad),
    FOREIGN KEY (IdCiudadEmision) REFERENCES Ciudad(IdCiudad),
    FOREIGN KEY (IdPaisEmision) REFERENCES Pais(IdPais),
    PRIMARY KEY (NumeroCarnet, IdDocumentoIdentidad)
);

CREATE TABLE Pasaporte (
    NumeroPasaporte INT,
    IdDocumentoIdentidad INT, 
    FechaVencimiento DATE NOT NULL CHECK (FechaVencimiento >= GETDATE()),  -- La fecha de vencimiento debe ser futura
    TipoPasaporte VARCHAR(50) NOT NULL,  -- No permitir valores nulos
    Nacionalidad VARCHAR(50) NOT NULL,  -- No permitir valores nulos
    IdCiudadEmision INT NOT NULL,
    IdPaisEmision INT NOT NULL,
    FOREIGN KEY (IdDocumentoIdentidad) REFERENCES DocumentoIdentidad(IdDocumentoIdentidad),
    FOREIGN KEY (IdCiudadEmision) REFERENCES Ciudad(IdCiudad),
    FOREIGN KEY (IdPaisEmision) REFERENCES Pais(IdPais),
    PRIMARY KEY (NumeroPasaporte, IdDocumentoIdentidad)
);

CREATE TABLE CategoriaBoleto (
    IdCategoriaBoleto INT PRIMARY KEY,
    NombreCategoria VARCHAR(50) NOT NULL  -- No permitir valores nulos
);

-- Añadir la columna IdCategoriaBoleto a la tabla Boleto
ALTER TABLE Boleto 
ADD IdCategoriaBoleto INT NOT NULL;

-- Añadir la relación de clave foránea entre Boleto y CategoriaBoleto
ALTER TABLE Boleto
ADD CONSTRAINT FK_IdCategoriaBoleto FOREIGN KEY (IdCategoriaBoleto) REFERENCES CategoriaBoleto(IdCategoriaBoleto);

CREATE TABLE CategoriaCliente (
    IdCategoriaCliente INT PRIMARY KEY,
    NombreCategoria VARCHAR(50) NOT NULL  -- No permitir valores nulos
);

-- Añadir la columna IdCategoriaCliente a la tabla Cliente
ALTER TABLE Cliente 
ADD IdCategoriaCliente INT NOT NULL;

-- Añadir la relación de clave foránea entre Cliente y CategoriaCliente
ALTER TABLE Cliente
ADD CONSTRAINT FK_IdCategoriaCliente FOREIGN KEY (IdCategoriaCliente) REFERENCES CategoriaCliente(IdCategoriaCliente);

GO
-- Insertar datos
INSERT INTO Pais (IdPais, NombrePais) VALUES
(1, 'México'),
(2, 'Bolivia'),
(3, 'Estados Unidos'),
(4, 'España');

INSERT INTO Ciudad (IdCiudad, NombreCiudad, IdPais) VALUES
(1, 'Ciudad de México', 1),
(2, 'La Paz', 2),
(3, 'Nueva York', 3),
(4, 'Madrid', 4);

INSERT INTO Aeropuerto (IdAeropuerto, Nombre, IdCiudad) VALUES
(1, 'Aeropuerto Internacional de la Ciudad de México', 1),
(2, 'Aeropuerto Internacional El Alto', 2),
(3, 'Aeropuerto Internacional John F. Kennedy', 3),
(4, 'Aeropuerto Adolfo Suárez Madrid-Barajas', 4);

INSERT INTO ModeloAvion (IdModeloAvion, Descripcion, Grafico) VALUES
(1, 'Boeing 737', NULL),
(2, 'Airbus A320', NULL),
(3, 'Boeing 777', NULL),
(4, 'Airbus A380', NULL);

INSERT INTO Avion (NumeroRegistroAvion, FechaInicioOperacion, Estado, IdModeloAvion) VALUES
('XA-ABC', '2020-01-15', 'Activo', 1),
('CP-1234', '2019-06-23', 'Inactivo', 2),
('N-5678', '2018-03-10', 'Activo', 3),
('EC-9876', '2021-12-01', 'Activo', 4);

INSERT INTO Asiento (IdAsiento, Tamano, Numero, Ubicacion, IdModeloAvion) VALUES
(1, 'Regular', 1, 'Ventana', 1),
(2, 'Regular', 2, 'Pasillo', 1),
(3, 'Regular', 1, 'Ventana', 2),
(4, 'Regular', 2, 'Pasillo', 2);

INSERT INTO NumeroVuelo (IdNumeroVuelo, Descripcion, Tipo, Aerolinea, HoraSalida, IdAeropuertoInicio, IdAeropuertoDestino, IdModeloAvion) VALUES
(1, 'Vuelo Ciudad de México a La Paz', 'Comercial', 'Aeroméxico', '2024-09-15 08:00:00', 1, 2, 1),
(2, 'Vuelo La Paz a Nueva York', 'Comercial', 'Boliviana de Aviación', '2024-09-16 14:00:00', 2, 3, 2),
(3, 'Vuelo Nueva York a Madrid', 'Comercial', 'American Airlines', '2024-09-17 18:00:00', 3, 4, 3),
(4, 'Vuelo Madrid a Ciudad de México', 'Comercial', 'Iberia', '2024-09-18 10:00:00', 4, 1, 4);

INSERT INTO Vuelo (IdVuelo, FechaVuelo, HoraEmbarque, PuertaEmbarque, MostradorCheckIn, IdNumeroVuelo) VALUES
(1, '2024-09-15', '07:30:00', 'A1', 'Counter 1', 1),
(2, '2024-09-16', '13:30:00', 'B2', 'Counter 3', 2),
(3, '2024-09-17', '17:30:00', 'C4', 'Counter 5', 3),
(4, '2024-09-18', '09:30:00', 'D6', 'Counter 7', 4);

INSERT INTO TarjetaFrecuente (NumeroTarjetaFrecuente, Millas, CodigoComida) VALUES
(1, 12000, 'Vegetariano'),
(2, 5000, 'Vegano'),
(3, 25000, 'Kosher'),
(4, 8000, 'Regular');

INSERT INTO CategoriaCliente (IdCategoriaCliente, NombreCategoria) VALUES
(1, 'Regular'),
(2, 'VIP'),
(3, 'Premium');

INSERT INTO Cliente (IdCliente, FechaNacimiento, Nombre, NumeroTarjetaFrecuente, IdCategoriaCliente) VALUES
(1, '1990-05-15', 'Juan Pérez', 1, 1),
(2, '1985-11-23', 'Ana Gómez', 2, 2),
(3, '1975-07-12', 'Carlos Sánchez', 3, 3),
(4, '2000-02-18', 'María Fernández', 4, 1);

INSERT INTO CategoriaBoleto (IdCategoriaBoleto, NombreCategoria) VALUES
(1, 'Económica'),
(2, 'Business'),
(3, 'Primera Clase');

INSERT INTO Boleto (IdBoleto, CodigoBoleto, IdCliente, IdCategoriaBoleto) VALUES
(1, 'MX1234', 1, 1),
(2, 'BO5678', 2, 2),
(3, 'US9101', 3, 3),
(4, 'ES1121', 4, 1);

INSERT INTO Cupon (IdCupon, FechaRedencion, Clase, Standby, CodigoComida, IdBoleto, IdVuelo) VALUES
(1, '2024-09-15', 'Económica', 0, 'Vegetariano', 1, 1),
(2, '2024-09-16', 'Business', 1, 'Vegano', 2, 2),
(3, '2024-09-17', 'Primera Clase', 0, 'Kosher', 3, 3),
(4, '2024-09-18', 'Económica', 1, 'Regular', 4, 4);

INSERT INTO Equipaje (IdEquipaje, Numero, Peso, IdCupon, IdBoleto) VALUES
(1, 2, 23.5, 1, 1),
(2, 1, 18.0, 2, 2),
(3, 3, 30.2, 3, 3),
(4, 1, 20.0, 4, 4);

INSERT INTO DocumentoIdentidad (IdDocumentoIdentidad, TipoDocumento, NumeroDocumento, IdCliente) VALUES
(1, 'Pasaporte', 'P123456', 1),
(2, 'Carnet de Identidad', 'CI654321', 2),
(3, 'Pasaporte', 'P987654', 3),
(4, 'Carnet de Identidad', 'CI123987', 4);

INSERT INTO CarnetIdentidad (NumeroCarnet, IdDocumentoIdentidad, FechaVencimiento, AutoridadEmisora, IdCiudadEmision, IdPaisEmision) VALUES
(1, 2, '2025-12-31', 'SEGIP', 2, 2),
(2, 4, '2026-07-01', 'SEGIP', 2, 2);

INSERT INTO Pasaporte (NumeroPasaporte, IdDocumentoIdentidad, FechaVencimiento, TipoPasaporte, Nacionalidad, IdCiudadEmision, IdPaisEmision) VALUES
(1, 1, '2025-05-15', 'Ordinario', 'Mexicana', 1, 1),
(2, 3, '2026-10-20', 'Ordinario', 'Boliviana', 3, 3);
