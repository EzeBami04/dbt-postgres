{{ config(
    materialized='incremental',
    unique_key='production_id',
    incremental_strategy='merge',
    cluster_by='production_id',
    partition_by={'field': 'production_date', 'data_type': 'date'}
) }}

select *
from {{ ref('stg_production') }}

{% if is_incremental() %}
    where production_date >= (select max(production_date) - interval '1 day' from {{ this }})
{% endif %}