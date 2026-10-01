---- Revenue, Totalcost, profit and profit margin by product
{{config(materialized='view')}}
with revenue as(
    select a.order_id as order_id, a.customer_id as customer_id,
        b.product_id as product_id, b.quantity as quantity, b.unit_price as unit_price,
        b.discount as discount,  sum((b.quantity * b.unit_price) - b.discount) as total_revenue
    from {{ref('fact_orders')}} a
    left join {{ref("fact_order_items")}} b
    on a.order_id = b.order_id
    group by order_id, sum((b.quantity * b.unit_price) - b.discount)
),
total_cost as(
    SELECT product_id, product_name, qty_produced,  SUM(material_cost, labor_cost, energy_cost) as total_cost
    FROM {{ref("fact_production")}}
    GROUP BY product_id, qty_produced, SUM(material_cost, labor_cost, energy_cost)
),
profit_margin as(
    SELECT d.product_id, d.product_name, c.total_revenue, d.total_cost, 
        round(((c.total_revenue - d.total_cost)/c.total_revenue), 2) as profit_margin
    FROM revenune c
    inner join total_cost d
    on c.product_id = d.product_id
    )
select product_name, total_revenue, total_cost, 
    sum(profit_margin) OVER(PARTITION BY product_name order by )