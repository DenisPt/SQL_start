/* Создайте SQL-запрос, который помещает в таблицу users миллион записей. */

delimiter //

drop procedure if exists create_users//
create procedure create_users (in num int)
begin
	declare i int default 0;
	while i < num do
		insert into users (name, birthday_at) values (concat('user', 1), date(from_unixtime(rand() * unix_timestamp(current_date)))); -- дата рождения рэндомная от 1970 до текущей даты
		set i = i + 1;
	end while;
end//
delimiter ;

call create_users(1000000);
