select
	id,
	name,
	surname
from
	users
where
	id = (
	select
		from_user_id
	from
		(
		select
			from_user_id, count(*) as msg_qty
		from
			messages
		where
			from_user_id in (
			select
				target_user_id ff
			from
				friend_requests
			where
				initiator_user_id = 1
				and status = 'approved'
		union
			select
				initiator_user_id ff
			from
				friend_requests
			where
				target_user_id = 1
				and status = 'approved')
			and to_user_id = 1
		group by
			from_user_id
		order by
			msg_qty desc
		limit 1) as msg_tbl);
