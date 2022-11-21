-- GetGoodGPU DataMart Build
-- Rupert Hutton
-- Written 10/11/2022
--------------------------------------------

-- Builds GetGoodGPU Datamart
IF NOT EXISTS(Select * FROM sys.databases
	WHERE NAME = N'GetGoodGPUDM')
	CREATE DATABASE GetGoodGPUDM
GO

USE GetGoodGPUDM
GO
---
--- Drops Tables 
IF EXISTS(
	SELECT * 
	FROM sys.tables
	WHERE NAME = N'FactSales'
	)
	DROP TABLE FactSales;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimDate'
	)
	DROP TABLE DimDate;

IF EXISTS(
	SELECT * 
	FROM sys.tables
	WHERE NAME = N'DimCustomer'
	)
	DROP TABLE DimCustomer;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimSalesAssociate'
	)
	DROP TABLE DimSalesAssociate;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimGPU'
	)
	DROP TABLE DimGPU;

--- Builds tables

CREATE TABLE DimDate 
	(Date_SK			INT CONSTRAINT pk_date_sk PRIMARY KEY, 
	Date				DATE,
	FullDate			NCHAR(10), -- Date in MM-dd-yyyy format
	DayOfMonth			INT, -- Field will hold day number of Month
	DayName				NVARCHAR(9), -- Contains name of the day, Sunday, Monday 
	DayOfWeek			INT, -- First Day Sunday=1 and Saturday=7
	DayOfWeekInMonth	INT, -- 1st Monday or 2nd Monday in Month
	DayOfWeekInYear		INT,
	DayOfQuarter		INT,
	DayOfYear			INT,
	WeekOfMonth			INT, -- Week Number of Month 
	WeekOfQuarter		INT, -- Week Number of the Quarter
	WeekOfYear			INT, -- Week Number of the Year
	Month				INT, -- Number of the Month 1 to 12{}
	MonthName			NVARCHAR(9), -- January, February etc
	MonthOfQuarter		INT, -- Month Number belongs to Quarter
	Quarter				NCHAR(2), 
	QuarterName			NVARCHAR(9), -- First,Second...
	Year				INT, -- Year value of Date stored in Row
	YearName			NCHAR(7), -- CY 2017,CY 2018
	MonthYear			NCHAR(10), -- Jan-2018,Feb-2018
	MMYYYY				INT,
	FirstDayOfMonth		DATE,
	LastDayOfMonth		DATE,
	FirstDayOfQuarter	DATE,
	LastDayOfQuarter	DATE,
	FirstDayOfYear		DATE,
	LastDayOfYear		DATE,
	IsHoliday			BIT, -- Flag 1=National Holiday, 0-No National Holiday
	IsWeekday			BIT, -- 0=Week End ,1=Week Day
	Holiday				NVARCHAR(50), -- Name of Holiday in US
	Season				NVARCHAR(10) -- Name of Season
	);
--
CREATE TABLE DimCustomer
	(Customer_SK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_CustomerID_sk PRIMARY KEY,
	Customer_AK		INT NOT NULL,
	Customer_State NVARCHAR(50) NOT NULL,
	Customer_Date_of_Birth	DATE NOT NULL,
	Customer_Gender NVARCHAR(10) NOT NULL
		);

--
CREATE TABLE DimSalesAssociate
	(SalesAssociate_SK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_SalesAssociateID_sk PRIMARY KEY,
	SalesAssociate_AK		INT NOT NULL,
	SalesAssociate_Name NVARCHAR(50) NOT NULL,
	SalesAssociate_Date_of_Birth DATE NOT NULL,
	SalesAssociate_Hire_Date DATE NOT NULL,
	SalesAssociate_Gender NVARCHAR(10) NOT NULL,
	SalesAssociate_Specialty NVARCHAR(50) NOT NULL -- This indicates what specialty a sales associate has
		);

CREATE TABLE DimGPU
	(GPU_SK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_GPUID_sk PRIMARY KEY,
	GPU_AK		INT NOT NULL,
	GPU_Name NVARCHAR(50) NOT NULL,
	GPU_Company NVARCHAR(50) NOT NULL,
	GPU_Price MONEY NOT NULL,
	GPU_Packaging_Fancy NVARCHAR(50) NOT NULL, -- This indicates wheather the GPU comes in fancy packaging or not
	GPU_Raytracing NVARCHAR(10) NOT NULL, -- Raytracing is an advanced chip used in GPU's for better graphics when it comes to video games
	StartDate DATETIME NOT NULL,
	EndDate	 DATETIME NUll
		);

CREATE TABLE FactSales
	(SalesID_DD				    INT NOT NULL,
	Customer_SK					INT NOT NULL,
	SalesAssociate_SK			INT NOT NULL,
	GPU_SK						INT NOT NULL,
	OrderDateKey				INT NOT NULL,	--- OrderDateKey is used along with ShipDateKey to find how long it takes for orders to ship
	ShipDateKey					INT NOT NULL,
	Total_Price					MONEY NOT NULL,
	Quantity					INT NOT NULL
	CONSTRAINT pk_Fact_Sales PRIMARY KEY (SalesID_DD, Customer_SK, SalesAssociate_SK, GPU_SK, OrderDateKey,ShipDateKey),
	CONSTRAINT fk_dim_Customer FOREIGN KEY (Customer_SK) REFERENCES DimCustomer(Customer_SK),
	CONSTRAINT fk_dim_SalesAssociate FOREIGN KEY (SalesAssociate_SK) REFERENCES DimSalesAssociate(SalesAssociate_SK),
	CONSTRAINT fk_dim_GPU FOREIGN KEY (GPU_SK) REFERENCES DimGPU(GPU_SK),
	CONSTRAINT fk_order_dim_date FOREIGN KEY (OrderDateKey) REFERENCES DimDate(Date_SK),
	CONSTRAINT fk_ship_dim_date FOREIGN KEY (ShipDateKey) REFERENCES DimDate(Date_SK)
		);