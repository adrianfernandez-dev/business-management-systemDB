-- ==========================================
-- 1. CREACIÓN DE BASE DE DATOS
-- ==========================================
CREATE DATABASE TopCabinets_DB;
GO

USE TopCabinets_DB;
GO

-- ==========================================
-- 2. TABLAS INDEPENDIENTES (Sin dependencias foráneas)
-- ==========================================

CREATE TABLE Roles (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Categorias (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255) NULL,
    Activo BIT DEFAULT 1
);
GO

CREATE TABLE Clientes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    NombreCompleto VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NULL,
    Telefono VARCHAR(20) NULL,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1
);
GO

-- ==========================================
-- 3. TABLAS DEPENDIENTES (Con Llaves Foráneas)
-- ==========================================

CREATE TABLE Usuarios (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RolId INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (RolId) REFERENCES Roles(Id)
);
GO

CREATE TABLE Productos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CategoriaId INT NOT NULL,
    CodigoProducto VARCHAR(50) NOT NULL UNIQUE,
    Nombre VARCHAR(200) NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL, -- CORREGIDO: Sin espacio
    StockActual INT NOT NULL DEFAULT 0,
    StockMinimo INT NOT NULL DEFAULT 5,
    Activo BIT DEFAULT 1,
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (CategoriaId) REFERENCES Categorias(Id)
);
GO

CREATE TABLE Ordenes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ClienteId INT NOT NULL,
    NumeroOrden VARCHAR(50) NOT NULL UNIQUE,
    FechaOrden DATETIME DEFAULT GETDATE(),
    TotalOrden DECIMAL(18,2) DEFAULT 0, 
    Estado VARCHAR(20) DEFAULT 'Pendiente', 
    CONSTRAINT FK_Ordenes_Clientes FOREIGN KEY (ClienteId) REFERENCES Clientes(Id)
);
GO

CREATE TABLE DetallesOrden (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrdenId INT NOT NULL,
    ProductoId INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL,
    Subtotal DECIMAL(18,2) NOT NULL, 
    CONSTRAINT FK_Detalles_Orden FOREIGN KEY (OrdenId) REFERENCES Ordenes(Id),
    CONSTRAINT FK_Detalles_Producto FOREIGN KEY (ProductoId) REFERENCES Productos(Id)
);
GO

CREATE TABLE Facturas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrdenId INT NOT NULL UNIQUE,
    NumeroFactura VARCHAR(50) NOT NULL UNIQUE,
    FechaEmision DATETIME DEFAULT GETDATE(),
    MontoTotal DECIMAL(18,2) NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Emitida', 
    CONSTRAINT FK_Facturas_Ordenes FOREIGN KEY (OrdenId) REFERENCES Ordenes(Id)
);
GO

-- ==========================================
-- 4. FUNCIONES Y TRIGGERS (Automatización)
-- ==========================================

CREATE FUNCTION dbo.fn_RequiereReabastecimiento (@ProductoId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Requiere BIT = 0;
    DECLARE @Stock INT, @Minimo INT;
    
    SELECT @Stock = StockActual, @Minimo = StockMinimo 
    FROM Productos WHERE Id = @ProductoId;

    IF (@Stock <= @Minimo)
        SET @Requiere = 1;

    RETURN @Requiere;
END;
GO

CREATE TRIGGER trg_InsertarDetalleOrden
ON DetallesOrden
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductoId INT, @Cantidad INT, @StockActual INT, @Precio DECIMAL(18,2);

    -- Obtener datos de la inserción
    SELECT @ProductoId = ProductoId, @Cantidad = Cantidad, @Precio = PrecioUnitario
    FROM inserted;

    -- Verificar stock disponible
    SELECT @StockActual = StockActual FROM Productos WHERE Id = @ProductoId;

    IF (@StockActual < @Cantidad)
    BEGIN
        RAISERROR ('No hay suficiente stock para el producto seleccionado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Insertar el registro con el subtotal calculado
    INSERT INTO DetallesOrden (OrdenId, ProductoId, Cantidad, PrecioUnitario, Subtotal)
    SELECT OrdenId, ProductoId, Cantidad, PrecioUnitario, (Cantidad * PrecioUnitario)
    FROM inserted;

    -- Descontar del inventario
    UPDATE Productos
    SET StockActual = StockActual - @Cantidad
    WHERE Id = @ProductoId;

    -- Actualizar el Total de la Orden
    UPDATE O
    SET O.TotalOrden = (SELECT SUM(Subtotal) FROM DetallesOrden WHERE OrdenId = O.Id)
    FROM Ordenes O
    INNER JOIN inserted I ON O.Id = I.OrdenId;
END;
GO

-- ==========================================
-- 5. INSERCIÓN DE DATOS DE PRUEBA 
-- ==========================================

INSERT INTO Roles (Nombre) VALUES ('Administrador'), ('Vendedor');
INSERT INTO Categorias (Nombre, Descripcion) VALUES 
('Gabinetes de Cocina', 'Estructuras base para cocinas'),
('Sobres de Mármol', 'Superficies de piedra natural'),
('Sobres de Granito', 'Superficies de alta resistencia');

INSERT INTO Productos (CategoriaId, CodigoProducto, Nombre, PrecioUnitario, StockActual) VALUES 
(1, 'GAB-001', 'Gabinete Base Estándar', 150.00, 20),
(2, 'MAR-001', 'Sobre Mármol Blanco Carrara (Metro)', 250.00, 15),
(3, 'GRA-001', 'Sobre Granito Negro Absoluto (Metro)', 180.00, 30);

INSERT INTO Clientes (NombreCompleto, Email) VALUES 
('Constructora ABC', 'compras@abc.com'),
('Juan Pérez', 'juanp@email.com');

INSERT INTO Usuarios (RolId, Nombre, Apellido, Email, PasswordHash) VALUES 
(1, 'Admin', 'Sistema', 'admin@topcabinets.com', 'HASH_AQUI');
GO
