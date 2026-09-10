{{config(materialized='view')}}
with employees as (
    select 
        cast(hire_date as date) as hire_date,
        cast(employee_id as varchar(9)) as employee_id,
        cast(employee_name as varchar(100)) as employee_name,
        cast(department as varchar(50)) as department,
        cast(role as varchar(50)) as emp_role
    from {{ source('staging', 'employees') }}
)

select *
from employees