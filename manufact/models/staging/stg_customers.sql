{{config(materialized='view')}}
with customers as (
    select *
    from {{ source('staging', 'customers') }}
)

select *
from customers