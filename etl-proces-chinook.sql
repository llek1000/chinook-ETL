CREATE DATABASE RACCOON_CHINOOK_DB;
USE DATABASE RACCOON_CHINOOK_DB;
CREATE SCHEMA RACCOON_CHINOOK_DB.STAGING;
USE SCHEMA RACCOON_CHINOOK_DB.STAGING;
CREATE OR REPLACE STAGE my_stage;

CREATE TABLE Artist_staging (
    ArtistId INT PRIMARY KEY,
    Name VARCHAR(120) 
);

CREATE TABLE Album_staging (
    AlbumId INT PRIMARY KEY,
    Title VARCHAR(160),
    ArtistId INT,
    FOREIGN KEY (ArtistId) REFERENCES Artist_staging(ArtistId)
);

CREATE TABLE MediaType_staging (
    MediaTypeId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Genre_staging (
    GenreId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE Track_staging (
    TrackId INT PRIMARY KEY,
    Name VARCHAR(200),
    AlbumId INT,
    MediaTypeId INT,
    GenreId INT,
    Composer VARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (AlbumId) REFERENCES Album_staging(AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES MediaType_staging(MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES Genre_staging(GenreId)
);

CREATE TABLE Playlist_staging (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

CREATE TABLE PlaylistTrack_staging (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES Playlist_staging(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

CREATE TABLE Employee_staging (
    EmployeeId INT PRIMARY KEY,
    FirstName VARCHAR(20),
    LastName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    FOREIGN KEY (ReportsTo) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Customer_staging (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(40),
    Company VARCHAR(80),
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    SupportRepId INT,
    FOREIGN KEY (SupportRepId) REFERENCES Employee_staging(EmployeeId)
);

CREATE TABLE Invoice_staging (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10, 2),
    FOREIGN KEY (CustomerId) REFERENCES Customer_staging(CustomerId)
);

CREATE TABLE InvoiceLine_staging (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    FOREIGN KEY (InvoiceId) REFERENCES Invoice_staging(InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES Track_staging(TrackId)
);

COPY INTO Artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Album_staging
FROM @my_stage/album.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO MediaType_staging
FROM @my_stage/mediatype.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Genre_staging
FROM @my_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Track_staging
FROM @my_stage/track.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Playlist_staging
FROM @my_stage/playlist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO PlaylistTrack_staging
FROM @my_stage/playlisttrack.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Employee_staging
FROM @my_stage/employee.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO Customer_staging
FROM @my_stage/customer.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO Invoice_staging
FROM @my_stage/invoice.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

COPY INTO InvoiceLine_staging
FROM @my_stage/invoiceline.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

CREATE TABLE Date_Dim AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY CAST(i.InvoiceDate AS DATE)) AS Dim_DateId,
    CAST(i.InvoiceDate AS DATE) AS Date,
    DATE_PART('day', i.InvoiceDate) AS Day,
    DATE_PART('month', i.InvoiceDate) AS Month,
    DATE_PART('year', i.InvoiceDate) AS Year,
    CASE
        WHEN DATE_PART('dow', i.InvoiceDate) = 0 THEN 'Sunday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 1 THEN 'Monday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 2 THEN 'Tuesday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 3 THEN 'Wednesday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 4 THEN 'Thursday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 5 THEN 'Friday'
        WHEN DATE_PART('dow', i.InvoiceDate) = 6 THEN 'Saturday'
    END AS Weekday,
    DATE_PART('dow', i.InvoiceDate) + 1 AS Day_Week,
    EXTRACT(WEEK FROM DATE_TRUNC('WEEK', i.InvoiceDate + INTERVAL '1 DAY')) AS Week,
    CASE
        WHEN DATE_PART('month', i.InvoiceDate) = 1 THEN 'January'
        WHEN DATE_PART('month', i.InvoiceDate) = 2 THEN 'February'
        WHEN DATE_PART('month', i.InvoiceDate) = 3 THEN 'March'
        WHEN DATE_PART('month', i.InvoiceDate) = 4 THEN 'April'
        WHEN DATE_PART('month', i.InvoiceDate) = 5 THEN 'May'
        WHEN DATE_PART('month', i.InvoiceDate) = 6 THEN 'June'
        WHEN DATE_PART('month', i.InvoiceDate) = 7 THEN 'July'
        WHEN DATE_PART('month', i.InvoiceDate) = 8 THEN 'August'
        WHEN DATE_PART('month', i.InvoiceDate) = 9 THEN 'September'
        WHEN DATE_PART('month', i.InvoiceDate) = 10 THEN 'October'
        WHEN DATE_PART('month', i.InvoiceDate) = 11 THEN 'November'
        WHEN DATE_PART('month', i.InvoiceDate) = 12 THEN 'December'
    END AS MonthString
FROM Invoice_staging i;

CREATE TABLE Track_Dim AS
SELECT
    t.TrackId,
    t.Name,
    t.Composer,
    t.Milliseconds,
    t.Bytes,
    t.UnitPrice
FROM Track_staging t;

CREATE TABLE Customer_Dim AS
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Company,
    c.Address,
    c.City,
    c.State,
    c.Country,
    c.PostalCode,
    c.Phone,
    c.Fax,
    c.Email,
    c.SupportRepId
FROM Customer_staging c;

CREATE TABLE Employee_Dim AS
SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    e.Title,
    e.BirthDate,
    e.HireDate,
    e.Address,
    e.City,
    e.State,
    e.Country,
    e.Phone,
    e.Email
FROM Employee_staging e;

CREATE TABLE Album_Dim AS
SELECT
    a.AlbumId,
    a.Title
FROM Album_staging a;

CREATE TABLE Artist_Dim AS
SELECT
    ar.ArtistId,
    ar.Name
FROM Artist_staging ar;

CREATE TABLE Genre_Dim AS
SELECT
    g.GenreId,
    g.Name
FROM Genre_staging g;

CREATE TABLE MediaType_Dim AS
SELECT
    m.MediaTypeId,
    m.Name
FROM MediaType_staging m;

CREATE TABLE Playlist_Dim AS
SELECT
    p.PlaylistId,
    p.Name
FROM Playlist_staging p;

CREATE TABLE Invoice_Dim AS
SELECT
    i.InvoiceId,
    i.CustomerId,
    i.InvoiceDate,
    i.BillingAddress,
    i.BillingCity,
    i.BillingState,
    i.BillingCountry,
    i.BillingPostalCode,
    i.Total
FROM Invoice_staging i;

CREATE OR REPLACE TABLE Sales_Fact AS
SELECT
    il.InvoiceLineId AS Sales_FactId,
    il.UnitPrice AS UnitPrice,
    il.Quantity AS Quantity,
    di.InvoiceId AS InvoiceId,
    dt.TrackId AS TrackId,
    dd.DateId AS DateId,
    de.EmployeeId AS EmployeeId,
    dg.GenreId AS GenreId,
    dp.PlaylistId AS PlaylistId,
    da.ArtistId AS ArtistId,
    a.AlbumId AS AlbumId,
    inv.InvoiceId AS InvoiceDimId
FROM InvoiceLine_staging il
JOIN Track_Dim dt ON il.TrackId = dt.TrackId
JOIN Invoice_staging di ON il.InvoiceId = di.InvoiceId
JOIN Date_Dim dd ON CAST(di.InvoiceDate AS DATE) = dd.Date
JOIN Customer_Dim dc ON di.CustomerId = dc.CustomerId
LEFT JOIN Employee_Dim de ON dc.SupportRepId = de.EmployeeId
LEFT JOIN Track_staging tr ON il.TrackId = tr.TrackId
LEFT JOIN PlaylistTrack_staging pt ON il.TrackId = pt.TrackId
LEFT JOIN Genre_Dim dg ON tr.GenreId = dg.GenreId
LEFT JOIN Playlist_Dim dp ON pt.PlaylistId = dp.PlaylistId
LEFT JOIN Album_staging al ON tr.AlbumId = al.AlbumId
LEFT JOIN Artist_staging ar ON al.ArtistId = ar.ArtistId
LEFT JOIN Artist_Dim da ON ar.ArtistId = da.ArtistId
LEFT JOIN Album_Dim a ON al.AlbumId = a.AlbumId
JOIN MediaType_Dim dm ON tr.MediaTypeId = dm.MediaTypeId
JOIN Invoice_Dim inv ON di.InvoiceId = inv.InvoiceId;

DROP TABLE IF EXISTS InvoiceLine_staging;
DROP TABLE IF EXISTS Invoice_staging;
DROP TABLE IF EXISTS Customer_staging;
DROP TABLE IF EXISTS Employee_staging;
DROP TABLE IF EXISTS PlaylistTrack_staging;
DROP TABLE IF EXISTS Playlist_staging;
DROP TABLE IF EXISTS Track_staging;
DROP TABLE IF EXISTS Genre_staging;
DROP TABLE IF EXISTS MediaType_staging;
DROP TABLE IF EXISTS Album_staging;
DROP TABLE IF EXISTS Artist_staging;