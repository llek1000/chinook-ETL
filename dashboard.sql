-- Graf 1. Príjmy podľa zamestnancov
SELECT 
    de.EmployeeId,
    de.FirstName || ' ' || de.LastName AS EmployeeName,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Employee_Dim de ON sf.EmployeeId = de.EmployeeId
GROUP BY de.EmployeeId, de.FirstName, de.LastName
ORDER BY TotalRevenue DESC;



-- Graf 2. Výnosy podľa albumov
SELECT 
    a.AlbumId,
    a.Title AS AlbumTitle,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Album_Dim a ON sf.AlbumId = a.AlbumId
GROUP BY a.AlbumId, a.Title
ORDER BY TotalRevenue DESC;



-- Graf 3. Trend predaja v čase
SELECT 
    dd.Date,
    de.EmployeeId,
    de.FirstName || ' ' || de.LastName AS EmployeeName,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Date_Dim dd ON sf.DateId = dd.DateId
JOIN Employee_Dim de ON sf.EmployeeId = de.EmployeeId
GROUP BY dd.Date, de.EmployeeId, de.FirstName, de.LastName
ORDER BY dd.Date, de.EmployeeId;



-- Graf 4. Najlepšie predávajúce krajiny
SELECT 
    dc.Country,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Customer_Dim dc ON sf.CustomerId = dc.CustomerId
GROUP BY dc.Country
ORDER BY TotalRevenue DESC;



-- Graf 5. Počet predaných skladieb podľa umelcov
SELECT 
    da.ArtistId,
    da.Name AS ArtistName,
    SUM(sf.Quantity) AS TotalSold
FROM Sales_Fact sf
JOIN Artist_Dim da ON sf.ArtistId = da.ArtistId
GROUP BY da.ArtistId, da.Name
ORDER BY TotalSold DESC;