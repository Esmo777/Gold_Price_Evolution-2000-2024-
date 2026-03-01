-- 1 How has the average annual gold price evolved between 2000 and 2026?
select
   year,
   avg(gold_price_usd) as avg_gold_price
from gold_price_2000_2026
group by year
order by year; 

-- 2 What is the compound annual growth rate(CAGR) of gold prices over the entire period?
with limits as (
    select
        min(year) as start_year,
        max(year) as end_year
     from gold_price_2000_2026
),
prices as (
      select     
        first_value(gold_price_usd) over
(order by date) as start_price,
        first_value(gold_price_usd) over
(order by date desc) as end_price
    from gold_price_2000_2026
    )
select
	power(
		end_price/start_price, 
        1.0 / (end_year - start_year)
	) - 1 as cagr
from prices
cross join limits
limit 1;   

-- 3 Which years experienced the strongest average price increases?
with yearly_avg as (
    select
	    year,
        avg(gold_price_usd) as avg_price
    from gold_price_2000_2026
    group by year
)
select
    year,
    (avg_price - lag(avg_price) over (order by
year))
        / lag(avg_price) over (order by year)
as yoy_growth
from yearly_avg
order by yoy_growth desc;        
    
-- 4 Which years recorded the sharpest average price declines? 
with yearly_avg as (
    select
	    year,
        avg(gold_price_usd) as avg_price
    from gold_price_2000_2026
    group by year
)
select
    year,
    (avg_price - lag(avg_price) over (order by
year))
        / lag(avg_price) over (order by year)
as yoy_growth
from yearly_avg
order by yoy_growth asc;  

-- 5 How does the average gold price differ across decades?
select
    decade,
    avg(gold_price_usd) as avg_gold_price
from gold_price_2000_2026
group by decade
order by decade;    

-- 6 What is the average annual volatility of gold prices?
select 
    year,
    stddev(gold_price_usd) as
annual_volatility
from gold_price_2000_2026
group by year
order by year;    

-- 7 Is there evidence of structural price acceleration across decades?
select
    decade,
    max(gold_price_usd) - min(gold_price_usd)
as price_range
from gold_price_2000_2026
group by decade
order by decade;  

-- 8 Which economic periods show the highest average gold prices?
select
    period_type,
    avg(gold_price_usd) as avg_gold_price
from gold_price_2000_2026
group by period_type
order by avg_gold_price desc;  

-- 9 Does gold exhibit a generally increasing long-term price trend?
with trend_check as (
    select
        gold_price_usd,
        lag(gold_price_usd) over (order by
date) as prev_price
    from gold_price_2000_2026
)    
select
    case
        when count(*) = sum(
            case
                when prev_price is null
                     or gold_price_usd >=
prev_price				
                then 1 else 0
			end    
        )
        then 'yes'
        else 'no'
    end as monotonic_trend
from trend_check;    

-- 10 What is the maximum observed price amplitude between the lowest and highest points over the full period?
select
    max(gold_price_usd) - min(gold_price_usd)
as max_price_amplitude
from gold_price_2000_2026;    