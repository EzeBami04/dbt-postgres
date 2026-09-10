{{config(materialized='view')}}
with inventory as (
    select 
        cast(movement_id as varchar(12)) as movement_id,
        cast(movement_date as date) as movement_date,
        cast(material_id as char(8)) as material_id,
        cast(warehouse as char(6)) as warehouse,
        cast(movement_type as varchar(50)) as movement_type,
        cast(quantity as bigint) as quantity
    from {{ source('staging', 'inventory') }}
)

select *
from inventory;