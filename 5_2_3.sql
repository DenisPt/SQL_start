select
	if((select count(*) from catalogs where value = 0) > 0, 0, 1)*
	pow(-1, (select count(*) from catalogs where value < 0))*
	round(pow(10, sum(log10(if(value < 0, -value, value)))),0) as prod
from
	catalogs;
