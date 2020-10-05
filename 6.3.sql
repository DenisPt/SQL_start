select
	gender,
	sum(likes) as likes
from
	(
	select
		gender, (
		select
			count(*)
		from
			(
			select
				id
			from
				likes_posts as likes
			where
				user_id = u.id) as likes_qty) likes
	from
		users as u) as tbl
group by
	gender
order by
	likes desc
limit 1;
