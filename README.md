# Data Warehouse Project

A SQL Server-based data warehouse built on the **Medallion Architecture** (Bronze → Silver → Gold), integrating data from CRM and ERP source systems into a clean, analytics-ready Star Schema.

---

## Table of Contents

- [What the Project Does](#what-the-project-does)
- [Why the Project is Useful](#why-the-project-is-useful)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Data Model](#data-model)
- [Quality Checks](#quality-checks)
- [Where to Get Help](#where-to-get-help)
- [Contributing](#contributing)
- [License](#license)

---

## What the Project Does

This project implements a modern data warehouse on **Microsoft SQL Server** that consolidates data from two source systems:

- **CRM** — customer information, product catalogue, and sales transactions
- **ERP** — customer demographics, location data, and product category hierarchies

Raw source data is ingested and progressively refined through three layers until it is ready for business intelligence and reporting.

---

## Why the Project is Useful

- **End-to-end pipeline** — covers ingestion, cleansing, transformation, and analytical modelling in a single, reproducible codebase
- **Medallion Architecture** — keeps raw data untouched in Bronze, applies business rules in Silver, and exposes clean analytics-ready views in Gold
- **Star Schema** — the Gold layer delivers a classic dimensional model (`dim_customers`, `dim_products`, `fact_sales`) that works out of the box with any BI tool
- **Built-in quality gates** — SQL-based quality-check scripts catch data integrity issues at both the Silver and Gold layers before data reaches consumers
- **Fully scripted** — every object (schemas, tables, stored procedures, views) is created by idempotent SQL scripts so the warehouse can be rebuilt from scratch at any time

---

## Architecture Overview

```
Source Files (CSV)
       │
       ▼
┌─────────────┐
│   Bronze    │  Raw ingestion via BULK INSERT
│  (Staging)  │  No transformations applied
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Silver    │  Cleansed & standardised data
│ (Cleansed)  │  Deduplication, type casting, normalisation
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Gold     │  Business-ready Star Schema views
│(Analytical) │  dim_customers, dim_products, fact_sales
└─────────────┘
```

The architecture is illustrated in detail in the diagram files included in the repository:

| File | Description |
|------|-------------|
| `DAtaWareHouse.drawio` | Overall warehouse architecture |
| `DataFlowDiagram.drawio` | End-to-end data flow |
| `Integration_model.drawio` | Source system integration model |
| `data_model.drawio` | Star Schema data model |

> Open `.drawio` files with [draw.io](https://app.diagrams.net/) (free, browser-based).

---

## Project Structure

```
Datawarehouse/
├── datasets/               # Place source CSV files here before loading
├── docs/                   # Additional documentation
├── scripts/
│   ├── init_database.sql           # Create database and schemas
│   ├── bronze/
│   │   ├── ddl_bronze.sql          # Bronze table definitions
│   │   └── proc_load_bronze.sql    # Stored procedure: source → bronze
│   ├── silver/
│   │   ├── ddl_script.sql          # Silver table definitions
│   │   ├── proc_load_silver.sql    # Stored procedure: bronze → silver
│   │   └── Preprocessing_*.sql     # Exploratory preprocessing queries
│   └── gold/
│       └── ddl_gold.sql            # Gold view definitions (Star Schema)
├── tests/
│   ├── quality_checks_silver.sql   # Data quality checks for Silver layer
│   └── quality_checks_gold.sql     # Data quality checks for Gold layer
├── *.drawio                        # Architecture and data model diagrams
└── LICENSE
```

---

## Getting Started

### Prerequisites

- **Microsoft SQL Server** 2019 or later (Developer or Standard edition)
- **SQL Server Management Studio (SSMS)** 19+ or Azure Data Studio
- Source CSV files for the CRM and ERP datasets (place them in the `datasets/` folder)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/rudrabhavsar7/Datawarehouse.git
   cd Datawarehouse
   ```

2. **Initialise the database**

   Open `scripts/init_database.sql` in SSMS and execute it.  
   > ⚠️ **Warning:** This script drops and recreates the `DataWarehouse` database. Back up any existing data first.

   ```sql
   -- Creates the DataWarehouse database with bronze, silver, and gold schemas
   USE master;
   -- ... (run scripts/init_database.sql)
   ```

3. **Create Bronze tables**

   Execute `scripts/bronze/ddl_bronze.sql` against the `DataWarehouse` database.

4. **Create the Bronze load procedure**

   Execute `scripts/bronze/proc_load_bronze.sql`.  
   Then update the file paths inside the procedure to point to your local `datasets/` directory.

5. **Create Silver tables**

   Execute `scripts/silver/ddl_script.sql`.

6. **Create the Silver load procedure**

   Execute `scripts/silver/proc_load_silver.sql`.

7. **Create Gold views**

   Execute `scripts/gold/ddl_gold.sql`.

---

## Usage

### Loading Data

Run the stored procedures in order:

```sql
-- 1. Load raw data from CSV files into the Bronze layer
EXEC bronze.load_bronze;

-- 2. Cleanse and transform data from Bronze into Silver
EXEC silver.load_silver;

-- The Gold views are live — no additional load step is needed.
```

### Querying the Gold Layer

```sql
USE DataWarehouse;

-- Customer dimension
SELECT * FROM gold.dim_customers;

-- Product dimension (current products only)
SELECT * FROM gold.dim_products;

-- Sales fact table joined to dimensions
SELECT
    f.order_number,
    f.order_date,
    c.first_name,
    c.last_name,
    c.country,
    p.product_name,
    p.category,
    f.quantity,
    f.sales_amount
FROM gold.fact_sales f
JOIN gold.dim_customers c ON c.customer_key = f.customer_key
JOIN gold.dim_products  p ON p.product_key  = f.product_key;
```

---

## Data Model

The Gold layer follows a **Star Schema**:

| Object | Type | Description |
|--------|------|-------------|
| `gold.dim_customers` | View | Customer dimension with surrogate key, demographics, and location |
| `gold.dim_products` | View | Product dimension with surrogate key, category, and product line |
| `gold.fact_sales` | View | Sales facts linked to customer and product dimension keys |

### Source Tables

| Schema | Table | Source System | Description |
|--------|-------|---------------|-------------|
| bronze/silver | `crm_cust_info` | CRM | Customer master data |
| bronze/silver | `crm_prd_info` | CRM | Product catalogue |
| bronze/silver | `crm_sales_details` | CRM | Sales transactions |
| bronze/silver | `erp_cust_az12` | ERP | Customer demographics |
| bronze/silver | `erp_loc_a101` | ERP | Customer location |
| bronze/silver | `erp_px_cat_g1v2` | ERP | Product category hierarchy |

---

## Quality Checks

Quality check scripts are provided in the `tests/` directory. Run them after each layer load to validate the data.

```sql
-- After loading Silver
-- tests/quality_checks_silver.sql
-- Checks: null/duplicate PKs, unwanted spaces, standardisation, invalid dates, sales consistency

-- After loading Gold
-- tests/quality_checks_gold.sql
-- Checks: surrogate key uniqueness, referential integrity between fact and dimensions
```

All checks are written as `SELECT` statements — a query returning **zero rows** means the check passed.

---

## Where to Get Help

- **Issues:** Open a [GitHub Issue](https://github.com/rudrabhavsar7/Datawarehouse/issues) for bug reports or feature requests
- **Diagrams:** Open any `.drawio` file at [draw.io](https://app.diagrams.net/) for architecture details
- **SQL Server docs:** [Microsoft SQL Server Documentation](https://learn.microsoft.com/en-us/sql/sql-server/)

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes with clear messages
4. Push the branch and open a Pull Request

Please ensure all quality check scripts in `tests/` pass before submitting a PR.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

© 2026 Rudra Bhavsar
