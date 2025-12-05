# **📗 README — Haskell Project: Weather Data Analysis**

## **Project Title**

**Weather Data Analysis**

## **Project Description**

Weather Data Analysis is a functional-programming project built in Haskell.
The application processes and analyzes weather records using pure functions, list transformations, and higher-order functions.

It supports statistics, filtering, extreme-value detection, and CSV/text file loading.

---

## **Features**

### 🌡 Weather Statistics

* Average temperature
* Minimum and maximum temperatures
* Total precipitation

### 🔍 Filtering

* Filter by exact date or date range
* Filter by temperature threshold

### ⚠ Extreme Weather Detection

* Hottest days
* Days with highest precipitation
* Highest humidity or wind

### 📁 File I/O

* Load records from CSV/text
* Save analysis results to a file

---

## **Requirements**

* **GHC ≥ 9.0**
* **Stack** or **Cabal**
* Recommended OS: Linux/macOS/Windows (WSL)

---

## **Running the Program**

### **Using Stack**

```bash
stack run
```

### **Using GHC**

```bash
ghc Main.hs -o weather
./weather
```

---

## **Data Structure Example**

```haskell
data Weather = Weather {
    date :: String,
    tempMax :: Double,
    tempMin :: Double,
    precipitation :: Double,
    humidity :: Double,
    wind :: Double
}
```

---

## **Main Menu**

```
1 — Compute average temperature
2 — Find extreme temperature days
3 — Find days with maximum precipitation
4 — Filter records
5 — Load data from file
6 — Save results
0 — Exit
```

---

## **Example Usage**

```
Enter temperature threshold: 20
Records above threshold:
2024-05-01   Avg: 23.5°C
2024-05-02   Avg: 24.1°C
```

---

