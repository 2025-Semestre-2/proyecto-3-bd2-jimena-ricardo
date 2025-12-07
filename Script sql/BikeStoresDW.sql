--CREATE DATABASE BikeStoresDW;

USE BikeStoresDW;

/*==============================================================
    DIMDATE (SCD1)
    - Necesaria porque el proyecto requiere análisis por día,
      mes, año y filtros por rango de fechas.
    - Se usa para 3 fechas del negocio:
        -> Fecha de Orden
        -> Fecha Requerida
        -> Fecha Envío
===============================================================*/
use BikeStoresDW

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,          
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
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,                     -- Business Key
    ProductName VARCHAR(255),
    BrandName VARCHAR(255),
    CategoryName VARCHAR(255),
    ModelYear SMALLINT,
    ListPrice DECIMAL(10,2),
    StartDate DATETIME,                   
    EndDate DATETIME                    
);



/*==============================================================
    DIMEMPLOYEE (SCD2)
    - Soporta el dashboard: “Top 10 empleados con más ventas”.
    - Permite ventas por sucursal (empleado pertenece tienda)
    - Cambios de tienda, jefe, estado.
===============================================================*/

CREATE TABLE DimEmployee (
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY, --- Surrogate Key
    EmployeeID INT,                    -- Business Key
    FullName VARCHAR(255),             -- Nombre + Apellidos
    Email VARCHAR(255),
    Phone VARCHAR(255),
    Active TINYINT,
    StoreID INT,
    ManagerID INT,
    StartDate DATETIME,                    -- Para SCD2
    EndDate DATETIME                     -- Para SCD2
);



/*==============================================================
    DIMCUSTOMER (SCD1)
    - Soporta el dashboard: “Top 10 clientes”
===============================================================*/

CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
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
    StoreKey INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
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
    OrderKey INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
    OrderID INT,
    CustomerID INT,
    StoreID INT,
    StaffID INT,
    Status TINYINT
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
    SalesKey INT IDENTITY(1,1),        ---Surrogate Key
    OrderKey INT,                       -- Factura / Orden
    ProductKey INT,                     -- Relación con DimProduct
    CustomerKey INT,                    -- Relación con DimCustomer
    EmployeeKey INT,                    -- Relación con DimEmployee
    StoreKey INT,                       -- Relación con DimStore
    DateOrderKey INT,                   -- Fecha de la orden
    DateRequiredKey INT,                -- Fecha requerida
    DateShippedKey INT,                 -- Fecha envío
    Quantity INT,                      -- Cantidad vendida
    UnitPrice DECIMAL(10,2),           -- Precio por unidad
    Discount DECIMAL(10,2),            -- Descuento aplicado
    LineTotal DECIMAL(18,2),           -- Total de la línea
    InvoiceCount INT                   -- Conteo de facturas (1 por orden)
PRIMARY KEY CLUSTERED 
(
	SalesKey ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([CustomerKey])
REFERENCES [dbo].[DimCustomer] ([CustomerKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[DimEmployee] ([EmployeeKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([OrderKey])
REFERENCES [dbo].[DimOrder] ([OrderKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([StoreKey])
REFERENCES [dbo].[DimStore] ([StoreKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([DateOrderKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([DateRequiredKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
ALTER TABLE FactSales  WITH CHECK ADD FOREIGN KEY([DateShippedKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO
