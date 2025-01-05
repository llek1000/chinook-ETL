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

### 1.2 Dátová architektúra
### ERD diagram

<p align="center">
  <img src="https://github.com/llek1000/chinook-ETL/blob/main/Chinook_ERD.png" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>
