select
	dayofweek(concat(year(now()), '-', month(birthday), '-', day(birthday))) as id_day, 
	dayname(concat(year(now()), '-', month(birthday), '-', day(birthday))) as Day_of_Week, 
	count(*)
from
	users
group by
	day_of_week
order by
	id_day;
