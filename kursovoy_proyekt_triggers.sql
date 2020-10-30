-- триггер, который делит таблицу site_share на две shares и shares_ps
delimiter //
create trigger insert_shares after insert on sites_share
for each row 
begin
	if new.price_segment is null then
		insert into shares values (new.code_site, new.`Планограмма`, new.share);
	else
		insert into shares_ps values (new.code_site, new.`Планограмма`, new.price_segment, new.share);
	end if;
end;
delimiter ;