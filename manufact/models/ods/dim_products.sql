{{config(materialized='incremental', unique_key='product_id', incremental_strategy='merge',
    cluster_by='product_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With products as(
    select *
    from {{ ref('stg_products') }}
)
select *
from products

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}