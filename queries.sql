/*Данный скрипт подсчитывает количество уникальных покупателей из таблицы customers.*/

select 
	count(customer_id) as customers_count 
from 
	customers;


/*Данный скрипт дает топ-10 продавцов, у которых наибольшая выручка*/

select 
	e.first_name || ' ' || e.last_name as name,
	count(s.sales_id) as operations,
	floor(sum(s.quantity * p.price)) as income
from
	sales s 
join employees e 
	on s.sales_person_id = e.employee_id 
join products p
	on p.product_id = s.product_id 
group by 
	e.first_name || ' ' || e.last_name
order by 
	income desc
limit 10;


/*Данный скрипт дает информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.*/

select 
	e.first_name || ' ' || e.last_name as name,
	floor(avg(s.quantity * p.price)) as average_income
from
	sales s 
join products p 
	on p.product_id = s.product_id 
join employees e 
	on e.employee_id = s.sales_person_id 
group by 
	e.first_name || ' ' || e.last_name
having 
	avg(s.quantity * p.price) < (
		select 
			avg(s.quantity * p.price) as avg_income_of_all
		from sales s 
		join products p 
			on p.product_id = s.product_id
		)
order by 
	average_income;
	

/*Данный скрипт дает информацию о выручке по продавцам и по дням недели*/

select 
	name,
	day_of_week,
	floor(income) as income
from

	(select 
		e.first_name || ' ' || e.last_name as name,
		extract(isodow from s.sale_date) as num_day_of_week,
		to_char(s.sale_date, 'day') as day_of_week,
		sum(s.quantity * p.price) as income
	from
		sales s 
	join employees e 
		on s.sales_person_id = e.employee_id 
	join products p
		on p.product_id = s.product_id
	group by 
		to_char(s.sale_date, 'day'),
		extract(isodow from s.sale_date),
		e.first_name || ' ' || e.last_name
	order by 
		num_day_of_week,
		name) as t1
;


/*Данный скрипт вычисляет кол-во покупателей по категшориям возраста*/

select
	case 
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		else '40+'
	end age_category,
	customer_id, 
	age
from
	customers;


/*Данный скрипт дает данные по количеству уникальных покупателей и выручке, которую они принесли*/

select 
	to_char(s.sale_date, 'YYYY-MM') as date,
	count(distinct s.customer_id) total_customers,
	floor(sum(s.quantity * p.price)) income
from sales s
left join products p 
	on p.product_id = s.product_id 
group by 
	to_char(s.sale_date, 'YYYY-MM')
order by 
	date;


/*Данный скрипт дает инфо о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)*/

select
	customer,
	sale_date,
	seller
from
	(select
	    s.sales_id ,
	    c.first_name || ' ' || c.last_name customer,
	    s.sale_date sale_date,
	    e.first_name || ' ' || e.last_name seller,
	    p.price,
	    s.customer_id,
	    s.product_id,
	    rank() over(partition by s.customer_id order by s.sale_date) rnk
	from
	    sales s 
	left join customers c 
	    on c.customer_id = s.customer_id 
	left join employees e 
	    on e.employee_id = s.sales_person_id
	left join products p 
	    on p.product_id = s.product_id 
	order by 
	    customer_id, customer, sale_date) as t1
where
	rnk = 1 and price = 0
group by 
	customer,
	sale_date,
	seller
;











