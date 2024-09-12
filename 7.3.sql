------------------------------------- вариант 1
select
	id,
	(select
		name
	from
		cities
	where
		flights.`from` = label) as `from`,
	(select
		name
	from
		cities
	where
		flights.`to` = label) as `to` 
from
	flights;
  
  
  ------------------------------------- вариант 2
select
	f.id as id,
	c.name as `from`,
	c2.name as `to`
from
	flights f
join cities c on
	f.`from` = c.label
join cities c2 on
	f.`to` = c2.label

  ------------------------------------- вариант 3
select
	f.id as id,
	c1.name as `from`,
	c2.name as `to`
from
	flights f
join
	(cities c1 join cities c2 on c1.label <> c2.label)
on
	(f.`from`, f.`to`) = (c1.label,	c2.label)
