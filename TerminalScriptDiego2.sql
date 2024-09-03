-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Terminal9')
BEGIN
    USE master;
    DROP DATABASE Terminal9;
END
GO

-- Crear la base de datos
CREATE DATABASE Terminal9;
GO
USE Terminal9;
GO

-- Eliminar y volver a crear las tablas
IF OBJECT_ID('TarjetaFrecuente', 'U') IS NOT NULL DROP TABLE TarjetaFrecuente;
CREATE TABLE TarjetaFrecuente (
    NumeroTarjetaFrecuente INT PRIMARY KEY,
    Millas INT CHECK (Millas >= 0),  -- Las millas no pueden ser negativas
    CodigoComida VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- Crear índice en CodigoComida para búsquedas rápidas
CREATE INDEX IX_TarjetaFrecuente_CodigoComida ON TarjetaFrecuente (CodigoComida);
GO

IF OBJECT_ID('CategoriaCliente', 'U') IS NOT NULL DROP TABLE CategoriaCliente;
CREATE TABLE CategoriaCliente (
    IdCategoriaCliente INT PRIMARY KEY,
    NombreCategoria VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- Crear índice en NombreCategoria para búsquedas rápidas
CREATE INDEX IX_CategoriaCliente_NombreCategoria ON CategoriaCliente (NombreCategoria);
GO

IF OBJECT_ID('Cliente', 'U') IS NOT NULL DROP TABLE Cliente;
CREATE TABLE Cliente (
    IdCliente INT PRIMARY KEY,
    FechaNacimiento DATE NOT NULL CHECK (FechaNacimiento <= GETDATE()),  -- La fecha de nacimiento debe ser anterior o igual a la actual
    Nombre VARCHAR(50) NOT NULL,
    NumeroTarjetaFrecuente INT NULL,
    IdCategoriaCliente INT NOT NULL,
    FOREIGN KEY (NumeroTarjetaFrecuente) REFERENCES TarjetaFrecuente(NumeroTarjetaFrecuente),
    FOREIGN KEY (IdCategoriaCliente) REFERENCES CategoriaCliente(IdCategoriaCliente)
);
GO

-- Crear índice en Nombre para búsquedas rápidas
CREATE INDEX IX_Cliente_Nombre ON Cliente (Nombre);
GO

IF OBJECT_ID('Pais', 'U') IS NOT NULL DROP TABLE Pais;
CREATE TABLE Pais (
    IdPais INT PRIMARY KEY,
    NombrePais VARCHAR(50) NOT NULL
);
GO

-- Crear índice en NombrePais para búsquedas rápidas
CREATE INDEX IX_Pais_NombrePais ON Pais (NombrePais);
GO

IF OBJECT_ID('Ciudad', 'U') IS NOT NULL DROP TABLE Ciudad;
CREATE TABLE Ciudad (
    IdCiudad INT PRIMARY KEY,
    NombreCiudad VARCHAR(50) NOT NULL,
    IdPais INT NOT NULL,
    FOREIGN KEY (IdPais) REFERENCES Pais(IdPais)
);
GO

-- Crear índice en NombreCiudad para búsquedas rápidas
CREATE INDEX IX_Ciudad_NombreCiudad ON Ciudad (NombreCiudad);
-- Crear índice en IdPais para búsquedas rápidas
CREATE INDEX IX_Ciudad_IdPais ON Ciudad (IdPais);
GO

IF OBJECT_ID('Aeropuerto', 'U') IS NOT NULL DROP TABLE Aeropuerto;
CREATE TABLE Aeropuerto (
    IdAeropuerto INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,  -- No permitir valores nulos
    IdCiudad INT NOT NULL,
    FOREIGN KEY (IdCiudad) REFERENCES Ciudad(IdCiudad)
);
GO

-- Crear índice en Nombre para búsquedas rápidas
CREATE INDEX IX_Aeropuerto_Nombre ON Aeropuerto (Nombre);
-- Crear índice en IdCiudad para búsquedas rápidas
CREATE INDEX IX_Aeropuerto_IdCiudad ON Aeropuerto (IdCiudad);
GO

IF OBJECT_ID('ModeloAvion', 'U') IS NOT NULL DROP TABLE ModeloAvion;
CREATE TABLE ModeloAvion (
    IdModeloAvion INT PRIMARY KEY,
    Descripcion VARCHAR(50) NOT NULL,
    Grafico VARCHAR(MAX) NULL
);
GO

-- Crear índice en Descripcion para búsquedas rápidas
CREATE INDEX IX_ModeloAvion_Descripcion ON ModeloAvion (Descripcion);
GO

IF OBJECT_ID('Avion', 'U') IS NOT NULL DROP TABLE Avion;
CREATE TABLE Avion (
    NumeroRegistroAvion VARCHAR(50) PRIMARY KEY,
    FechaInicioOperacion DATE CHECK (FechaInicioOperacion <= GETDATE()),  -- La fecha de inicio debe ser anterior o igual a la actual
    Estado VARCHAR(50) CHECK (Estado IN ('Activo', 'Inactivo')),  -- Restringir los valores a 'Activo' o 'Inactivo'
    IdModeloAvion INT NOT NULL,
    FOREIGN KEY (IdModeloAvion) REFERENCES ModeloAvion(IdModeloAvion)
);
GO

-- Crear índice en Estado para búsquedas rápidas
CREATE INDEX IX_Avion_Estado ON Avion (Estado);
-- Crear índice en FechaInicioOperacion para búsquedas rápidas
CREATE INDEX IX_Avion_FechaInicioOperacion ON Avion (FechaInicioOperacion);
GO

IF OBJECT_ID('Asiento', 'U') IS NOT NULL DROP TABLE Asiento;
CREATE TABLE Asiento (
    IdAsiento INT, 
    Tamano VARCHAR(50) NOT NULL,
    Numero INT NOT NULL CHECK (Numero > 0),  -- El número del asiento debe ser positivo
    Ubicacion VARCHAR(50) NOT NULL,
    IdModeloAvion INT NOT NULL,
    FOREIGN KEY (IdModeloAvion) REFERENCES ModeloAvion(IdModeloAvion),
    PRIMARY KEY (IdAsiento, IdModeloAvion)
);
GO

-- Crear índice en Tamano para búsquedas rápidas
CREATE INDEX IX_Asiento_Tamano ON Asiento (Tamano);
-- Crear índice en Numero para búsquedas rápidas
CREATE INDEX IX_Asiento_Numero ON Asiento (Numero);
-- Crear índice en Ubicacion para búsquedas rápidas
CREATE INDEX IX_Asiento_Ubicacion ON Asiento (Ubicacion);
GO

IF OBJECT_ID('NumeroVuelo', 'U') IS NOT NULL DROP TABLE NumeroVuelo;
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
GO

-- Crear índice en Descripcion para búsquedas rápidas
CREATE INDEX IX_NumeroVuelo_Descripcion ON NumeroVuelo (Descripcion);
-- Crear índice en Tipo para búsquedas rápidas
CREATE INDEX IX_NumeroVuelo_Tipo ON NumeroVuelo (Tipo);
-- Crear índice en HoraSalida para búsquedas rápidas
CREATE INDEX IX_NumeroVuelo_HoraSalida ON NumeroVuelo (HoraSalida);
-- Crear índice en IdAeropuertoInicio para búsquedas rápidas
CREATE INDEX IX_NumeroVuelo_IdAeropuertoInicio ON NumeroVuelo (IdAeropuertoInicio);
-- Crear índice en IdAeropuertoDestino para búsquedas rápidas
CREATE INDEX IX_NumeroVuelo_IdAeropuertoDestino ON NumeroVuelo (IdAeropuertoDestino);
GO

IF OBJECT_ID('Vuelo', 'U') IS NOT NULL DROP TABLE Vuelo;
CREATE TABLE Vuelo (
    IdVuelo INT PRIMARY KEY,
    FechaVuelo DATE NOT NULL CHECK (FechaVuelo >= GETDATE()),  -- La fecha del vuelo debe ser hoy o en el futuro
    HoraEmbarque DATETIME NOT NULL,
    PuertaEmbarque VARCHAR(50) NOT NULL,
    MostradorCheckIn VARCHAR(50) NOT NULL,
    IdNumeroVuelo INT NOT NULL,
    NrosDeReservas INT NOT NULL DEFAULT 0,
    FOREIGN KEY (IdNumeroVuelo) REFERENCES NumeroVuelo(IdNumeroVuelo)
);
GO

-- Crear índice en FechaVuelo para búsquedas rápidas
CREATE INDEX IX_Vuelo_FechaVuelo ON Vuelo (FechaVuelo);
-- Crear índice en HoraEmbarque para búsquedas rápidas
CREATE INDEX IX_Vuelo_HoraEmbarque ON Vuelo (HoraEmbarque);
-- Crear índice en PuertaEmbarque para búsquedas rápidas
CREATE INDEX IX_Vuelo_PuertaEmbarque ON Vuelo (PuertaEmbarque);
-- Crear índice en MostradorCheckIn para búsquedas rápidas
CREATE INDEX IX_Vuelo_MostradorCheckIn ON Vuelo (MostradorCheckIn);
GO

IF OBJECT_ID('CategoriaBoleto', 'U') IS NOT NULL DROP TABLE CategoriaBoleto;
CREATE TABLE CategoriaBoleto (
    IdCategoriaBoleto INT PRIMARY KEY,
    NombreCategoria VARCHAR(50) NOT NULL  -- No permitir valores nulos
);
GO

-- Crear índice en NombreCategoria para búsquedas rápidas
CREATE INDEX IX_CategoriaBoleto_NombreCategoria ON CategoriaBoleto (NombreCategoria);
GO

IF OBJECT_ID('Boleto', 'U') IS NOT NULL DROP TABLE Boleto;
CREATE TABLE Boleto (
    IdBoleto INT PRIMARY KEY,
    CodigoBoleto VARCHAR(50) NOT NULL,
    IdCliente INT NOT NULL,
    IdCategoriaBoleto INT NOT NULL,
    FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    FOREIGN KEY (IdCategoriaBoleto) REFERENCES CategoriaBoleto(IdCategoriaBoleto)
);
GO

-- Crear índice en CodigoBoleto para búsquedas rápidas
CREATE INDEX IX_Boleto_CodigoBoleto ON Boleto (CodigoBoleto);
-- Crear índice en IdCliente para búsquedas rápidas
CREATE INDEX IX_Boleto_IdCliente ON Boleto (IdCliente);
GO

IF OBJECT_ID('Reserva', 'U') IS NOT NULL DROP TABLE Reserva;
CREATE TABLE Reserva (
    IdReserva INT PRIMARY KEY,
    IdVuelo INT NOT NULL,
    IdCliente INT NOT NULL,
    FechaReserva DATETIME NOT NULL DEFAULT GETDATE(),  -- Fecha y hora en que se realiza la reserva
    EstadoReserva VARCHAR(50) NOT NULL CHECK (EstadoReserva IN ('Reservado', 'Cancelado')),  -- Estado de la reserva
    FOREIGN KEY (IdVuelo) REFERENCES Vuelo(IdVuelo),
    FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);
GO

-- Crear índice en IdVuelo para búsquedas rápidas
CREATE INDEX IX_Reserva_IdVuelo ON Reserva (IdVuelo);
-- Crear índice en EstadoReserva para búsquedas rápidas
CREATE INDEX IX_Reserva_EstadoReserva ON Reserva (EstadoReserva);
GO

IF OBJECT_ID('Cupon', 'U') IS NOT NULL DROP TABLE Cupon;
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
GO

-- Crear índice en FechaRedencion para búsquedas rápidas
CREATE INDEX IX_Cupon_FechaRedencion ON Cupon (FechaRedencion);
-- Crear índice en Clase para búsquedas rápidas
CREATE INDEX IX_Cupon_Clase ON Cupon (Clase);
-- Crear índice en Standby para búsquedas rápidas
CREATE INDEX IX_Cupon_Standby ON Cupon (Standby);
GO

IF OBJECT_ID('AsientoDisponible', 'U') IS NOT NULL DROP TABLE AsientoDisponible;
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
GO

-- Crear índice en IdVuelo para búsquedas rápidas
CREATE INDEX IX_AsientoDisponible_IdVuelo ON AsientoDisponible (IdVuelo);
-- Crear índice en IdAsiento para búsquedas rápidas
CREATE INDEX IX_AsientoDisponible_IdAsiento ON AsientoDisponible (IdAsiento);
-- Crear índice en IdModeloAvion para búsquedas rápidas
CREATE INDEX IX_AsientoDisponible_IdModeloAvion ON AsientoDisponible (IdModeloAvion);
-- Crear índice en IdCupon para búsquedas rápidas
CREATE INDEX IX_AsientoDisponible_IdCupon ON AsientoDisponible (IdCupon);
GO

IF OBJECT_ID('Equipaje', 'U') IS NOT NULL DROP TABLE Equipaje;
CREATE TABLE Equipaje (
    IdEquipaje INT PRIMARY KEY,
    Numero INT CHECK (Numero >= 1),  -- Al menos debe haber una pieza de equipaje
    Peso DECIMAL(10, 2) CHECK (Peso >= 0),  -- El peso no puede ser negativo
    TipoEquipaje VARCHAR(50) NOT NULL CHECK (TipoEquipaje IN ('Mano', 'Facturado')),
    IdCupon INT NOT NULL,
    IdBoleto INT NOT NULL,
    FOREIGN KEY (IdCupon, IdBoleto) REFERENCES Cupon(IdCupon, IdBoleto)
);
GO

-- Crear índice en Numero para búsquedas rápidas
CREATE INDEX IX_Equipaje_Numero ON Equipaje (Numero);
-- Crear índice en Peso para búsquedas rápidas
CREATE INDEX IX_Equipaje_Peso ON Equipaje (Peso);
-- Crear índice en TipoEquipaje para búsquedas rápidas
CREATE INDEX IX_Equipaje_TipoEquipaje ON Equipaje (TipoEquipaje);
GO

IF OBJECT_ID('DocumentoIdentidad', 'U') IS NOT NULL DROP TABLE DocumentoIdentidad;
CREATE TABLE DocumentoIdentidad (
    IdDocumentoIdentidad INT PRIMARY KEY,
    TipoDocumento VARCHAR(50) NOT NULL CHECK (TipoDocumento IN ('Pasaporte', 'Carnet de Identidad')),  -- Tipos de documentos permitidos
    NumeroDocumento VARCHAR(50) NOT NULL,
    IdCliente INT NOT NULL,
    FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
);
GO

-- Crear índice en TipoDocumento para búsquedas rápidas
CREATE INDEX IX_DocumentoIdentidad_TipoDocumento ON DocumentoIdentidad (TipoDocumento);
-- Crear índice en NumeroDocumento para búsquedas rápidas
CREATE INDEX IX_DocumentoIdentidad_NumeroDocumento ON DocumentoIdentidad (NumeroDocumento);
-- Crear índice en IdCliente para búsquedas rápidas
CREATE INDEX IX_DocumentoIdentidad_IdCliente ON DocumentoIdentidad (IdCliente);
GO

IF OBJECT_ID('CarnetIdentidad', 'U') IS NOT NULL DROP TABLE CarnetIdentidad;
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
GO

-- Crear índice en FechaVencimiento para búsquedas rápidas
CREATE INDEX IX_CarnetIdentidad_FechaVencimiento ON CarnetIdentidad (FechaVencimiento);
-- Crear índice en AutoridadEmisora para búsquedas rápidas
CREATE INDEX IX_CarnetIdentidad_AutoridadEmisora ON CarnetIdentidad (AutoridadEmisora);
-- Crear índice en IdCiudadEmision para búsquedas rápidas
CREATE INDEX IX_CarnetIdentidad_IdCiudadEmision ON CarnetIdentidad (IdCiudadEmision);
-- Crear índice en IdPaisEmision para búsquedas rápidas
CREATE INDEX IX_CarnetIdentidad_IdPaisEmision ON CarnetIdentidad (IdPaisEmision);
GO

IF OBJECT_ID('Pasaporte', 'U') IS NOT NULL DROP TABLE Pasaporte;
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
GO

-- Crear índice en FechaVencimiento para búsquedas rápidas
CREATE INDEX IX_Pasaporte_FechaVencimiento ON Pasaporte (FechaVencimiento);
-- Crear índice en TipoPasaporte para búsquedas rápidas
CREATE INDEX IX_Pasaporte_TipoPasaporte ON Pasaporte (TipoPasaporte);
-- Crear índice en Nacionalidad para búsquedas rápidas
CREATE INDEX IX_Pasaporte_Nacionalidad ON Pasaporte (Nacionalidad);
-- Crear índice en IdCiudadEmision para búsquedas rápidas
CREATE INDEX IX_Pasaporte_IdCiudadEmision ON Pasaporte (IdCiudadEmision);
-- Crear índice en IdPaisEmision para búsquedas rápidas
CREATE INDEX IX_Pasaporte_IdPaisEmision ON Pasaporte (IdPaisEmision);
GO

IF OBJECT_ID('Multa', 'U') IS NOT NULL DROP TABLE Multa;
CREATE TABLE Multa (
    IdMulta INT PRIMARY KEY,
    IdReserva INT NULL,
    IdBoleto INT NULL,
    Monto DECIMAL(10, 2) NOT NULL CHECK (Monto > 0),  -- El monto de la multa debe ser positivo
    FechaMulta DATETIME NOT NULL DEFAULT GETDATE(),  -- Fecha y hora en que se aplica la multa
    Concepto VARCHAR(50) NOT NULL,  -- Motivo de la multa
    FOREIGN KEY (IdReserva) REFERENCES Reserva(IdReserva),
	FOREIGN KEY (IdBoleto) REFERENCES Boleto(IdBoleto)
);
GO

-- Crear índice en Monto para búsquedas rápidas
CREATE INDEX IX_Multa_Monto ON Multa (Monto);
-- Crear índice en FechaMulta para búsquedas rápidas
CREATE INDEX IX_Multa_FechaMulta ON Multa (FechaMulta);
-- Crear índice en Concepto para búsquedas rápidas
CREATE INDEX IX_Multa_Concepto ON Multa (Concepto);
-- Crear índice en IdReserva para búsquedas rápidas
CREATE INDEX IX_Multa_IdReserva ON Multa (IdReserva);
-- Crear índice en IdBoleto para búsquedas rápidas
CREATE INDEX IX_Multa_IdBoleto ON Multa (IdBoleto);
GO

--------------------INSERTAR--DATOS-------------------------
-- Insertar datos en la tabla Pais
INSERT INTO Pais (IdPais, NombrePais) VALUES
(1, 'México'),
(2, 'Bolivia'),
(3, 'Estados Unidos'),
(4, 'España');

-- Insertar datos en la tabla Ciudad
INSERT INTO Ciudad (IdCiudad, NombreCiudad, IdPais) VALUES
(1, 'Ciudad de México', 1),
(2, 'La Paz', 2),
(3, 'Nueva York', 3),
(4, 'Madrid', 4);

-- Insertar datos en la tabla Aeropuerto
INSERT INTO Aeropuerto (IdAeropuerto, Nombre, IdCiudad) VALUES
(1, 'Aeropuerto Internacional de la Ciudad de México', 1),
(2, 'Aeropuerto Internacional El Alto', 2),
(3, 'Aeropuerto Internacional John F. Kennedy', 3),
(4, 'Aeropuerto Adolfo Suárez Madrid-Barajas', 4);

-- Insertar datos en la tabla ModeloAvion
INSERT INTO ModeloAvion (IdModeloAvion, Descripcion, Grafico) VALUES
(1, 'Boeing 737', NULL),
(2, 'Airbus A320', NULL),
(3, 'Boeing 777', NULL),
(4, 'Airbus A380', NULL);

-- Insertar datos en la tabla Avion
INSERT INTO Avion (NumeroRegistroAvion, FechaInicioOperacion, Estado, IdModeloAvion) VALUES
('XA-ABC', '2020-01-15', 'Activo', 1),
('CP-1234', '2019-06-23', 'Inactivo', 2),
('N-5678', '2018-03-10', 'Activo', 3),
('EC-9876', '2021-12-01', 'Activo', 4);

-- Insertar datos en la tabla Asiento
INSERT INTO Asiento (IdAsiento, Tamano, Numero, Ubicacion, IdModeloAvion) VALUES
(1, 'Regular', 1, 'Ventana', 1),
(2, 'Regular', 2, 'Pasillo', 1),
(3, 'Regular', 1, 'Ventana', 2),
(4, 'Regular', 2, 'Pasillo', 2);

-- Insertar datos en la tabla NumeroVuelo
INSERT INTO NumeroVuelo (IdNumeroVuelo, Descripcion, Tipo, Aerolinea, HoraSalida, IdAeropuertoInicio, IdAeropuertoDestino, IdModeloAvion) VALUES
(1, 'Vuelo Ciudad de México a La Paz', 'Comercial', 'Aeroméxico', '2024-09-15 08:00:00', 1, 2, 1),
(2, 'Vuelo La Paz a Nueva York', 'Comercial', 'Boliviana de Aviación', '2024-09-16 14:00:00', 2, 3, 2),
(3, 'Vuelo Nueva York a Madrid', 'Comercial', 'American Airlines', '2024-09-17 18:00:00', 3, 4, 3),
(4, 'Vuelo Madrid a Ciudad de México', 'Comercial', 'Iberia', '2024-09-18 10:00:00', 4, 1, 4);

-- Insertar datos en la tabla Vuelo
INSERT INTO Vuelo (IdVuelo, FechaVuelo, HoraEmbarque, PuertaEmbarque, MostradorCheckIn, IdNumeroVuelo) VALUES
(1, '2024-09-15', '07:30:00', 'A1', 'Counter 1', 1),
(2, '2024-09-16', '13:30:00', 'B2', 'Counter 3', 2),
(3, '2024-09-17', '17:30:00', 'C4', 'Counter 5', 3),
(4, '2024-09-18', '09:30:00', 'D6', 'Counter 7', 4);

-- Insertar datos en la tabla TarjetaFrecuente
INSERT INTO TarjetaFrecuente (NumeroTarjetaFrecuente, Millas, CodigoComida) VALUES
(1, 12000, 'Vegetariano'),
(2, 5000, 'Vegano'),
(3, 25000, 'Kosher'),
(4, 8000, 'Regular');

-- Insertar datos en la tabla CategoriaCliente
INSERT INTO CategoriaCliente (IdCategoriaCliente, NombreCategoria) VALUES
(1, 'Regular'),
(2, 'VIP'),
(3, 'Premium');

-- Insertar datos en la tabla Cliente
INSERT INTO Cliente (IdCliente, FechaNacimiento, Nombre, NumeroTarjetaFrecuente, IdCategoriaCliente) VALUES
(1, '1990-05-15', 'Juan Pérez', 1, 1),
(2, '1985-11-23', 'Ana Gómez', 2, 2),
(3, '1975-07-12', 'Carlos Sánchez', 3, 3),
(4, '2000-02-18', 'María Fernández', 4, 1);

-- Insertar datos en la tabla CategoriaBoleto
INSERT INTO CategoriaBoleto (IdCategoriaBoleto, NombreCategoria) VALUES
(1, 'Económica'),
(2, 'Business'),
(3, 'Primera Clase');

-- Insertar datos en la tabla Boleto
INSERT INTO Boleto (IdBoleto, CodigoBoleto, IdCliente, IdCategoriaBoleto) VALUES
(1, 'MX1234', 1, 1),
(2, 'BO5678', 2, 2),
(3, 'US9101', 3, 3),
(4, 'ES1121', 4, 1);

-- Insertar datos en la tabla Cupon
INSERT INTO Cupon (IdCupon, FechaRedencion, Clase, Standby, CodigoComida, IdBoleto, IdVuelo) VALUES
(1, '2024-09-15', 'Económica', 0, 'Vegetariano', 1, 1),
(2, '2024-09-16', 'Business', 1, 'Vegano', 2, 2),
(3, '2024-09-17', 'Primera Clase', 0, 'Kosher', 3, 3),
(4, '2024-09-18', 'Económica', 1, 'Regular', 4, 4);

-- Insertar datos en la tabla Equipaje
INSERT INTO Equipaje (IdEquipaje, Numero, Peso, TipoEquipaje, IdCupon, IdBoleto) VALUES
(1, 2, 23.5, 'Facturado', 1, 1),
(2, 1, 18.0, 'Facturado', 2, 2),
(3, 3, 30.2, 'Mano', 3, 3),
(4, 1, 20.0, 'Facturado', 4, 4);

-- Insertar datos en la tabla DocumentoIdentidad
INSERT INTO DocumentoIdentidad (IdDocumentoIdentidad, TipoDocumento, NumeroDocumento, IdCliente) VALUES
(1, 'Pasaporte', 'P123456', 1),
(2, 'Carnet de Identidad', 'CI654321', 2),
(3, 'Pasaporte', 'P987654', 3),
(4, 'Carnet de Identidad', 'CI123987', 4);

-- Insertar datos en la tabla CarnetIdentidad
INSERT INTO CarnetIdentidad (NumeroCarnet, IdDocumentoIdentidad, FechaVencimiento, AutoridadEmisora, IdCiudadEmision, IdPaisEmision) VALUES
(1, 2, '2025-12-31', 'SEGIP', 2, 2),
(2, 4, '2026-07-01', 'SEGIP', 2, 2);

-- Insertar datos en la tabla Pasaporte
INSERT INTO Pasaporte (NumeroPasaporte, IdDocumentoIdentidad, FechaVencimiento, TipoPasaporte, Nacionalidad, IdCiudadEmision, IdPaisEmision) VALUES
(1, 1, '2025-05-15', 'Ordinario', 'Mexicana', 1, 1),
(2, 3, '2026-10-20', 'Ordinario', 'Boliviana', 3, 3);


