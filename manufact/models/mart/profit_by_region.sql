{{ config(materialized='view') }}

with sales as (
    select
        c.country ,
        i.product_id,
        sum(i.quantity) as units_sold,
        sum(i.quantity * i.unit_price - i.discount) as revenue
    from {{ ref('fact_orders') }} o
    inner join {{ ref('fact_order_items') }} i
        on o.order_id = i.order_id
    inner join {{ ref('dim_customers') }} c
        on o.customer_id = c.customer_id
    group by c.country, i.product_id
),

unit_cost as (
    select
        product_id,
        avg(unit_price) as cost_per_unit  
    from {{ ref('fact_production') }}
    group by product_id
)

select
    s.country as region,
    sum(s.revenue) as total_revenue,
    sum(s.units_sold * u.cost_per_unit) as total_cost,
    sum(s.revenue) - sum(s.units_sold * u.cost_per_unit) as profit,
    round(
        (sum(s.revenue) - sum(s.units_sold * u.cost_per_unit))
        / nullif(sum(s.revenue), 0),
        2
    ) as profit_margin
from sales s
inner join unit_cost u
    on s.product_id = u.product_id
group by s.country