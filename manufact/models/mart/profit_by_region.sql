-- profit by region
{{config(materialized='view')}}
with revenue as(
    select a.order_id as order_id, a.customer_id as customer_id,
        b.product_id as product_id, b.quantity as quantity, b.unit_price as unit_price,
        b.discount as discount,  sum((b.quantity * b.unit_price) - b.discount) as revenue
    from {{ref('fact_orders')}} a
    left join {{ref("fact_order_items")}} b
    on a.order_id = b.order_id
    group by order_id, sum((b.quantity * b.unit_price) - b.discount)
    order by 1
),
order_region as(
    select d.product_id, c. 
    from {{ref("dim_customers")}} c
    left join revenue d
    on c.customer_id = d.customer_id
),
total_cost as(
    SELECT product_id, qty_produced,  SUM(material_cost, labor_cost, energy_cost) as total_cost
    FROM {{ref("fact_production")}}
    GROUP BY product_id, qty_produced, SUM(material_cost, labor_cost, energy_cost)
)