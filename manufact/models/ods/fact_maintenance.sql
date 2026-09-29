{{config(materialized='incremental', unique_key='maintenance_id', incremental_strategy='merge',
    cluster_by='maintenance_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With inventory as(
    select *
    from {{ ref('stg_maintenance') }}
)
select *
from inventory

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}