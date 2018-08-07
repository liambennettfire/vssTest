IF EXISTS (SELECT * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'elo_full_rights_by_territory')
    DROP TABLE elo_full_rights_by_territory;


CREATE TABLE elo_full_rights_by_territory
 (territorycode int NULL,
	forsalerights varchar(max) NULL,
	notforsalerights varchar(max) NULL,
	fullrights varchar(max) NULL)
GO

GRANT SELECT ON elo_full_rights_by_territory TO PUBLIC
go
GRANT INSERT ON elo_full_rights_by_territory TO PUBLIC
go
GRANT UPDATE ON elo_full_rights_by_territory TO PUBLIC
go
GRANT DELETE ON elo_full_rights_by_territory TO PUBLIC
go
