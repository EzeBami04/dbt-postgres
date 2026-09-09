{{config(materialized='view')}}
with employees as (
    select *
    from {{ source('staging', 'employees') }}
)

select *
from employees