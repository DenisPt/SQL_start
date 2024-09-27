select * from storehouses_products order by if(value = 0, 1, 0), value;
