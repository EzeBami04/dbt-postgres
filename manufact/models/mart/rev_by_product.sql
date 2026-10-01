--- Revenue by product 
{{config(materialized='view')}}
with product as(
    select product_id, product_name
    from {{ref('dim_products')}}
),
order_details as(
    select a.order_id as order_id, b.product_id as product_id, b.quantity as quantity, b.unit_price as unit_prics,
         b.discount as discount,  sum((b.quantity * b.unit_price) - b.discount) as revenue
    from {{ref('fact_orders')}} a
    left join {{ref("fact_order_items")}} b
    on a.order_id = b.order_id
    group by order_id, sum((b.quantity * b.unit_price) - b.discount)
    order by 1
    )
SELECT c.product_id, c.product_name, 
    SUM(d.revenue) Over(PARTITION BY c.product_id order by product_name) as revenue_by_product
from product c
inner join order_details d
on c.product_id = d.product_id
Group by c.product_id, c.product_name