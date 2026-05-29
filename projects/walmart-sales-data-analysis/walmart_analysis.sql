select * from walmart

drop table walmart

--
select count(*) from walmart

select 
	payment_method,
	count(*)
from walmart
group by payment_method

select count(distinct Branch)
from walmart

select max(quantity) from walmart;
select min(quantity) from walmart;

--1.find diff payment method and number of transactiopns,number of qty sold

select 
	payment_method,
	count(*) as no_of_payments,
	sum(quantity) as quantity_sold
from walmart
group by payment_method

--identify the highest rated category in each branch,displaying the branch,category and average rating


select *
from
(
select
	branch,
	category,
	avg(rating) as average_rating,
	rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by 1,2 
)
where rank=1

--3.identify the busiest day for each branch based on the number of transactions
select * from
(
select 
	branch,
	to_char(to_date(date,'dd/mm/yy'),'day') as day_name,
	count(*) as no_of_transactions,
	rank() over(partition by branch order by count(*) desc) as rank
From walmart
group by 1,2
)
where rank=1

--4.calculate the total quantity of items sold per payment method.list payment_method and total_quantity

select 
	payment_method,
	--count(*) as no_of_payments,
	sum(quantity) as quantity_sold
from walmart
group by payment_method

--5.determine the average,minimum and maximum rating of products for each city,list the city,average_rating,min_rating and max_rating

select 
	city,
	category,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from walmart
group by 1,2


--6.calculate the total profit for each category by considering total_profit as 
--(unit_price*quantity*profir_margin).list category and total,ordered from highest to lowest profit

select 
	category,
	sum(total_price) as total_revenue,
	sum(total_price * profit_margin) as profit
from walmart
group by 1

--7.determine the most common payment method for each branch,displaybranch and the preferred_payment_method


with cte
as
(select
	branch,
	payment_method,
	count(*) as total_transactions,
	rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
select * from cte where rank=1

--8categorize sales into 3 group morning,afternoon,evening
--find out each of the shift and number of invoices

select
	branch,
	case 
		when extract (hour from(time::time)) < 12 then 'Morning'
		when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end day_time,
	count(*)
from walmart
group by 1,2
order by 1,3 desc

--9identify 5 branches with highest decrease ratio in
--revenue compare to last year(current year 2023 and last year 2022)

--rdr == last_rev-cy_rev/ls_rev*100

select 
	*,
	extract(year from to_date(date,'dd/mm/yy')),'day' as formatted_date
from walmart


--2022 sales
with revenue_2022
as
(
	select
		branch,
		sum(total_price) as revenue
		
	from walmart
	where extract(year from to_date(date,'dd/mm/yy'))=2022
	group by 1
),

revenue_2023
as
(
	select
		branch,
		sum(total_price) as revenue
		
	from walmart
	where extract(year from to_date(date,'dd/mm/yy'))=2023
	group by 1
)
select 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	round(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric*100,
		2) as revenue_decreased_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue> cs.revenue
order by 4 desc
limit 5