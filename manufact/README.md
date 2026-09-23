# Manufacturing dbt project

This folder contains the dbt project used to build the manufacturing data warehouse. It transforms raw PostgreSQL source data into cleaned staging tables and analytics-ready dimension/fact models.

## Project purpose

The project is designed to support operational and analytical reporting across the manufacturing process, with focus on:

- production output and quality
- material and inventory usage
- maintenance events
- order and customer performance
- employee and product dimensions

## dbt project layout

```text
manufact/
├── dbt_project.yml
├── profiles.yml
├── source.yml
├── analyses/
├── macros/
├── models/
│   ├── schema.yml
│   ├── staging/
│   └── ods/
├── seeds/
├── snapshots/
├── target/
├── tests/
└── logs/
```

## Configuration

The project is configured to use a PostgreSQL profile named `manufact` and reads its database credentials from environment variables:

- `HOST`
- `USER`
- `PASSWORD`
- `DATABASE`
- `SCHEMA`
- `PORT`

These values are consumed by [profiles.yml](profiles.yml) and the source definitions in [source.yml](source.yml).

## Model conventions

- staging models begin with `stg_`
- fact and dimension models live under `models/ods`
- models are defined with descriptions and tests in [models/schema.yml](models/schema.yml)
- the project uses views for staging and tables for curated warehouse data

## Common commands

```bash
dbt debug

dbt deps

dbt run

dbt test

dbt run --select fact_production

dbt docs generate
dbt docs serve
```

## Notes

- The raw source schema is expected to be `staging` unless you change the env var values.
- The production fact model uses incremental logic and a rolling date filter.
- The project is intended to be run from the repository root by changing into the `manufact` directory first.

## Useful references

- [../README.md](../README.md)
- [dbt_project.yml](dbt_project.yml)
- [profiles.yml](profiles.yml)
- [source.yml](source.yml)
- [models/schema.yml](models/schema.yml)
