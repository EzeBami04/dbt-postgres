{{config(materialized='incremental', unique_key='usage_id', incremental_strategy='merge',
    cluster_by='usage_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With material_usage as(
    select *
    from {{ ref('stg_material') }}
)
select *
from material_usage

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}