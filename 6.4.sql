/* Активность померим баллами, у каждого действия свой вес:
 * 1 - для лайка
 * 1 - для запроса в друзья
 * 1 - для вступление в группу
 * 2 - для сообщения
 * 2 - для комментария
 * 2 - для репоста
 * 4 - если админ группы
 * 4 - для фото
 * 8 - для поста
 */
select user_id, sum(activity) as activity from (
	select user_id, count(*) as activity from likes_posts group by user_id
	union
	select initiator_user_id as user_id, count(*) as activity from friend_requests group by user_id
	union 
	select user_id, sum(usr_status) as activity from (select user_id, if(is_admin = 1, 4, 1) as usr_status from users_communities) as usr_grps group by user_id
	union
	select user_id, 2*count(*) as activity from comments group by user_id
	union
	select from_user_id as user_id, 2*count(*) as activity from messages group by user_id
	union
	select from_user_id as user_id, 2*count(*) as activity from reposts group by user_id
	union
	select user_id, 4*count(*) as activity from photos group by user_id
	union
	select user_id, 8*count(*) as activity from posts group by user_id) as act_usrs
group by
	user_id
order by
	activity
limit 10;
