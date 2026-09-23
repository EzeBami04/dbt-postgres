{{config(materialized='view')}}
with quality_checks as (
    select *
    from {{ source('staging', 'quality_checks') }}
)

select *
from quality_checks