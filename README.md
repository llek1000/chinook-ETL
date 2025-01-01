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
