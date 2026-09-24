{{config(materialized='incremental', unique_key='order_id', incremental_strategy='merge',
    cluster_by='order_id', partition_by={'field': 'order_date', 'data_type': 'date'})}}
With orders as(
    select *
    from {{ ref('stg_orders') }}
)
select *
from orders

{% if is_incremental() %}
    where order_date >= (select max(order_date) - interval '1 day' from {{ this }})
{% endif %}