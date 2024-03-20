/*Данный скрипт подсчитывает количество уникальных
покупателей из таблицы customers.*/

select count(customer_id) as customers_count
from
    customers;


/*Данный скрипт дает топ-10 продавцов, у которых наибольшая выручка*/

select
    e.first_name || ' ' || e.last_name as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name || ' ' || e.last_name
order by
    income desc
limit 10;

/*Данный скрипт дает информацию о продавцах, чья средняя выручка
за сделку меньше средней выручки за сделку по всем продавцам.*/

select
    e.first_name || ' ' || e.last_name as seller,
    floor(avg(s.quantity * p.price)) as average_income
from
    sales as s
inner join products as p
    on s.product_id = p.product_id
inner join employees as e
    on s.sales_person_id = e.employee_id
group by
    e.first_name || ' ' || e.last_name
having
    avg(s.quantity * p.price) < (
        select avg(s.quantity * p.price) as avg_income_of_all
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by
    average_income;

/*Данный скрипт дает информацию о выручке по продавцам и по дням недели*/

select
    seller,
    day_of_week,
    floor(income) as income
from
    (
        select
            e.first_name || ' ' || e.last_name as seller,
            extract(isodow from s.sale_date) as num_day_of_week,
            to_char(s.sale_date, 'day') as day_of_week,
            sum(s.quantity * p.price) as income
        from
            sales as s
        inner join employees as e
            on s.sales_person_id = e.employee_id
        inner join products as p
            on s.product_id = p.product_id
        group by
            to_char(s.sale_date, 'day'),
            extract(isodow from s.sale_date),
            e.first_name || ' ' || e.last_name
        order by
            num_day_of_week,
            seller
    ) as t1;

/*Данный скрипт вычисляет кол-во покупателей по категшориям возраста*/

select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(distinct customer_id) as age_count
from
    customers
group by
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end;

/*Данный скрипт дает данные по количеству уникальных покупателей и выручке, 
которую они принесли*/

select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
group by
    to_char(s.sale_date, 'YYYY-MM')
order by
    selling_month;


/*Данный скрипт дает инфо о покупателях, первая покупка которых была
в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)*/

select
    customer,
    sale_date,
    seller
from
    (
        select
            s.sales_id,
            s.sale_date,
            p.price,
            s.customer_id,
            s.product_id,
            c.first_name || ' ' || c.last_name as customer,
            e.first_name || ' ' || e.last_name as seller,
            rank() over (partition by s.customer_id order by s.sale_date) as rnk
        from
            sales as s
        left join customers as c
            on s.customer_id = c.customer_id
        left join employees as e
            on s.sales_person_id = e.employee_id
        left join products as p
            on s.product_id = p.product_id
        order by
            s.customer_id, customer, s.sale_date
    ) as t1
where
    rnk = 1 and price = 0
group by
    customer,
    sale_date,
    seller;





