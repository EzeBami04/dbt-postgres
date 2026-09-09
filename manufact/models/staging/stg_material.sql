{{config(materialized='view')}}
with materials as (
    select *
    from {{ source('staging', 'material_usage') }}
)

select *
from materials