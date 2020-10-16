---------------------------------------1---------------------------------
start transaction;
delete from sample.users where id = 1;	
insert into sample.users select * from shop.users where id = 1;
delete from shop.users where id = 1;	-- строку добавляем если под переносом понимаем добавление в БД sample, и при этом удаление из исходной БД shop
commit;


---------------------------------------2---------------------------------
use shop;
create or replace view v1 as
select
	p.name as 'Товар',
	c.name as 'Категория'
from
	products p
join catalogs c on
	p.catalog_id = c.id;
  
---------------------------------------3---------------------------------
-- решение явно не оптимальное, но придумал только такое)
set @date_start := '2020-08-01'; -- если вдруг захотим поменять даты начала и конца вывода
set @date_end := '2020-08-31';

 -- создаем временную таблицу из 40 значений от 0 до 39, если хотим расширить максимальное количество дней, нужно увеличивать таблицу t2
 -- или создавать таблицы t3, t4 и т.д. для увелечения количества дней до 100, 1000 и т.д.
drop table if exists t1;
create temporary table t1 as select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9;
drop table if exists t2;
create temporary table t2 as select 0 i union select 1 union select 2 union select 3;
drop table if exists t3;  
create temporary table t3 as select t1.i + t2.i*10 as i from t1, t2;
-- окончание создания временной таблицы

-- создаем временную таблицу, вычисляющую разницу между датой старта и датой, записанной в поле created_at в исходной таблице tbl1
drop table if exists t4;
create temporary table t4 as select DATEDIFF(created_at, @date_start) as i from tbl1;
-- окончание создание временной таблицы

select
	date_add(@date_start,
	interval t3.i day) as d,
	case
		when t3.i = t4.i then 1
		else 0
	end as date_in
from
	t3
	left join t4
	on t3.i = t4.i
where
	t3.i <= DATEDIFF(@date_end, @date_start)
order by
	t3.i;
  
---------------------------------------4---------------------------------
delete
from
	tbl1
where
	created_at not in (
	select
		*
	from
		(select
			*
		from
			tbl1
		order by
			created_at desc
		limit 5) as tmp);
