/*Данный скрипт подсчитывает количество уникальных покупателей из таблицы customers.*/

select 
	count(customer_id) customers_count 
from 
	customers;



