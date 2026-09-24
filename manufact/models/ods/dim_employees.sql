{{config(materialized='incremental', unique_key='employee_id', incremental_strategy='merge',
    cluster_by='employee_id', partition_by={'field': 'created_at', 'data_type': 'date'})}}
With employees as(
    select *
    from {{ ref('stg_employee') }}
)
select *
from employees

{% if is_incremental() %}
    where created_at >= (select max(created_at) - interval '1 day' from {{ this }})
{% endif %}