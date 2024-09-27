update users set created_at = concat(substring(created_at, 7, 4),
					"-",substring(created_at, 4, 2),
					"-",substring(created_at, 1, 2),
					" ", if(substring(created_at, 13, 1)=":",
						concat("0", substring(created_at, 12, 1)),
						substring(created_at, 12, 2)),
					":", substring(created_at, -2, 2), ":00"),
		updated_at = concat(substring(updated_at, 7, 4),
					"-",substring(updated_at, 4, 2),
					"-",substring(updated_at, 1, 2),
					" ", if(substring(updated_at, 13, 1)=":",
						concat("0", substring(updated_at, 12, 1)),
						substring(updated_at, 12, 2)),
					":", substring(updated_at, -2, 2), ":00" );
					
alter table users modify column created_at datetime;
alter table users modify column updated_at datetime;
