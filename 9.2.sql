-------------------------------1-------------------------------
create user shop;
create user shop_read;
grant all on shop.* to shop;
grant grant option on shop.* to shop;
grant select on shop.* to shop_read;

-------------------------------2-------------------------------
create view username as select id, name from accounts;
create user user_read;
grant select on test_2.username to user_read;
