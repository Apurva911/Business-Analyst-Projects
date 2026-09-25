create database logistic_warehouse;

SELECT TOP (1000) [item_id]
      ,[category]
      ,[stock_level]
      ,[reorder_point]
      ,[reorder_frequency_days]
      ,[lead_time_days]
      ,[daily_demand]
      ,[demand_std_dev]
      ,[item_popularity_score]
      ,[storage_location_id]
      ,[zone]
      ,[picking_time_seconds]
      ,[handling_cost_per_unit]
      ,[unit_price]
      ,[holding_cost_per_unit_day]
      ,[stockout_count_last_month]
      ,[order_fulfillment_rate]
      ,[total_orders_last_month]
      ,[turnover_ratio]
      ,[layout_efficiency_score]
      ,[last_restock_date]
      ,[forecasted_demand_next_7d]
      ,[KPI_score]
  FROM [logistic_warehouse].[dbo].[logistics_dataset]

--1.Which items are running dangerously low right now and need to be ordered from suppliers today?
  select 
    [item_id],
    category,
    [stock_level],
    [reorder_point],
    [turnover_ratio],
    (reorder_point-stock_level) as shortage_unit,
     [daily_demand],
     lead_time_days,
     round(stock_level/daily_demand,1) as days_unlit_stockempty
  from [logistic_warehouse].[dbo].[logistics_dataset]
  where stock_level<reorder_point
  order by shortage_unit desc;
 

 --2.Where does our system say we have stock, but we are still failing to ship orders to customers? 
 --(Looking for broken or misplaced items).
 
 select
    item_id,
    category,
    stock_level,
    order_fulfillment_rate,
    zone,
    storage_location_id,
    reorder_point,
    round(order_fulfillment_rate *100,1) as fullfillment_rate_pct,
    total_orders_last_month,
    round(total_orders_last_month * (1 - order_fulfillment_rate),0) as estimated_unfullfilled_orders
 from [logistic_warehouse].[dbo].[logistics_dataset]
 where stock_level>=250 and
 order_fulfillment_rate<=072
 order by order_fulfillment_rate asc 
  ,estimated_unfullfilled_orders desc;



  --3.What are our most expensive, top-selling products that we must protect and count every week?

 with item_consuption as(
    select 
    item_id,
    category,
    unit_price,
    daily_demand,
    stock_level,
    (daily_demand * 30 * unit_price) as monthly_value,
    (stock_level * unit_price) as holding_value
 from [logistic_warehouse].[dbo].[logistics_dataset]
 ),
 cumulative_calc as(
    select 
        item_id,
        category,
        unit_price,
        daily_demand,
        monthly_value,
        holding_value,
        sum(monthly_value)over () as total_value,
        sum(monthly_value) over( 
            order by monthly_value desc 
            rows between UNBOUNDED PRECEDING  and current row
        ) as running_value
      from item_consuption

    )
    select
        item_id,
        category,
        unit_price,
        monthly_value,
        round(running_value/ total_value *100,2) as cumulative_pecntage,
        case
            when (running_value/ total_value )<=80.0 then 'class A'
            when(running_value/ total_value)<=95.0 then 'class B'
            else 'class c'

        end as abd_class
    from cumulative_calc
    order by monthly_value desc;



--4.How much working capital is tied up in slow-moving or dead stock, and what are the liquidation priorities?

select 
    item_id,
    category,
    stock_level,
    unit_price,
    daily_demand,
    turnover_ratio,
    round( stock_level*unit_price,2) as capital_tied_up,
    round(stock_level/daily_demand,1) as daily_inventory_on_hand,
    case 
        when turnover_ratio<2.0 then 'Dead stock risk'
        when turnover_ratio<5.0 then 'slow mover'
        when turnover_ratio<10.0 then 'Moderate Mover'
        else 'fast mover'
    end as velocity_tier
from [logistic_warehouse].[dbo].[logistics_dataset]
where turnover_ratio<2.0
order by capital_tied_up desc;



--5.Which fast-moving items are stored in bad warehouse locations that cause long walking/picking times, and how can reslotting fix it?

select 
    item_id,
    category,
    zone,
    storage_location_id,
    daily_demand,
    turnover_ratio,
    picking_time_seconds,
    layout_efficiency_score,
    case 
        when turnover_ratio>=10.0 and picking_time_seconds>150 then 'Relocate to front pick zone'
        when turnover_ratio>=10.0 and picking_time_seconds>100 then 'review slotting'
        else 'stable'
    end as sloting_action
from [logistic_warehouse].[dbo].[logistics_dataset]
where turnover_ratio>=10.0 and picking_time_seconds>150
order by picking_time_seconds desc , turnover_ratio desc;