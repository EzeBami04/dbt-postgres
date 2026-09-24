{{config(materialized='incremental', unique_key='customer_id', incremental_strategy='merge',
    cluster_by='customer_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With customers as(
    select *
    from {{ ref('stg_customers') }}
)
select *
from customers

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}