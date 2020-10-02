select 
	round(avg(TIMESTAMPDIFF(year, birthday, now())), 1) 
from
	users;
