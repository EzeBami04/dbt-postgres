{{ config(materialized='view') }}

with revenue as (
    select
        i.product_id,
        sum(i.quantity * i.unit_price - i.discount) as total_revenue
    from {{ ref('fact_orders') }} o
    inner join {{ ref('fact_order_items') }} i
        on o.order_id = i.order_id
    group by i.product_id
),

total_cost as (
    select
        product_id,
        product_name,
        sum(
            coalesce(material_cost, 0)
            + coalesce(labor_cost, 0)
            + coalesce(energy_cost, 0)
        ) as total_cost
    from {{ ref('fact_production') }}
    group by product_id, product_name
)

select
    c.product_name,
    r.total_revenue,
    c.total_cost,
    r.total_revenue - c.total_cost as profit,
    round(
        (r.total_revenue - c.total_cost) / nullif(r.total_revenue, 0),
        2
    ) as profit_margin
from revenue r
inner join total_cost c
    on r.product_id = c.product_id