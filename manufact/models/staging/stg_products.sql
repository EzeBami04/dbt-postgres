{{config(materialized='view')}}
with products as (
    select 
        cast(created_at as date) as created_at,
       cast(product_id as varchar(10)) as product_id,
       cast(product_name as varchar(100)) as product_name,
       cast(category as varchar(100)) as category,
       cast(unit_price as numeric(10,2)) as unit_price,
       cast(unit_cost as numeric(10,2)) as unit_cost,
       cast(reorder_level as int) as reorder_level
    from {{ source('staging', 'products') }}
)

select *
from products