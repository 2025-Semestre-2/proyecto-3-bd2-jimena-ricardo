--CREATE DATABASE BikeStoresDW;
USE BikeStoresDW;

CREATE TABLE	[dbo].[DimDate]
	(	[DateKey] INT primary key, 
		[Date] DATETIME,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday] BIT,-- 0=Week End ,1=Week Day
		[HolidayUSA] VARCHAR(50),--Name of Holiday in US
		[IsHolidayUK] BIT Null,-- Flag 1=National Holiday, 0-No National Holiday
		[HolidayUK] VARCHAR(50) Null --Name of Holiday in UK
	)
GO


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
	OrderID INT,
    OrderKey INT IDENTITY(1,1) PRIMARY KEY, ---Surrogate Key
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
