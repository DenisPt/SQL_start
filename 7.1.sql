-- вариант 1
select id, name from users where exists(select 1 from orders where user_id = users.id);

-- вариант 2
select distinct u.id as id, u.name as name from orders o join users u on o.user_id = u.id;

-- вариант 3
select id, name from users where (select count(*) from orders where user_id = users.id) > 0;
