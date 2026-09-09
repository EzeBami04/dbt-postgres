{{config(materialized='view')}}
with orders as (
    select 
        cast(order_date as date) as order_date,
        cast(order_id as varchar(12)) as order_id,
        cast(customer_id as varchar(11)) as customer_id,
        cast(required_date as date) as required_date,
        cast(sales_channel as varchar(45)) as sales_channel,
        cast(order_status as varchar(25)) as order_status,
        cast(payment_status as varchar(10)) as payment_status
    from {{ source('staging', 'orders') }}
)

select *
from orders