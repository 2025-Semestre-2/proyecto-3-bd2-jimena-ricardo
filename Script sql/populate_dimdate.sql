--select * from dbo.DimDate
--delete from dbo.dimdate where 1=1

DECLARE @StartDate DATE, @EndDate DATE;

SET @startDate = (select min(min_date)
from
(
select min(order_date) as min_date from BikestoresST.sales.orders
union all
select min(required_date) as min_date from BikestoresST.sales.orders
union all
select min(shipped_date) as min_date from BikestoresST.sales.orders
) as min_dates)

SET @EndDate = (select max(max_date)
from
(
select max(order_date) as max_date from BikestoresST.sales.orders
union all
select max(required_date) as max_date from BikestoresST.sales.orders
union all
select max(shipped_date) as max_date from BikestoresST.sales.orders
) as max_dates)

SET NOCOUNT ON

--DECLARE @d DATE = @StartDate;
DECLARE @d DATE = @StartDate;

WHILE @d <= @EndDate
BEGIN
INSERT INTO dbo.DimDate (
    DateSK, FullDate, Year, Quarter, Month, MonthName, Day, DayOfWeek, DayName
) VALUES (
	CONVERT(char(8), @d, 112),
    @d,
    YEAR(@d),
    DATEPART(QUARTER, @d),
    MONTH(@d),
    DATENAME(MONTH, @d),
    DAY(@d),
    DATEPART(WEEKDAY, @d),
    DATENAME(WEEKDAY, @d)
);
SET @d = DATEADD(DAY, 1, @d);
END
GO

SET NOCOUNT OFF
GO