/* Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы,
идентификатор первичного ключа и содержимое поля name. */


drop table if exists logs;
create table logs(
	created_at datetime default current_timestamp,
	table_name char(50) not null,
	id_rec bigint unsigned not null,
	name_content varchar(255)
) engine=Archive;

delimiter //

drop trigger if exists users_create_row//
create trigger users_create_row after insert on users
for each row 
begin 
	insert into logs(table_name, id_rec, name_content) values ('users', new.id, new.name);
end//

drop trigger if exists catalogs_create_row//
create trigger catalogs_create_row after insert on catalogs
for each row 
begin 
	insert into logs(table_name, id_rec, name_content) values ('catalogs', new.id, new.name);
end//

drop trigger if exists products_create_row//
create trigger products_create_row after insert on products
for each row 
begin 
	insert into logs(table_name, id_rec, name_content) values ('products', new.id, new.name);
end//

delimiter ;
