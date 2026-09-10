{{config(materialized='view')}}
with materials as (
    select 
        cast(machine_id as varchar(10)) as material_id,
        cast(production_id as varchar(50)) as production_id,
        cast(usage_id as varchar(12)) as usage_id,
        cast(quantity_used as numeric(10,2)) as quantity_used,
        cast(unit_cost as numeric(10,2)) as unit_cost
        cast(usage_date as date) as usage_date
    from {{ source('staging', 'material_usage') }}
)

select *
from materials