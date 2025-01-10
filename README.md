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

# Výkonnosť zamestnancov - Hviezdicový model (Star Schema)

Tento dokument poskytuje prehľad o hviezdicovom modeli navrhnutom na analýzu **výkonnosti zamestnancov** pomocou databázy Chinook. Model obsahuje centrálnu faktovú tabuľku a niekoľko dimenzionálnych tabuliek, ktoré umožňujú detailnú analýzu predajov.

---

## 🟠 Faktová tabuľka: Sales_Fact

Tabuľka **Sales_Fact** je centrálnou tabuľkou v hviezdicovom modeli a obsahuje hlavné transakčné údaje týkajúce sa predajov.

### **Polia:**
- `InvoiceLineID` - Unikátny identifikátor riadku faktúry
- `EmployeeID` - Identifikátor zamestnanca, ktorý uskutočnil predaj
- `CustomerID` - Identifikátor zákazníka, ktorý uskutočnil nákup
- `InvoiceID` - Identifikátor faktúry
- `TrackID` - Identifikátor predanej skladby
- `Quantity` - Počet zakúpených položiek
- `UnitPrice` - Cena za jednotku
- `TotalAmount` - Celková suma predaja
- `SaleDate` - Dátum predaja

---

## 🟢 Dimenzionálne tabuľky

### **1. Employee_Dim (Zamestnanci)**
Obsahuje informácie o zamestnancoch vrátane ich osobných údajov a pracovných pozícií.

#### **Polia:**
- `EmployeeID` - Unikátny identifikátor zamestnanca
- `LastName` - Priezvisko zamestnanca
- `FirstName` - Krstné meno zamestnanca
- `Title` - Pracovná pozícia
- `HireDate` - Dátum nástupu do práce
- `Address` - Adresa zamestnanca
- `City` - Mesto zamestnanca
- `Country` - Krajina zamestnanca
- `Phone` - Telefónne číslo zamestnanca
- `Email` - Emailová adresa zamestnanca

#### **Typ SCD:** SCD Typ 2 (Sledujú sa historické zmeny v údajoch zamestnanca)

---

### **2. Customer_Dim (Zákazníci)**
Obsahuje informácie o zákazníkoch vrátane ich kontaktných údajov a polohy.

#### **Polia:**
- `CustomerID` - Unikátny identifikátor zákazníka
- `FullName` - Celé meno zákazníka
- `Address` - Adresa zákazníka
- `City` - Mesto zákazníka
- `Country` - Krajina zákazníka
- `Phone` - Telefónne číslo zákazníka
- `Email` - Emailová adresa zákazníka
- `SupportRepID` - Identifikátor zamestnanca, ktorý spravuje zákazníka

#### **Typ SCD:** SCD Typ 2 (Sledujú sa historické zmeny v údajoch zákazníka)

---

### **3. Time_Dim (Časová dimenzia)**
Poskytuje podrobnosti o dátume a čase predaja.

#### **Polia:**
- `SaleDate` - Dátum predaja (primárny kľúč)
- `Year` - Rok predaja
- `Month` - Mesiac predaja
- `Day` - Deň predaja
- `Weekday` - Deň v týždni

#### **Typ SCD:** Nie je relevantné (Časové údaje sa nemenia)

---

### **4. Track_Dim (Skladby)**
Obsahuje podrobnosti o predávaných skladbách.

#### **Polia:**
- `TrackID` - Unikátny identifikátor skladby
- `Name` - Názov skladby
- `AlbumID` - Identifikátor albumu, do ktorého skladba patrí
- `GenreID` - Identifikátor žánru skladby
- `MediaTypeID` - Identifikátor typu média skladby
- `Composer` - Autor skladby
- `Milliseconds` - Dĺžka skladby v milisekundách
- `Bytes` - Veľkosť skladby v bajtoch
- `UnitPrice` - Cena za skladbu

#### **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

---

### **5. Album_Dim (Albumy)**
Obsahuje podrobnosti o albumoch.

#### **Polia:**
- `AlbumID` - Unikátny identifikátor albumu
- `Title` - Názov albumu
- `ArtistID` - Identifikátor umelca albumu

#### **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

---

### **6. Artist_Dim (Umelci)**
Obsahuje podrobnosti o umelcoch.

#### **Polia:**
- `ArtistID` - Unikátny identifikátor umelca
- `Name` - Názov umelca

#### **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

---

### **7. Genre_Dim (Žánre)**
Obsahuje informácie o hudobných žánroch.

#### **Polia:**
- `GenreID` - Unikátny identifikátor žánru
- `Name` - Názov žánru

#### **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)

---

### **8. MediaType_Dim (Typy médií)**
Obsahuje informácie o typoch médií (napr. MP3, WAV, AAC).

#### **Polia:**
- `MediaTypeID` - Unikátny identifikátor typu média
- `Name` - Názov typu média

#### **Typ SCD:** SCD Typ 1 (Zmeny sa prepíšu)


<p align="center">
  <img src="https://github.com/llek1000/chinook-ETL/blob/main/StarScheme.png" alt="ERD Schema">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma Chinook</em>
</p>

---
