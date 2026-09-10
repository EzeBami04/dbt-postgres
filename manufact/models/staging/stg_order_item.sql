{{config(materialized='view')}}
with items as (
    select 
        cast(order_item_id as varchar(12)) as order_item_id,
        cast(order_id as varchar(12)) as order_id,
        cast(product_id as varchar(10)) as product_id,
        cast(quantity as int) as quantity,
        cast(unit_price as numeric(10,2)) as unit_price,
        cast(discount as numeric(10,2)) as discount,
        cast(line_amount as numeric(10,2)) as line_amount
    from {{ source('staging', 'order_items') }}
)

select *
from items