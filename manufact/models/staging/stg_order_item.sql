{{config(materialized='view')}}
with items as (
    select *
    from {{ source('staging', 'order_items') }}
)

select *
from items