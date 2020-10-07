-- вариант 1
select id, name, (select name from catalogs where id = products.catalog_id) as catalog_name from products;

-- вариант 2
select p.id as id, p.name as name, c.name as catalog_name from products as p join catalogs as c on p.catalog_id = c.id;
