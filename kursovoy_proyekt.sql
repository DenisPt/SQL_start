/*drop database if exists gold_ord_new;
create database gold_ord_new;
use gold_ord_new;*/
SET foreign_key_checks = 0;
-- таблица, которая содержит данные по магазинам, РЦ, изменяетя редко, вручную
drop table if exists sites;
create table sites(
	code int unsigned not null unique primary key, -- код магазина 5-значный числовой
	name char(5) not null unique, -- краткое наименование магазина которое соответствует рег. выражению "^...-\d$"
	status enum('РЦ', 'открыт', 'закрыт', 'новый') not null,
	T tinyint unsigned not null, -- периодичность отгрузки товара на магазин
	L tinyint unsigned not null, -- скорость доставки товара на магазин
	Lreg tinyint unsigned not null, -- скорость доставки товара с особыми условиями доставки (напр., теплый контейнер)
	check(name rlike '^...-\d$')
);
-- таблица, в которой будут храниться данные по количеству страховых дней для магазина, можно было бы объединить с таблицей sites,
-- но данными в этой таблицей и таблицей sites будут управлять разные люди, поэтому разделено
drop table if exists SS;
create table SS(
	code int unsigned not null unique primary key, -- код магазина
	SS_L float unsigned default 0, -- количество страховых дней на колебания доставки товара на магазин
	SS_add float unsigned default 0, -- количество дополнительных страховых дней для магазина,  определенные вручную
	foreign key (code) references sites (code)
);


-- таблица с данными по поставщикам
drop table if exists supplier;
create table supplier(
	code char(12) not null, -- код поставщика, соответств. рег. выражению "^\{.{10}\}$"
	name varchar(255) not null, -- наименование поставщика
	com_con char(9) unique primary key, -- код коммерческого контракта, соответств. рег. выражению "^\{.{7}\}$"
	country varchar(255) not null, -- название страны поставщика
	payment int, -- условия оплаты (отсрочка в днях, '-1' соответствует товарам на реализации)
	add_chain tinyint unsigned not null, -- адресная цепочка не несет информации,но нужна для загрузки заказов в erp систему
	check(code rlike '^\{.{10}\}$'),
	check(com_con rlike '^\{.{7}\}$')
);

-- товарный классификатор, наимнования столбцов на русском, т.к. 
-- они соответствуют тому файлу, который уже выгружается из erp системы для удобства загрузки в эту БД
drop table if exists classifier;
create table classifier(
	Направление varchar(255) not null,
	Отдел varchar(255) not null,
	Планограмма varchar(255) not null,
	Категория varchar(255) not null,
	Подкатегория varchar(255) not null,
	code char(12) not null unique primary key,
	`Ключевая группа` varchar(255),
	`Продакт-менеджер` varchar(255) not null,
	`Характер спроса` varchar(255) not null,
	`Первый месяц сезонного спроса` tinyint unsigned,
	`Пиковый месяц сезонного спроса` tinyint unsigned,
	`Последний месяц сезонного спроса` tinyint unsigned,
	`Тип выкладки УТК` varchar(255) not null,
	`Группа Ксез` varchar(255) not null,
	check(code rlike '^\{.{12}\}$')
);

-- таблица с характеристиками товаров
drop table if exists goods;
create table goods(
	code char(8) not null unique primary key, -- соответств. рег. выраж. '^\{.{6}\}$'
	LV tinyint unsigned not null, -- логистический варинат, необходим только для загрузки заказа в erp систему
	name varchar(50) not null, -- наименование товара максимум 50 символов
	EAN_code varchar(20) unique not null, -- штрих-код, соответств. рег. выражению "^\{.+\}$"
	indic tinyint unsigned not null, -- характеристика "Индикатор"
	vol float unsigned not null, -- объем товара в куб.м.
	weight float unsigned not null, -- вес товара в кг
	inner_mul int unsigned not null, -- кратность внутренней упаковки в шт.
	box_mul int unsigned not null, -- кратность коробки в шт.
	features tinyint not null, -- особенности товара, если не равно "-1" товар запрещено возить штуками на магазин может принимать значения "-1, 0, 1, 2"
	MOQ int unsigned, -- минимальный размер заказа по товару в шт.
	temp_regime int not null, -- температурный режим товара,может принимать значения 0, 1, 2, 3
	exp_date int unsigned not null, -- полный срок годности в днях по товару, 0 - если отсутствует СГ
	exp_date_in int unsigned not null, -- минимальный срок годности, с которым товар может поступить на РЦ
	num_goods tinyint unsigned not null, -- количество ассортиментных позиций в одном коде товара
	subcat_code char(12) not null, -- код подкатегории товара
	price_segment tinyint unsigned not null, -- ценовой сегмент по товару, принимает значение 0, 1 или 2
	com_con char(9), -- привязка к поставщику идет через ком. контракт
	brand varchar(50) not null, -- наименование бренда товара
	foreign key (subcat_code) references classifier(code),
	foreign key (com_con) references supplier(com_con),
	check (code rlike '^\{.{6}\}$')
);

-- таблица содержит топ-1000 товаров по Profit, управляется вручную, поэтому отдельно от таблицы goods
drop table if exists top_prft;
create table top_prft(
	code char(8) not null unique primary key,
	foreign key (code) references goods(code)
);

-- таблица с остатками и остальными данными по связке товар-магазин
drop table if exists allstock;
create table allstock(
	code_site int unsigned not null, -- код магазина
	code_good char(8) not null , -- код товара
	AZ_GOLD tinyint unsigned, 
	AZ_IKB tinyint unsigned,
	KZ_GOLD int unsigned,
	INV int unsigned not null, --  остаток
	INTransit int unsigned not null, -- в пути
	INOrders int unsigned not null, -- в заказах
	INV_rotation int unsigned not null, -- остаток ротируемого товара
	-- параметры автозаказа
	type_order tinyint unsigned not null,
	min_order int unsigned not null,
	fix_order int unsigned not null,
	--
	purch_price double unsigned not null, -- закупочная цена
	purch_price_vat double unsigned not null, -- закупочная цена c НДС
	retail_price double unsigned not null, -- розничная цена с НДС
	deficit float unsigned not null, --  дефицит по товару на объекте, принимает значение от 0% до 100%
	first_accept date, -- дата первой приемки товара на магазине
	last_accept date, -- дата последней приемки товара на магазине
	first_admis date,  -- дата ближайшего поступления товара на магазин
	first_admis_qty int unsigned, -- количество товара в ближайшем поступлении
	second_admis date,  -- дата второго поступления товара на магазин
	second_admis_qty int unsigned, -- количество товара во втором поступлении
	third_admis date,  -- дата третьего поступления товара на магазин
	third_admis_qty int unsigned, -- количество товара в третьем поступлении
	PS int unsigned, -- неснижаемый запас
	Capacity int unsigned, -- вместимость товара на полке в магазине
	foreign key (code_site) references sites(code),
	foreign key (code_good) references goods(code),
	primary key (code_good, code_site)
);

-- таблица с рассчитанным среднедневным спросом по статистике и некоторыми данными о продажах по связке товар-магазин
-- выгружается отдельно от ALLSTOCK поэтому не объеденена с предыдущей таблицей
drop table if exists avgsale;
create table avgsale(
	code_site int unsigned not null, -- код магазина
	code_good char(8) not null , -- код товара
	d_norm double unsigned not null, --  среднедневной спрос
	d_type bool not null, -- 0, если спрос рассчитан по статистике, 1, если восстановлен по доле магазина в УТК
	sales28 int unsigned, -- количество товара, проданного за последние 28 дней на магазине
	last_sale date, -- дата последней продажи товара на магазине
	foreign key (code_site) references sites(code),
	foreign key (code_good) references goods(code),
	primary key (code_good, code_site)
);

-- таблица прогнозов продаж по товарам с сезонным спросом
-- K1 - K24_2 - коэффициенты сезонности, как их добавить в основное представлениее еще не придумал
drop table if exists avg_season;
create table avg_season(
	code_good char(8) not null unique primary key , -- код товара
	d double unsigned not null, -- среднедневной спрос за сезонный период
	k1 double unsigned not null,
	k2_1 double unsigned not null,
	k2_2 double unsigned not null,
	k3_1 double unsigned not null,
	k3_2 double unsigned not null,
	k4 double unsigned not null,
	k5 double unsigned not null,
	k6 double unsigned not null,
	k7 double unsigned not null,
	k8 double unsigned not null,
	k9 double unsigned not null,
	k10 double unsigned not null,
	k11 double unsigned not null,
	k12_1 double unsigned not null,
	k12_2 double unsigned not null,
	k13 double unsigned not null,
	k14_1 double unsigned not null,
	k14_2 double unsigned not null,
	k15_1 double unsigned not null,
	k15_2 double unsigned not null,
	k16 double unsigned not null,
	k17 double unsigned not null,
	k18 double unsigned not null,
	k19 double unsigned not null,
	k20 double unsigned not null,
	k21 double unsigned not null,
	k22 double unsigned not null,
	k23 double unsigned not null,
	k24_1 double unsigned not null,
	k24_2 double unsigned not null,
	foreign key (code_good) references goods(code)
);

-- таблица с данными о ближайших акциях по товарам на магазине
-- в данной таблице будет только одна ближайшая акция по товару на магазине
drop table if exists allpromo;
create table allpromo(
	code_site int unsigned not null, -- код магазина
	code_good char(8) not null , -- код товара
	promo_begin date not null,
	promo_end date not null,
	promo_rate float unsigned not null, -- к. увеличения плана продаж на период акции
	foreign key (code_site) references sites(code),
	foreign key (code_good) references goods(code),
	primary key (code_good, code_site)
);

-- таблицы долей магазинов
-- таблица может быть построена по связке "Магазин - Планограмма" или по связке "Магазин - Планограмма - ценовой сегмент"
-- основная идея в том, что при заполнении основной таблицы sites_share будут срабатывать триггер и
-- в таблицу shares - пойдут доли по связке "Магазин - Планограмма"
-- в таблицу shares_ps - пойдут доли по связке "Магазин - Планограмма - Ценовой сегмент"
drop table if exists sites_share;
create table sites_share(
	code_site int unsigned not null, -- код магазина
	Планограмма varchar(255) not null,
	price_segment tinyint unsigned,
	share float unsigned not null -- доля магазина в продажах планограммы
);

drop table if exists shares;
create table shares(
	code_site int unsigned not null,
	Планограмма varchar(255) not null,
	share float unsigned not null,
	foreign key (code_site) references sites(code)
);

drop table if exists shares_ps;
create table shares_ps(
	code_site int unsigned not null,
	Планограмма varchar(255) not null,
	price_segment tinyint unsigned not null,
	share float unsigned not null,
	foreign key (code_site) references sites(code)
);

-- таблица с коэффициентами прогноза продаж
-- коэффициенты могут быть построены по товару, подкатегории в связке с ценовым сегментом
-- или просто по подкатегории, таблица будет разбиваться триггером 
-- на 3 таблицы, в зависимости от связки, по которой строились коэффициенты,
-- триггер напишу после того, как придумаю как выгружать данные коэф. в основное представление
-- т.к. скорее всего придется еще прописывать UNPIVOT этой таблицы
drop table if exists coefficients;
create table coefficients(
	obj varchar(12) not null, -- код товара или код подкатегории
	price_segment tinyint unsigned,
	k1 double unsigned not null,
	k2_1 double unsigned not null,
	k2_2 double unsigned not null,
	k3_1 double unsigned not null,
	k3_2 double unsigned not null,
	k4 double unsigned not null,
	k5 double unsigned not null,
	k6 double unsigned not null,
	k7 double unsigned not null,
	k8 double unsigned not null,
	k9 double unsigned not null,
	k10 double unsigned not null,
	k11 double unsigned not null,
	k12_1 double unsigned not null,
	k12_2 double unsigned not null,
	k13 double unsigned not null,
	k14_1 double unsigned not null,
	k14_2 double unsigned not null,
	k15_1 double unsigned not null,
	k15_2 double unsigned not null,
	k16 double unsigned not null,
	k17 double unsigned not null,
	k18 double unsigned not null,
	k19 double unsigned not null,
	k20 double unsigned not null,
	k21 double unsigned not null,
	k22 double unsigned not null,
	k23 double unsigned not null,
	k24_1 double unsigned not null,
	k24_2 double unsigned not null
);

SET foreign_key_checks = 1;