drop database if exists snet1509;
create database snet1509;
use snet1509;

drop table if exists users;
create table users(
	id serial primary key,
	name varchar(50) not null,
	surname varchar(50) not null,
	email varchar(120) unique,
	phone bigint unique,
	gender char(1),
	birthday date,
	hometown varchar(50),
	photo_id bigint unsigned,
	pass char(50) not null,
	created_at datetime default current_timestamp,
	index(phone),
	index(email),
	index(name, surname),
	check (email is not null or phone is not null),
	check (birthday <= date_add(created_at, interval -16 year))
);

drop table if exists messages;
create table messages(
	id serial primary key,
	from_user_id bigint unsigned not null,
	to_user_id bigint unsigned not null,
	body text,
	is_read bool default 0,
	created_at datetime default current_timestamp,
	quote_id bigint unsigned default null,
	foreign key (from_user_id) references users (id),
	foreign key (to_user_id) references users (id),
	foreign key (quote_id) references messages (id)
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
	name varchar(150) not null,
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
	repost_id bigint unsigned default null,
	foreign key (user_id) references users (id),
	foreign key (repost_id) references posts (id)
);

drop table if exists comments;
create table comments (
	id serial primary key,
	user_id bigint unsigned not null,
	post_id bigint unsigned not null,
	body text,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	root_id bigint unsigned default null,
	prev_id bigint unsigned default null,
	foreign key (user_id) references users (id),
	foreign key (post_id) references posts (id),
	foreign key (root_id) references comments (id),
	foreign key (prev_id) references comments (id)
);

drop table if exists photos;
create table photos (
	id serial primary key,
	user_id bigint unsigned not null,
	description text default null,
	filename varchar(250) not null,
	foreign key (user_id) references users (id)
);

drop table if exists likes_post;
create table likes_post(
	user_id bigint unsigned not null,
	post_id bigint unsigned not null,
	like_dis bool not null,
	liked_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (post_id) references posts (id),
	primary key (user_id, post_id)
);

drop table if exists likes_comments;
create table likes_comments(
	user_id bigint unsigned not null,
	comment_id bigint unsigned not null,
	like_dis bool not null,
	liked_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (comment_id) references comments (id),
	primary key (user_id, comment_id)
);


drop table if exists rating_users;
create table rating_users(
	user_id bigint unsigned not null,
	valuing_user_id bigint unsigned not null,
	rate tinyint unsigned not null, -- оценка
	rated_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references users (id),
	foreign key (valuing_user_id) references users (id),
	primary key (user_id, valuing_user_id),
	check (rate <= 4)
);
