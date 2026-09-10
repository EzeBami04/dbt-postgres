{{config(materialized='view')}}
with maintenance as (
    select 
        cast(maintenance_id as varchar(12)) as maintenance_id,
        cast(machine_id as varchar(5)) as machine_id,
        cast(maintenance_date as date) as maintenance_date,
        cast(maintenance_type as VARCHAR(15)) as maintenance_type,
        cast(technician_id as varchar(9)) as employee_id,
        cast(downtime_minutes as int) as downtime_minutes,
        cast(maintenance_cost as numeric(10, 2)) as maintenance_cost
    from {{ source('staging', 'maintenance') }}
)

select *
from maintenance