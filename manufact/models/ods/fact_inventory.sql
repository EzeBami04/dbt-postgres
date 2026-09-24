{{config(materialized='incremental', unique_key='movement_id', incremental_strategy='merge',
    cluster_by='movement_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With inventory as(
    select *
    from {{ ref('stg_inventory') }}
)
select *
from inventory

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}