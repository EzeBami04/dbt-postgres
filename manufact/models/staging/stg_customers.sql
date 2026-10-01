{{config(materialized='ephemeral')}}
with customers as (
    select
        cast(created_at as date) as created_at,
        cast(customer_id as varchar(15)) as customer_id,
        cast(customer_name as varchar(100)) as customer_name,
        cast(customer_type as varchar(45)) as customer_type,
        cast(country as varchar(45)) as country,
        cast(city as varchar(100)) as city

    from {{ source('staging', 'customers') }}
)

select *
from customers