{{config(materialized='incremental', unique_id='production_id', 
        incremental_strategy='upsert', cluster_by = 'production_id', 
        partition_by={'field': 'production_date', 'data_type': 'date'})
        }}
select *
from {{ref("stg_production")}}

{%if is_incremental()%}
    where production_date >= (select max(production_date) from {{ this }})
{%endif%}