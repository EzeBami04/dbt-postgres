{{config(materialized='view')}}
with inventory as (
    select *
    from {{ source('staging', 'inventory') }}
)

select *
from inventory;