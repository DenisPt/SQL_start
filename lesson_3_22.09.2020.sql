drop database if exists snet1509;
create database snet1509;
use snet1509;

-- создадим таблицу-справочник по гендерам
drop table if exists genders;
create table genders(
	id tinyint unsigned not null unique primary key,
	gender varchar(20)
);

drop table if exists users;
create table users(
	id serial primary key,
	name varchar(50) not null,
	surname varchar(50) not null,
	email varchar(120) unique,
	phone bigint unique, -- добавим уникальность телефона, т.к. логично восстанавливать акк или по почте или по телефону
	gender tinyint unsigned, -- для толерантной соцсети лучше иметь возможность указать несколько гендеров :D и отдельно хранить таблицу с расшифровкой типов
	birthday date,
	hometown varchar(50),
	photo_id bigint unsigned,
	pass char(50) not null, -- добавим обязательным ввести пароль
	created_at datetime default current_timestamp,
	index(phone),
	index(email),
	index(name, surname),
	foreign key (gender) references genders (id), -- добавим  связь с таблицей с расшифровкой по гендерам
	check (email is not null or phone is not null), -- добавим проверку, чтобы либо email, либо телефон не были пустыми
	check (birthday <= date_add(created_at, interval -16 year)) -- разрешим нашу соцсеть для лиц не младше 16 лет
);

drop table if exists messages;
create table messages(
	id serial primary key,
	from_user_id bigint unsigned not null,
	to_user_id bigint unsigned not null,
	body text,
	is_read bool default 0,
	created_at datetime default current_timestamp,
	quote_id bigint unsigned default null, -- добавим для ссылки на цитируемое предыдущее сообщение, по умолчанию - пусто
	foreign key (from_user_id) references users (id),
	foreign key (to_user_id) references users (id),
	foreign key (quote_id) references messages (id) -- сошлемся на саму себя
);

drop table if exists friend_requests;
create table friend_requests(
	initiator_user_id bigint unsigned not null,
	target_user_id bigint unsigned not null,
	status enum('requested', 'approved', 'unfriended', 'declined') default 'requested',
	requested_at datetime default now(),
	confirmed_at datetime default current_timestamp on update current_timestamp,
	primary key(initiator_user_id, target_user_id),
	foreign key (initiator_user_id) references users (id),
	foreign key (target_user_id) references users (id)
);

alter table friend_requests add index(initiator_user_id);

drop table if exists communities;
create table communities(
	id serial primary key,
	name varchar(150) not null, -- имя общества не должно быть пустым
	index communities_name_idx (name)
);


drop table if exists users_communities;
create table users_communities(
	user_id bigint unsigned not null,
	community_id bigint unsigned not null,
	is_admin bool default 0,
	primary key(user_id, community_id),
	foreign key (user_id) references users (id),
	foreign key (community_id) references communities (id)
);

drop table if exists posts;
create table posts(
	id serial primary key,
	user_id bigint unsigned not null,
	body text,
	metadata json,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	repost_id bigint unsigned default null, -- дадим возможность сделать репост
	foreign key (user_id) references users (id),
	foreign key (repost_id) references posts (id) -- сошлемся на саму себя
);

drop table if exists comments;
create table comments (
	id serial primary key,
	user_id bigint unsigned not null,
	post_id bigint unsigned not null,
	body text,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	root_id bigint unsigned default null, -- корневой комментарий / возможно и не нужен, т.к. циклом по prev_id до значения null можно вернуться к корню
	prev_id bigint unsigned default null, -- предыдущий комментарий
	foreign key (user_id) references users (id),
	foreign key (post_id) references posts (id),
	foreign key (root_id) references comments (id), -- сошлемся на саму себя
	foreign key (prev_id) references comments (id) -- сошлемся на саму себя
);

drop table if exists photos;
create table photos (
	id serial primary key,
	user_id bigint unsigned not null,
	description text default null, -- по умолчанию поставим пусто
	filename varchar(250) not null,
	foreign key (user_id) references users (id)
);

drop table if exists likes_post;
create table likes_post(
	user_id bigint unsigned not null, -- кто поставил лайк/дизлайк
	post_id bigint unsigned not null, -- на какой пост поставил лайк/дизлайк
	like_dis bool not null, -- 0 для дизлайка, 1 для лайка
	liked_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (post_id) references posts (id),
	primary key (user_id, post_id)
);

drop table if exists likes_comments;
create table likes_comments(
	user_id bigint unsigned not null, -- кто поставил лайк/дизлайк
	comment_id bigint unsigned not null, -- на какой коммент поставил лайк/дизлайк
	like_dis bool not null, -- 0 для дизлайка, 1 для лайка
	liked_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (comment_id) references comments (id),
	primary key (user_id, comment_id)
);
-- время добавил для возможности отследить динамику по лайкам и оценки "горячести" поста

-- для оценки юзеров сделаем рейтинговую систему от 1 до 5
drop table if exists rating_users;
create table rating_users(
	user_id bigint unsigned not null, -- кому поставили оценку
	valuing_user_id bigint unsigned not null, -- кто поставил оценку
	rate tinyint unsigned not null, -- оценка
	rated_at datetime default current_timestamp, -- время добавим для того,чтобы можно было смотреть динамику рейтинга пользователя
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (valuing_user_id) references users (id),
	primary key (user_id, valuing_user_id),
	check (rate <= 4) -- позволим ставить оценки от 0 до 4, т.е. по сути от 1 до 5.
);
