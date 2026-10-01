{{ config(materialized='view') }}

with order_details as (
    select
        i.product_id,
        sum(i.quantity * i.unit_price - i.discount) as revenue
    from {{ ref('fact_orders') }} o
    inner join {{ ref('fact_order_items') }} i
        on o.order_id = i.order_id
    group by i.product_id
)

select
    p.product_id,
    p.product_name,
    coalesce(d.revenue, 0) as revenue_by_product
from {{ ref('dim_products') }} p
left join order_details d
    on p.product_id = d.product_id