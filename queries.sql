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
	

/*Данный скрипт дает информацию о выручке по дням недели*/

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
