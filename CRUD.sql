use snet1509;


INSERT INTO users (name,surname,email,phone,gender,birthday,hometown,photo_id,pass,created_at) VALUES 
('Сергей','Сергеев','qwe@asdf.qw',123123123,2,'1983-03-21','Саратов',NULL,'fdkjgsdflskdjfgsdfg142356214','2020-09-25 22:09:27.0');

INSERT INTO users (name,surname,email,phone,gender,birthday,hometown,photo_id,pass) values
('Ирина','Кийко','cattack2@unc.edu',2139527247,'f','1986-05-22','Саратов',NULL,'5f91ea663688cc873be65a6cc107f07da84664ae');

INSERT INTO users values
(3,'Виктория','Водопьянова','scasotti3@usgs.gov',4187011526,'f','1984-04-06','Челябинск',NULL,'f93c320ee2275544eb1b42d8278133c343fa5030','2020-09-25 22:09:27.0');

INSERT INTO users (id,name,surname,email,phone,gender,birthday,hometown,photo_id,pass,created_at) VALUES 
(6,'Дмитрий','Тимашов','segginton4@cam.ac.uk',4513359033,'m','1984-06-19','Казань',NULL,'e6ab5f555555fb26c7c60ddd23c8118307804330','2020-09-25 22:09:27.0')
,(7,'Владислав','Авраменко','aswaddle5@altervista.org',1874462339,'m','1987-07-07','Москва',NULL,'b25e49362b83833eece7d225717f2e285213bf25','2020-09-25 22:09:27.0')
,(8,'Алексей','Величко','fleahey6@ftc.gov',2951798252,'m','1984-11-27','Казань',NULL,'07521436ef4b4ad464ed04cdceb99f422bbbd9c5','2020-09-25 22:09:27.0')
,(9,'Артем','Филипцов','rcasley7@exblog.jp',3237322265,'m','1984-08-04','Краснодар',NULL,'5aac7b105729d4ad431db6a4e73604ecec132fa8','2020-09-25 22:09:27.0')
,(10,'Елена','Колдаева','rlantry8@pen.io',3731144657,'f','1989-08-07','Тюмень',NULL,'ba6c51c3064c20f9de84d4ed69733d9dd408e504','2020-09-25 22:09:27.0')
,(11,'Андрей','Антипов','egoatcher9@behance.net',8774858608,'m','1984-09-04','Красноярск',NULL,'16f4e6ac1aedd2d9707b56d767f452f3246e67f7','2020-09-25 22:09:27.0');

INSERT INTO users 
set
name='Евгений',surname='Грачев',email='dcolquita@ucla.edu',phone='9744906651',gender='m',birthday='1987-11-26',hometown='Омск',pass='1487c1cf7c24df739fc97460a2c791a2432df062';
	
insert communities (name)
select distinct district from world.city limit 20; -- вставим данные из тестовой базы MySQL world

select * from communities;
select * from communities order by id;
select surname, name, phone from users;
select * from users limit 10;
select * from users limit 10 offset 10;
select * from users limit 3 offset 8;
select concat(surname,' ',name) persons from users;
select concat(SUBSTRING(name,1,1), '. ',surname) persons from users;
select distinct hometown from users;

select * from users where hometown = 'Челябинск';

select name,surname, birthday 
	from users where birthday >= '1985-01-01' 
	order by birthday;

select name,surname, birthday 
	from users where birthday >= '1985-01-01' and birthday <= '1990-01-01';

select name,surname, birthday 
	from users where birthday between '1985-01-01' and '1990-01-01';

select name,surname,hometown from users where hometown != 'Москва';
select name,surname,hometown from users where hometown <> 'Москва';

select name,surname,hometown from users where hometown in ('Москва', 'Санкт-Петербург', 'Нижний Новгород');

select name,surname,hometown from users 
	where hometown = 'Москва'
	or hometown ='Санкт-Петербург'
 	or hometown ='Нижний Новгород';

select name,surname,hometown, gender from users 
	where (hometown = 'Москва' or hometown ='Санкт-Петербург') and gender='m';

select name,surname from users where surname like 'Ки%';
select name,surname from users where surname like '%ко';
select name,surname from users where surname like 'Ки_ко';

select count(*) from users;
select min(birthday) from users;

select hometown, count(*) from users group by hometown;

select hometown, count(*) from users group by hometown having count(*) >=10;

update friend_requests 
	set status = 'approved'
	where initiator_user_id = 1 and target_user_id = 2;
	 
delete from communities where name = 'Биология клетки';
delete from communities where id between 1 and 10;
delete from communities;

