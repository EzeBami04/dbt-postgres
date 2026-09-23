# dbt-postgres manufacturing warehouse

This repository contains a dbt project for a PostgreSQL-based manufacturing data warehouse. It ingests staging source tables, standardizes them into staging models, and builds curated dimension and fact tables for analytics and operational reporting.

The project is organized as a dbt package under the [manufact](manufact) folder and includes a seeded data model diagram in [utils/images/data_model.jpg](utils/images/data_model.jpg).

## Overview

The warehouse is designed around a manufacturing domain with tables covering:

- production operations
- inventory and material usage
- sales orders and order items
- customers and employees
- maintenance and quality checks
- product and supplier-related dimension data

The dbt structure follows a common layered pattern:

- source definitions in [manufact/source.yml](manufact/source.yml)
- staging models in [manufact/models/staging](manufact/models/staging)
- analytical models in [manufact/models/ods](manufact/models/ods)
- project config in [manufact/dbt_project.yml](manufact/dbt_project.yml)
- connection config in [manufact/profiles.yml](manufact/profiles.yml)

## Repository structure

```text
.
├── .env                     # local environment variables for Postgres connection
├── .gitignore               # repository excludes
├── README.md                # project overview and developer setup
├── requirements.txt         # Python dependencies for dbt
├── logs/                    # runtime and dbt logs
├── manufact/                # dbt project root
│   ├── README.md            # dbt project-specific usage notes
│   ├── dbt_project.yml      # project config and materializations
│   ├── profiles.yml         # Postgres profile for dbt
│   ├── source.yml           # source table definitions
│   ├── analyses/
│   ├── macros/
│   ├── models/
│   │   ├── schema.yml       # model-level tests and descriptions
│   │   ├── staging/         # typed/staged source model views
│   │   └── ods/             # curated dimensions and facts
│   ├── seeds/
│   ├── snapshots/
│   ├── target/
│   └── tests/
├── post/                    # local Python virtual environment (gitignored)
├── utils/
│   └── images/
│       └── data_model.jpg
└── .github/
```

## Prerequisites

Before using the project, make sure you have:

- Python 3.10+ recommended
- PostgreSQL access credentials for the target warehouse
- dbt Core installed with the Postgres adapter
- environment variables for the connection setup

## Local setup

1. Clone the repository and open it in your editor.
2. Create or activate a Python virtual environment.
3. Install the project dependencies:

```bash
python -m pip install -r requirements.txt
```

4. Configure the database connection either via the local `.env` file or by exporting the same variables in your shell.

Required variables:

```bash
export HOST="your-postgres-host"
export USER="your-db-user"
export PASSWORD="your-db-password"
export DATABASE="your-database"
export SCHEMA="staging"
export PORT="5432"
```

The active profile in [manufact/profiles.yml](manufact/profiles.yml) expects those env vars.

## Running dbt

From the project directory:

```bash
cd manufact
```

Check the connection and profile setup:

```bash
dbt debug
```

Install any dbt dependencies if needed:

```bash
dbt deps
```

Run the full project:

```bash
dbt run
```

Run only the production fact pipeline:

```bash
dbt run --select fact_production
```

Run tests:

```bash
dbt test
```

Generate documentation:

```bash
dbt docs generate
dbt docs serve
```

## Data model and transformations

The project follows a layered model design:

- Staging layer: model names start with `stg_` and normalize source data types and filters.
- ODS layer: model names like `dim_*` and `fact_*` create business-ready analytics tables.
- Materializations:
  - staging models are materialized as views
  - ODS models are materialized as tables
  - the production fact uses incremental logic based on date windows

Examples of models currently in the project:

- staging: `stg_customers`, `stg_orders`, `stg_production`, `stg_inventory`, `stg_products`
- dimensions: `dim_customers`, `dim_products`, `dim_employees`
- facts: `fact_orders`, `fact_production`, `fact_inventory`, `fact_quality_checks`

## Source data

The source tables are declared in [manufact/source.yml](manufact/source.yml) and include:

- `customers`
- `employees`
- `inventory`
- `orders`
- `order_items`
- `production`
- `products`
- `quality_checks`
- `material_usage`
- `maintenance`

## Notes for contributors

- Keep model naming consistent with the staging and ODS patterns.
- Prefer small, reusable transformations rather than duplicating logic across models.
- Use tests defined in [manufact/models/schema.yml](manufact/models/schema.yml) to validate critical keys and data quality.
- Avoid committing local `target/` build artifacts or secrets from environment files.

## License

This project is intended for internal analytics and warehouse modeling use. Review the repository owner’s legal requirements before sharing or deploying it in another environment.

## Related files

- [manufact/dbt_project.yml](manufact/dbt_project.yml)
- [manufact/profiles.yml](manufact/profiles.yml)
- [manufact/source.yml](manufact/source.yml)
- [manufact/models/schema.yml](manufact/models/schema.yml)
- [utilities/data model image](utils/images/data_model.jpg)
