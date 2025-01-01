# Úvod a popis zdrojových dát
Tento projekt sa zameriava na analýzu faktúr a súvisiacich údajov pomocou dimenzionálneho modelu. Primárnym cieľom je získať prehľad o príjmoch, zákazníkoch, zamestnancoch a časových trendoch. Zdrojové dáta pochádzajú z databázy Chinook, ktorá obsahuje údaje o fakturácii, zákazníkoch a zamestnancoch. 

Analýza má za cieľ:
- Identifikovať výkonnosť zamestnancov, ktorí poskytujú podporu zákazníkom.
- Sledovať správanie zákazníkov podľa regiónov, krajín a ďalších demografických údajov.
- Analyzovať časové trendy vo fakturácii.

## Typ dát
Dáta sú štruktúrované v relačnej databáze s viacerými tabuľkami. Hlavnou tabuľkou pre analýzu je tabuľka faktúr, ktorá je prepojená s tabuľkami zákazníkov, zamestnancov a inými podpornými údajmi.

---

## Popis zdrojových tabuliek

### 1. **Tabuľka `Employee`**
- **Popis:** Obsahuje údaje o zamestnancoch, ktorí poskytujú podporu zákazníkom. Títo zamestnanci majú rôzne pozície a pracujú v rôznych mestách a krajinách.
- **Hlavné stĺpce:**
  - `EmployeeId`: Jedinečný identifikátor zamestnanca.
  - `FirstName`, `LastName`: Meno a priezvisko zamestnanca.
  - `Title`: Pozícia zamestnanca (napr. Sales Support Agent).
  - `ReportsTo`: Identifikátor nadriadeného zamestnanca.
  - `HireDate`: Dátum nástupu zamestnanca.

### 2. **Tabuľka `Customer`**
- **Popis:** Obsahuje údaje o zákazníkoch, ktorí realizovali objednávky. Táto tabuľka obsahuje demografické údaje, ako sú adresa, mesto, krajina a pridelený zamestnanec podpory.
- **Hlavné stĺpce:**
  - `CustomerId`: Jedinečný identifikátor zákazníka.
  - `FirstName`, `LastName`: Meno a priezvisko zákazníka.
  - `Country`, `City`: Krajina a mesto, kde sa zákazník nachádza.
  - `SupportRepId`: Identifikátor zamestnanca, ktorý poskytuje podporu tomuto zákazníkovi.

### 3. **Tabuľka `Invoice`**
- **Popis:** Hlavná tabuľka faktúr, ktorá obsahuje údaje o fakturácii a príjmoch. Táto tabuľka je kľúčová pre analýzu príjmov.
- **Hlavné stĺpce:**
  - `InvoiceId`: Jedinečný identifikátor faktúry.
  - `CustomerId`: Odkaz na zákazníka, ktorý objednávku realizoval.
  - `InvoiceDate`: Dátum vystavenia faktúry.
  - `BillingCity`, `BillingCountry`: Adresa zákazníka pre fakturáciu.
  - `Total`: Celková suma faktúry.

---

## Vzťahy medzi tabuľkami
- **`Employee` ↔ `Customer`:**  
  Každý zákazník má priradeného zamestnanca podpory (`SupportRepId`).
- **`Customer` ↔ `Invoice`:**  
  Každá faktúra je spojená s konkrétnym zákazníkom (`CustomerId`).
- **`Employee` ↔ `Invoice`:**  
  Zamestnanci majú nepriame spojenie s faktúrami cez zákazníkov.

---

## Účel analýzy
- **Zamestnanci:** Identifikácia výkonnosti zamestnancov v oblasti podpory zákazníkov a ich príspevok k príjmom.
- **Zákazníci:** Analýza správania zákazníkov, demografické rozdelenie a lokalizácia.
- **Faktúry:** Sledovanie príjmov, identifikácia trendov a sezónnosti na základe časovej dimenzie.

### Hlavné metriky
- **`Total`**: Celková suma faktúry. Táto metrika sa používa na analýzu príjmov podľa rôznych dimenzií (čas, zamestnanci, zákazníci, krajiny).
- **`InvoiceDateId`**: Odkaz na dimenziu času na analýzu trendov a sezónnosti.

### Kľúče
- **Primárny kľúč:**  
  - `InvoiceId`: Jedinečný identifikátor faktúry.
- **Cudzie kľúče:**  
  - `CustomerId` → `DimCustomer` (zákazníci).  
  - `InvoiceDateId` → `DimTime` (časová dimenzia).

---

## Dimenzia zákazníkov: `DimCustomer`

### Údaje
Obsahuje informácie o zákazníkoch, ktoré umožňujú analýzu na základe demografických údajov (krajina, mesto) alebo zodpovedných zamestnancov.

| **Stĺpec**       | **Popis**                      |
|-------------------|--------------------------------|
| `CustomerId`      | Primárny kľúč zákazníka.      |
| `FirstName`       | Krstné meno zákazníka.        |
| `LastName`        | Priezvisko zákazníka.         |
| `Country`         | Krajina zákazníka.            |
| `City`            | Mesto zákazníka.              |
| `SupportRepId`    | Odkaz na zamestnanca.         |

### Vzťah s faktovou tabuľkou
Každý zákazník môže mať viacero faktúr (1:N vzťah medzi `DimCustomer` a `InvoiceFact`).

### Typ dimenzie
**SCD typu 2 (Slowly Changing Dimension, Type 2)**  
- Pri zmene údajov o zákazníkovi (napr. adresa, mesto) je dôležité uchovávať historické údaje pre presnú analýzu.

---

## Dimenzia zamestnancov: `DimEmployee`

### Údaje
Obsahuje informácie o zamestnancoch, ktorí poskytujú podporu zákazníkom.

| **Stĺpec**       | **Popis**                      |
|-------------------|--------------------------------|
| `EmployeeId`      | Primárny kľúč zamestnanca.    |
| `FirstName`       | Krstné meno zamestnanca.      |
| `LastName`        | Priezvisko zamestnanca.       |
| `Title`           | Pozícia zamestnanca.          |
| `HireDate`        | Dátum nástupu zamestnanca.    |

### Vzťah s faktovou tabuľkou
Nepriama väzba cez `DimCustomer` (každý zákazník má priradeného zamestnanca).

### Typ dimenzie
**SCD typu 1 (Slowly Changing Dimension, Type 1)**  
- Pri zmene údajov (napr. titul, pozícia) sa aktualizujú údaje priamo, historické údaje sa neukladajú, pretože historický kontext zamestnancov nie je zvyčajne potrebný pre analýzu.

---

## Dimenzia času: `DimTime`

### Údaje
Detailné informácie o dátumoch faktúr, umožňujú analýzu trendov podľa rokov, mesiacov, dní alebo týždňov.

| **Stĺpec**       | **Popis**                      |
|-------------------|--------------------------------|
| `InvoiceDateId`   | Identifikátor dátumu (YYYYMMDD). |
| `Year`            | Rok faktúry.                  |
| `Month`           | Mesiac faktúry.               |
| `Day`             | Deň v mesiaci.                |
| `Week`            | Týždeň v roku.                |

### Vzťah s faktovou tabuľkou
Každá faktúra obsahuje dátum, na ktorý odkazuje (1:N vzťah medzi `DimTime` a `InvoiceFact`).

### Typ dimenzie
**Stabilná dimenzia (Fixed Dimension)**  
- Dimenzia času sa nemení, pretože je statická (dátumy sú nemenné).

---

## Typy dimenzií – zhrnutie

| **Dimenzia**       | **Typ dimenzie (SCD)**                           |
|---------------------|-------------------------------------------------|
| `DimCustomer`       | SCD typu 2 (historické údaje sa uchovávajú).    |
| `DimEmployee`       | SCD typu 1 (historické údaje sa neuchovávajú).  |
| `DimTime`           | Stabilná dimenzia (fixná, nemení sa).           |

---
