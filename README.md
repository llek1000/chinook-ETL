# ETL proces Chinook

Cieľom projektu je navrhnúť a implementovať **dimenzionálny model** pre analýzu výkonnosti zamestnancov, správania zákazníkov a trendov v príjmoch spoločnosti na základe dostupných údajov z databázy **Chinook**. Tento model umožní sledovanie kľúčových metrík, ako sú celkové príjmy, počet zákazníkov a výkonnosť zamestnancov v rôznych časových obdobiach a geografických lokalitách.

---

## 1. Úvod a popis zdrojových dát

Zdrojové dáta pochádzajú z databázy **Chinook**, ktorá simuluje reálne obchodné prostredie digitálnej hudobnej spoločnosti. Databáza obsahuje údaje o zákazníkoch, zamestnancoch, faktúrach, skladbách, albumoch a interpretoch. Tieto údaje sú vhodné na analýzu predaja, výkonnosti zamestnancov a správania zákazníkov.

### 1.1 Popis tabuliek v databáze

1. `Employee`
- Obsahuje údaje o zamestnancoch spoločnosti.
- **Hlavné stĺpce:** `EmployeeId`, `FirstName`, `LastName`, `Title`, `HireDate`, `ReportsTo`.

2. `Customer`
- Obsahuje informácie o zákazníkoch, ktorí si zakúpili produkty alebo služby.
- **Hlavné stĺpce:** `CustomerId`, `FirstName`, `LastName`, `Country`, `City`, `SupportRepId` (odkaz na zamestnanca podpory).

3. `Invoice`
- Tabuľka faktúr obsahuje údaje o predaji produktov zákazníkom.
- **Hlavné stĺpce:** `InvoiceId`, `CustomerId`, `InvoiceDate`, `BillingCountry`, `Total`.

4. `InvoiceLine`
- Obsahuje detaily o jednotlivých položkách faktúry.
- **Hlavné stĺpce:** `InvoiceLineId`, `InvoiceId`, `TrackId`, `UnitPrice`, `Quantity`.

5. `Track`
- Obsahuje údaje o skladbách dostupných na predaj.
- **Hlavné stĺpce:** `TrackId`, `Name`, `AlbumId`, `GenreId`, `UnitPrice`.

6. `Album`
- Obsahuje údaje o albumoch, z ktorých pochádzajú jednotlivé skladby.
- **Hlavné stĺpce:** `AlbumId`, `Title`, `ArtistId`.

7. `Artist`
- Obsahuje údaje o interpretovi alebo skupine, ktorá nahrala albumy.
- **Hlavné stĺpce:** `ArtistId`, `Name`.

8. `Genre`
- Obsahuje informácie o hudobných žánroch skladieb.
- **Hlavné stĺpce:** `GenreId`, `Name`.

9. `MediaType`
- Obsahuje informácie o typoch médií, v ktorých sú skladby dostupné (napr. MP3, AAC).
- **Hlavné stĺpce:** `MediaTypeId`, `Name`.

10. `Playlist`
- Obsahuje informácie o playlistoch, ktoré boli vytvorené zákazníkmi.
- **Hlavné stĺpce:** `PlaylistId`, `Name`.

11. `PlaylistTrack`
- Obsahuje záznamy o skladbách priradených k playlistom.
- **Hlavné stĺpce:** `PlaylistId`, `TrackId`.

### 1.2 Dátová architektúra
### ERD diagram

<p align="center">
  <img src="https://github.com/llek1000/chinook-ETL/blob/main/Chinook_ERD.png" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>

---

## 2. Návrh dimenzionálneho modelu

Navrhnutý bol **hviezdicový model (star schema)** pre efektívnu analýzu, kde centrálny bod predstavuje faktová tabuľka **`Sales_Fact`**, ktorá je prepojená s nasledujúcimi dimenziami:

### Faktová tabuľka: Sales_Fact
Obsahuje hlavné transakčné údaje týkajúce sa predajov.

#### **Polia:**
- `Sales_FactId` - Unikátny identifikátor riadku faktúry
- `UnitPrice` - Cena za jednotku
- `Quantity` - Počet zakúpených položiek
- `InvoiceId` - Identifikátor faktúry
- `TrackId` - Identifikátor predanej skladby
- `DateId` - Identifikátor dátumu predaja
- `EmployeeId` - Identifikátor zamestnanca, ktorý uskutočnil predaj
- `GenreId` - Identifikátor žánru skladby
- `PlaylistId` - Identifikátor playlistu
- `ArtistId` - Identifikátor umelca
- `AlbumId` - Identifikátor albumu
- `InvoiceId` - Identifikátor faktúry v dimenzii

### Dimenzionálne tabuľky

1. **Employee_Dim (Zamestnanci)**
   - Obsahuje informácie o zamestnancoch vrátane ich osobných údajov a pracovných pozícií.
   - **Polia:** `EmployeeId`, `FirstName`, `LastName`, `Title`, `BirthDate`, `HireDate`, `Address`, `City`, `State`, `Country`, `Phone`, `Email`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

2. **Customer_Dim (Zákazníci)**
   - Obsahuje informácie o zákazníkoch vrátane ich kontaktných údajov a polohy.
   - **Polia:** `CustomerId`, `FirstName`, `LastName`, `Company`, `Address`, `City`, `State`, `Country`, `PostalCode`, `Phone`, `Fax`, `Email`, `SupportRepId`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

3. **Track_Dim (Skladby)**
   - Obsahuje podrobnosti o predávaných skladbách.
   - **Polia:** `TrackId`, `Name`, `Composer`, `Milliseconds`, `Bytes`, `UnitPrice`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

4. **Album_Dim (Albumy)**
   - Obsahuje podrobnosti o albumoch.
   - **Polia:** `AlbumId`, `Title`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

5. **Artist_Dim (Umelci)**
   - Obsahuje podrobnosti o umelcoch.
   - **Polia:** `ArtistId`, `Name`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

6. **Genre_Dim (Žánre)**
   - Obsahuje informácie o hudobných žánroch.
   - **Polia:** `GenreId`, `Name`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

7. **MediaType_Dim (Typy médií)**
   - Obsahuje informácie o typoch médií (napr. MP3, WAV, AAC).
   - **Polia:** `MediaTypeId`, `Name`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

8. **Invoice_Dim (Faktúry)**
   - Obsahuje informácie o faktúrach vrátane dátumu a miesta vystavenia.
   - **Polia:** `InvoiceId`, `CustomerId`, `InvoiceDate`, `BillingAddress`, `BillingCity`, `BillingState`, `BillingCountry`, `BillingPostalCode`, `Total`
   - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

9. **Playlist_Dim (Playlisty)**
    - Obsahuje informácie o playlistoch.
    - **Polia:** `PlaylistId`, `Name`
    - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

10. **Date_Dim (Dátumy)**
    - Obsahuje informácie o dátumoch.
    - **Polia:** `Dim_DateId`, `Date`, `Day`, `Month`, `Year`, `Weekday`, `Day_Week`, `Week`, `MonthString`
    - **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

<p align="center">
  <img src="https://github.com/llek1000/chinook-ETL/blob/main/StarScheme.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre Chinook</em>
</p>

---

## 3. ETL proces v nástroji Snowflake

ETL proces pozostával z troch hlavných fáz: `extrahovanie` (Extract), `transformácia` (Transform) a `načítanie` (Load). Tento proces bol implementovaný v Snowflake s cieľom pripraviť zdrojové dáta zo staging vrstvy do viacdimenzionálneho modelu vhodného na analýzu a vizualizáciu.

### 3.1 Extract (Extrahovanie dát)

Dáta zo zdrojového datasetu (formát `.csv`) boli najprv nahraté do Snowflake prostredníctvom interného stage úložiska s názvom `my_stage`. Stage v Snowflake slúži ako dočasné úložisko na import alebo export dát. Vytvorenie stage bolo zabezpečené príkazom:

```sql
CREATE OR REPLACE STAGE my_stage;
```

Do stage boli následne nahraté súbory obsahujúce údaje o umelcoch, albumoch, skladbách, zákazníkoch, zamestnancoch a faktúrach. Dáta boli importované do staging tabuliek pomocou príkazu `COPY INTO`. Pre každú tabuľku sa použil podobný príkaz:

```sql
COPY INTO Artist_staging
FROM @my_stage/artist.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

V prípade nekonzistentných záznamov bol použitý parameter `ON_ERROR = 'CONTINUE'`, ktorý zabezpečil pokračovanie procesu bez prerušenia pri chybách.

### 3.2 Transform (Transformácia dát)

V tejto fáze boli dáta zo staging tabuliek vyčistené, transformované a obohatené. Hlavným cieľom bolo pripraviť dimenzie a faktovú tabuľku, ktoré umožnia jednoduchú a efektívnu analýzu.

#### Transformácia pre dimenziu `Artist_Dim`:

```sql
CREATE TABLE Artist_Dim AS
SELECT
    ar.ArtistId,
    ar.Name
FROM Artist_staging ar;
```

#### Transformácia pre dimenziu `Album_Dim`:

```sql
CREATE TABLE Album_Dim AS
SELECT
    a.AlbumId,
    a.Title,
    a.ArtistId
FROM Album_staging a;
```

#### Transformácia pre dimenziu `MediaType_Dim`:

```sql
CREATE TABLE MediaType_Dim AS
SELECT
    m.MediaTypeId,
    m.Name
FROM MediaType_staging m;
```

#### Transformácia pre dimenziu `Genre_Dim`:

```sql
CREATE TABLE Genre_Dim AS
SELECT
    g.GenreId,
    g.Name
FROM Genre_staging g;
```

#### Transformácia pre dimenziu `Track_Dim`:

```sql
CREATE TABLE Track_Dim AS
SELECT
    t.TrackId,
    t.Name,
    t.Composer,
    t.Milliseconds,
    t.Bytes,
    t.UnitPrice,
    t.AlbumId,
    t.MediaTypeId,
    t.GenreId
FROM Track_staging t;
```

#### Transformácia pre dimenziu `Playlist_Dim`:

```sql
CREATE TABLE Playlist_Dim AS
SELECT
    p.PlaylistId,
    p.Name
FROM Playlist_staging p;
```

#### Transformácia pre dimenziu `Employee_Dim`:

```sql
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
```

#### Transformácia pre dimenziu `Customer_Dim`:

```sql
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
```

#### Transformácia pre dimenziu `Date_Dim`:

```sql
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
```

### 3.3 Load (Načítanie dát)

Po úspešnom vytvorení dimenzií a faktovej tabuľky boli dáta nahraté do finálnej štruktúry. Na záver boli staging tabuľky odstránené, aby sa optimalizovalo využitie úložiska:

```sql
DROP TABLE IF EXISTS Artist_staging;
DROP TABLE IF EXISTS Album_staging;
DROP TABLE IF EXISTS MediaType_staging;
DROP TABLE IF EXISTS Genre_staging;
DROP TABLE IF EXISTS Track_staging;
DROP TABLE IF EXISTS Playlist_staging;
DROP TABLE IF EXISTS PlaylistTrack_staging;
DROP TABLE IF EXISTS Employee_staging;
DROP TABLE IF EXISTS Customer_staging;
DROP TABLE IF EXISTS Invoice_staging;
DROP TABLE IF EXISTS InvoiceLine_staging;
```

ETL proces v Snowflake umožnil spracovanie pôvodných dát z `.csv` formátu do viacdimenzionálneho modelu typu hviezda. Tento proces zahŕňal čistenie, obohacovanie a reorganizáciu údajov. Výsledný model umožňuje analýzu predajov, výkonnosti zamestnancov a správania zákazníkov, pričom poskytuje základ pre vizualizácie a reporty.

---

## 4. Vizualizácia dát

Navrhnuté vizualizácie odpovedajú na dôležité otázky a odhaľujú kľúčové metriky. Zobrazená vizualizácia dát je nižšie.
<p align="center">
  <img src="https://github.com/llek1000/chinook-ETL/blob/main/Dashboard.png" alt="ERD Schema">
  <br>
  <em>Obrázok 3 Vizualizácia dát v Snowflake</em>
</p>

### Graf 1: Príjmy podľa zamestnancov
Táto vizualizácia zobrazuje celkové príjmy generované jednotlivými zamestnancami. Pomáha identifikovať najvýkonnejších zamestnancov.

```sql
SELECT 
    de.EmployeeId,
    de.FirstName || ' ' || de.LastName AS EmployeeName,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Employee_Dim de ON sf.EmployeeId = de.EmployeeId
GROUP BY de.EmployeeId, de.FirstName, de.LastName
ORDER BY TotalRevenue DESC;
```

### Graf 2: Výnosy podľa albumov
Táto vizualizácia zobrazuje celkové výnosy generované jednotlivými albumami. Pomáha identifikovať najpredávanejšie albumy.

```sql
SELECT 
    a.AlbumId,
    a.Title AS AlbumTitle,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Album_Dim a ON sf.AlbumId = a.AlbumId
GROUP BY a.AlbumId, a.Title
ORDER BY TotalRevenue DESC;
```

### Graf 3: Trend predaja v čase
Táto vizualizácia zobrazuje trend predaja v čase. Pomáha identifikovať sezónne trendy a výkyvy v predaji.

```sql
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
```

### Graf 4: Najlepšie predávajúce krajiny
Táto vizualizácia zobrazuje krajiny s najvyššími príjmami z predaja. Pomáha identifikovať najvýnosnejšie trhy.

```sql
SELECT 
    dc.Country,
    SUM(sf.UnitPrice * sf.Quantity) AS TotalRevenue
FROM Sales_Fact sf
JOIN Customer_Dim dc ON sf.CustomerId = dc.CustomerId
GROUP BY dc.Country
ORDER BY TotalRevenue DESC;
```

### Graf 5: Počet predaných skladieb podľa umelcov
Táto vizualizácia zobrazuje počet predaných skladieb podľa umelcov. Pomáha identifikovať najpopulárnejších umelcov.

```sql
SELECT 
    da.ArtistId,
    da.Name AS ArtistName,
    SUM(sf.Quantity) AS TotalSold
FROM Sales_Fact sf
JOIN Artist_Dim da ON sf.ArtistId = da.ArtistId
GROUP BY da.ArtistId, da.Name
ORDER BY TotalSold DESC;
```

**Autor:** Michal Bogdány
