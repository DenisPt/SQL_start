-- ниже идет основное представление, которое используется для расчета заказов поставщикам
-- достаточно простое, т.к. БД старался проектировать так, чтобы мы по сути выбирали все столбцы из всех таблиц, которые есть

-- второе что осталось сделать это добавить столбцы, отвечающие за периоды: январь текущего года - декабрь следующего года, причем
-- февраль, март и декабрь разбиты на 2 периода: один с 1 по 15 число, другой с 16 до окончания месяца
-- так же по этим периодам присоединяются сезонные коэффициенты по 3 из возможных связок: 
-- товар - коэффициенты, группа Ксез - ценовой сегмент - коэффициенты, группа Ксез - коэффициенты
-- пока тоже не придумаал как реализовать
drop view if exists main;
create view main as
select
	supplier.name as `Поставщик`,
	supplier.payment as `Условия оплаты`,
	supplier.country as `Страна поставщика`,
	supplier.code as `Код поставщика`,
	supplier.com_con as `КК`,
	supplier.add_chain as `Адресная цепочка`,
	classifier.Направление as `Направление`,
	classifier.Отдел as `Отдел`,
	classifier.Планограмма as `Планограмма`,
	classifier.Категория as `Категория`,
	classifier.Подкатегория as `Подкатегория`,
	classifier.code as `Код подкатегории`,
	classifier.code as `Группа Ксез`,
	classifier.`Ключевая группа` as `Ключевая группа`,
	classifier.`Продакт-менеджер` as `Продакт-менеджер`,
	classifier.`Характер спроса` as `Характер спроса`,
	classifier.`Первый месяц сезонного спроса` as `Первый месяц сезонного спроса`,
	classifier.`Пиковый месяц сезонного спроса` as `Пиковый месяц сезонного спроса`,
	classifier.`Последний месяц сезонного спроса` as `Последний месяц сезонного спроса`,
	classifier.`Тип выкладки УТК` as `Тип выкладки УТК`,
	goods.brand as `Бренд`,
	goods.code as `Код товара`,
	goods.LV as `ЛВ`,
	goods.name as `Наименование товара`,
	goods.EAN_code as `Штрих-код товара в заказе`,
	goods.indic as `Индикатор`,
	if(top_prft.code is null, 0, 1) as `Группа А по Profit1`,
	goods.vol as `Объем`,
	goods.weight as `Вес`,
	goods.inner_mul as `Иннер`,
	goods.box_mul as `Короб`,
	goods.features as `Особенности товара`,
	goods.MOQ as MOQ,
	goods.temp_regime as `Температурный режим`,
	goods.exp_date as `Полный срок годности`,
	goods.exp_date_in as `Входящий срок годности`,
	goods.num_goods as `Ассортиментность`,
	sites.name as `Объект`,
	sites.code as `Код объекта`,
	sites.status as `Статус объекта`,
	sites.T as T,
	sites.L as L,
	sites.Lreg as `L режим`,
	ifnull(shares_ps.share, shares.share) as `Доля магазина`,
	allstock.AZ_GOLD as `АЗ GOLD`,
	allstock.AZ_IKB as `АЗ IKB`,
	allstock.KZ_GOLD as `КЗ GOLD`,
	allstock.INV as `Свободный остаток`,
	allstock.INTransit as `В пути`,
	allstock.INOrders as `В заказах`,
	allstock.INV_rotation as `Остаток ротируемого товара`,
	allstock.type_order as `Тип автозаказа`,
	allstock.min_order as `Мин`,
	allstock.fix_order as `Фикс`,
	allstock.purch_price as `Закуп. цена без НДС`,
	allstock.purch_price_vat as `Закуп. цена с НДС`,
	allstock.retail_price as `Розничная цена`,
	goods.price_segment as `Ценовой сегмент`,
	avgsale.d_norm as `dнорм`,
	avgsale.d_type as `Тип расчета dнорм`,
	avg_season.d as `d СХС`, -- СХС = сезонный характер спроса
 	allpromo.promo_begin as `Дата начала акции`,
 	allpromo.promo_end as `Дата завершения акции`,
 	allpromo.promo_rate as `Коэффициент прироста акции`,
 	allstock.deficit as `Дефицит на объекте за 4 недели`,
 	avgsale.sales28 as `Продано на объекте за 4 недели`,
 	avgsale.last_sale as `Дата последней продажи`,
 	allstock.first_accept as `Дата первой приемки`,
 	allstock.last_accept as `Дата последней приемки`,
 	allstock.first_admis as `Плановая дата прихода 1 заказа`,
 	allstock.first_admis_qty as `Количество в 1 заказе`,
 	allstock.second_admis as `Плановая дата прихода 2 заказа`,
 	allstock.second_admis_qty as `Количество во 2 заказе`,
 	allstock.third_admis as `Плановая дата прихода 3 заказа`,
 	allstock.third_admis_qty as `Количество в 3 заказе`,
 	allstock.PS as `PS IKB`,
 	ss.SS_L as `SS Lмаг`,
 	ss.SS_add as `SS доп. маг.`,
 	allstock.Capacity as `Капасити`
from
	allstock
join goods on
	allstock.code_good = goods.code
join sites on
	allstock.code_site = sites.code
join avgsale on
	allstock.code_good = avgsale.code_good
	and allstock.code_site = avgsale.code_site
join avg_season on
	goods.code = avg_season.code_good
join allpromo on
	allstock.code_good = allpromo.code_good
	and allstock.code_site = allpromo.code_site
join ss on
	sites.code = ss.code
join top_prft on
	goods.code = top_prft.code
join classifier on
	goods.subcat_code = classifier.code
join supplier on
	goods.com_con = supplier.com_con
join shares on
	allstock.code_site = shares.code_site
	and classifier.Планограмма = shares.Планограмма
join shares_ps on
	allstock.code_site = shares_ps.code_site
	and classifier.Планограмма = shares_ps.Планограмма 
	and goods.price_segment = shares_ps.price_segment