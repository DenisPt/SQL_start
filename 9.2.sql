-------------------------------1-------------------------------
create user shop;
create user shop_read;
grant all on shop.* to shop;
grant grant option on shop.* to shop; -- если нужно дать право юзеру shop раздавать права, связанные с этой БД
grant select on shop.* to shop_read;

-------------------------------2-------------------------------
create view username as select id, name from accounts;
create user user_read;
grant select on test_2.username to user_read; -- test_2 название БД, в которой создана таблица
