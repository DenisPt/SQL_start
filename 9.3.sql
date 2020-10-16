--------------------------------1--------------------------------
delimiter //
drop function if exists hello//
create function hello()
returns varchar(255) deterministic
begin
	declare h_now int default hour(now());
	case
		when h_now >= 6 and h_now < 12 then return 'Доброе утро!';
		when h_now >= 12 and h_now < 18 then return 'Добрый день!';
		when h_now >= 18 then return 'Добрый вечер!';
		else return 'Доброй ночи!';
	end case;
end//

				       
--------------------------------2--------------------------------
drop trigger if exists chck_ins//
create trigger chck_ins before insert on products
for each row
begin
	if (new.name is null and new.description is null) then 
		signal sqlstate '45000' set MESSAGE_TEXT = 'Имя и описание не может быть пустым одновременно';
	end if;
end//
				       
drop trigger if exists chck_upd//
create trigger chck_upd before update on products
for each row
begin 
	if  (new.name is null and new.description is null) then 
		signal sqlstate '45000' set MESSAGE_TEXT = 'Имя и описание не может быть пустым одновременно';
	end if;
end//

--------------------------------3--------------------------------
drop function if exists fibonacci//
create function fibonacci(num int unsigned)
returns int deterministic
begin
	declare fib, fib_1, fib_2, i int default 0;
	while (i <= num) do
		set fib_2 = fib_1;
		set fib_1 = fib;
		set fib = fib_1 + fib_2;
		if i = 1 then set fib = 1;
		end if;
		set i = i  +  1;
	end while;
	return fib;
end//
