{{config(materialized='view')}}
with maintenance as (
    select *
    from {{ source('staging', 'maintenance') }}
)

select *
from maintenance