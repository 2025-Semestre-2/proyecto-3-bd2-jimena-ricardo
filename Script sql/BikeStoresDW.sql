---CREATE DATABASE BikeStoresDW;

USE BikeStoresDW;

select * from DimCustomer;

INSERT INTO DimDate (DateSK, FullDate, Year, Quarter, Month, MonthName, Day, DayOfWeek, DayName)
VALUES
(20240101, '2024-01-01', 2024, 1, 1, 'January', 1, 1, 'Monday'),
(20240102, '2024-01-02', 2024, 1, 1, 'January', 2, 2, 'Tuesday'),
(20240103, '2024-01-03', 2024, 1, 1, 'January', 3, 3, 'Wednesday'),
(20240201, '2024-02-01', 2024, 1, 2, 'February', 1, 4, 'Thursday');

INSERT INTO DimProduct (ProductID, ProductName, BrandName, CategoryName, ModelYear, ListPrice, StartDate, EndDate, IsCurrent)
VALUES
(1, 'Mountain Bike X1', 'Trek', 'Mountain Bikes', 2022, 900.00, '2024-01-01', '9999-12-31', 1),
(2, 'Road Bike R9', 'Giant', 'Road Bikes', 2023, 1200.00, '2024-01-01', '9999-12-31', 1),
(3, 'City Bike C3', 'Cannondale', 'City Bikes', 2021, 700.00, '2024-01-01', '9999-12-31', 1);


INSERT INTO DimCustomer (CustomerID, FullName, Email, Phone, Street, City, State, ZipCode)
VALUES
(101, 'Pedro Gómez', 'pedro@example.com', '555-1234', 'Calle Uno', 'Madrid', 'MD', '28001'),
(102, 'María Ruiz', 'maria@example.com', '555-5678', 'Calle Dos', 'Barcelona', 'BC', '08001'),
(103, 'Luis Torres', 'luis@example.com', '555-9999', 'Calle Tres', 'Valencia', 'VC', '46001');

INSERT INTO DimEmployee (EmployeeID, FullName, Email, Phone, Active, StoreID, ManagerID, StartDate, EndDate, IsCurrent)
VALUES
(201, 'Carlos Mendoza', 'carlos@bike.com', '555-1111', 1, 1, NULL, '2024-01-01', '9999-12-31', 1),
(202, 'Ana López', 'ana@bike.com', '555-2222', 1, 2, 201, '2024-01-01', '9999-12-31', 1);

INSERT INTO DimStore (StoreID, StoreName, City, State, ZipCode, Street)
VALUES
(1, 'BikeStore Central', 'Madrid', 'MD', '28001', 'Av. Central 100'),
(2, 'BikeStore Norte', 'Barcelona', 'BC', '08002', 'Av. Norte 20');

INSERT INTO DimOrder (OrderID, CustomerID, StoreID, StaffID, Status)
VALUES
(5001, 101, 1, 201, 1),
(5002, 102, 2, 202, 1),
(5003, 103, 1, 201, 1);

INSERT INTO FactSales
(ProductSK, CustomerSK, EmployeeSK, StoreSK, DateOrderSK, DateRequiredSK, DateShippedSK,
 Quantity, UnitPrice, Discount, LineTotal, InvoiceCount, OrderID)
VALUES
(1, 1, 1, 1, 20240101, 20240102, 20240103, 2, 900.00, 0.00, 1800.00, 1, 5001),

(2, 2, 2, 2, 20240102, 20240103, 20240103, 1, 1200.00, 50.00, 1150.00, 1, 5002),

(3, 3, 1, 1, 20240201, 20240201, 20240201, 3, 700.00, 0.00, 2100.00, 1, 5003);


SELECT * FROM DimProduct;
SELECT * FROM DimCustomer;
SELECT * FROM DimEmployee;
SELECT * FROM DimStore;

/*==============================================================
    DIMDATE (SCD1)
    - Necesaria porque el proyecto requiere análisis por día,
      mes, año y filtros por rango de fechas.
    - Se usa para 3 fechas del negocio:
        -> Fecha de Orden
        -> Fecha Requerida
        -> Fecha Envío
===============================================================*/

CREATE TABLE DimDate (
    DateSK INT PRIMARY KEY,            -- Clave sustituta AAAAMMDD, Surrogate Key
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(20),
    Day INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName VARCHAR(20)
);



/*==============================================================
    DIMPRODUCT (SCD2)
    - análisis por categoría, marca y producto.
    - historial de cambios de precio o atributos.
    - Soporta reporte de ventas (agrupado por categoría y marca)
===============================================================*/

CREATE TABLE DimProduct (
    ProductSK INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
    ProductID INT,                     -- Business Key
    ProductName VARCHAR(255),
    BrandName VARCHAR(255),
    CategoryName VARCHAR(255),
    ModelYear INT,
    ListPrice DECIMAL(10,2),
    StartDate DATE,                   
    EndDate DATE,                     
    IsCurrent BIT                      -- Para identificar la versión actual
);



/*==============================================================
    DIMEMPLOYEE (SCD2)
    - Soporta el dashboard: “Top 10 empleados con más ventas”.
    - Permite ventas por sucursal (empleado pertenece tienda)
    - Cambios de tienda, jefe, estado.
===============================================================*/

CREATE TABLE DimEmployee (
    EmployeeSK INT IDENTITY(1,1) PRIMARY KEY, --- Surrogate Key
    EmployeeID INT,                    -- Business Key
    FullName VARCHAR(255),             -- Nombre + Apellidos
    Email VARCHAR(255),
    Phone VARCHAR(255),
    Active INT,
    StoreID INT,
    ManagerID INT,
    StartDate DATE,                    -- Para SCD2
    EndDate DATE,                      -- Para SCD2
    IsCurrent BIT                      -- Para versión actual
);



/*==============================================================
    DIMCUSTOMER (SCD1)
    - Soporta el dashboard: “Top 10 clientes”
===============================================================*/

CREATE TABLE DimCustomer (
    CustomerSK INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
    CustomerID INT,
    FullName VARCHAR(255),             -- Nombre + apellidos
    Email VARCHAR(255),
    Phone VARCHAR(255),
    Street VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode VARCHAR(15)
);



/*==============================================================
    DIMSTORE (SCD1)
    - Requerimientos:
        -> Ventas por sucursal
        -> Mapa de sucursales
        -> Ventas por estado
===============================================================*/

CREATE TABLE DimStore (
    StoreSK INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
    StoreID INT,
    StoreName VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    ZipCode VARCHAR(15),
    Street VARCHAR(255)
);



/*==============================================================
    DIMORDER (SCD1)
    - Requerimiento: cantidad de facturas emitidas
    - Relaciona órdenes con clientes, tiendas y empleados
===============================================================*/

CREATE TABLE DimOrder (
    OrderSK INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
    OrderID INT,
    CustomerID INT,
    StoreID INT,
    StaffID INT,
    Status INT
);



/*==============================================================
    FACTSALES (TABLA DE HECHOS)

    Requisitos:
     Cantidades vendidas (Quantity)
     Total de ventas (LineTotal)
     Total de descuentos (Discount)
     Cantidad de facturas (InvoiceCount)
     Fechas clave (Order / Required / Shipped)
     Filtros: Cliente, Marca, Sucursal, Categoría
     Soporta el cubo, los reportes SSRS y el dashboard Power BI
===============================================================*/

CREATE TABLE FactSales (
    SalesSK INT IDENTITY(1,1) PRIMARY KEY,        ---Surrogate Key
    OrderID INT,                       -- Factura / Orden
    ProductSK INT,                     -- Relación con DimProduct
    CustomerSK INT,                    -- Relación con DimCustomer
    EmployeeSK INT,                    -- Relación con DimEmployee
    StoreSK INT,                       -- Relación con DimStore
    DateOrderSK INT,                   -- Fecha de la orden
    DateRequiredSK INT,                -- Fecha requerida
    DateShippedSK INT,                 -- Fecha envío
    Quantity INT,                      -- Cantidad vendida
    UnitPrice DECIMAL(10,2),           -- Precio por unidad
    Discount DECIMAL(10,2),            -- Descuento aplicado
    LineTotal DECIMAL(18,2),           -- Total de la línea
    InvoiceCount INT                   -- Conteo de facturas (1 por orden)
);
