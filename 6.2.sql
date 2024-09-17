select
	count(*) as likes
from
	likes_posts
where
	post_id in (
	select
		id
	from
		posts as young_posts
	where
		user_id in (
		select
			*
		from
			(
			select
				id
			from
				users as young
			order by
				timestampdiff(day,
				birthday,
				now())
			limit 10) as young2));
