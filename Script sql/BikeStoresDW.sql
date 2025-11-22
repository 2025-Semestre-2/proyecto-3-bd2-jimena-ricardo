---CREATE DATABASE BikeStoresDW;

---USE BikeStoresDW;

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
