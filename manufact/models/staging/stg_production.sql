{{config(materialized='view')}}
with production as (
    select cast(production_id as varchar(50)) as production_id,
        cast(production_date as Date) as production_date,
        cast(product_id as varchar(10)) as product_id, 
        cast(batch_id as varchar(5)) as batch_id, 
        cast(machine_id as varchar(45)) as machine_id,
        cast(operator_id as VARCHAR(9)) as operator_id,
        cast(planned_quantity as int) planned_qty,
        cast(produced_quantity as int) as qty_produced, 
        cast(good_quantity as bigint) as good_qty,
        cast(defective_quantity as int) as defective_qty,
        round(cast(downtime_minutes as decimal(2)), 2) as downtime_min,
        round(cast(production_time_minutes as decimal(2)), 2) as production_time_min,
        round(cast(material_cost as decimal(2)), 2) as material_cost, 
       round(cast(labor_cost as decimal(2)), 2) as labor_cost,
        round(cast(energy_cost as decimal(2)), 2) as energy_cost
    from {{ source('staging', 'production') }}
    WHERE production_date BETWEEN '2025-01-01' AND '2026-08-31'
    )
select *
from production