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
-- пока не придумал решение
  
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
