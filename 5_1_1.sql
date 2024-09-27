update users set created_at = now() where created_at <=> null;
update users set updated_at = now() where updated_at <=> null;
