{{config(materialized='incremental', unique_key='order_item_id', incremental_strategy='merge',
    cluster_by='order_item_id', partition_by={'field': 'last_updated', 'data_type': 'date'})}}
With order_items as(
    select *
    from {{ ref('stg_order_item') }}
)
select *
from order_items

{% if is_incremental() %}
    where last_updated >= (select max(last_updated) -  from {{ this }})
{% endif %}