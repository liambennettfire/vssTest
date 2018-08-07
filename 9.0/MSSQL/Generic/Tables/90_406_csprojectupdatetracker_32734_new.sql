IF (EXISTS (SELECT *
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_SCHEMA = 'dbo'
					AND TABLE_NAME = 'csprojectupdatetracker'))
	DROP TABLE [dbo].[csprojectupdatetracker]
GO

CREATE TABLE dbo.csprojectupdatetracker(
	id UNIQUEIDENTIFIER NOT NULL,
	projectkey INT NOT NULL,
	created DATETIME NULL,
	updated DATETIME NULL,	
	lastmaintdate DATETIME NULL,
	lastuserid VARCHAR(30) NULL
)

GO

CREATE UNIQUE INDEX csprojectupdatetracker_qp ON csprojectupdatetracker(id)
GO

GRANT SELECT ON csprojectupdatetracker TO PUBLIC
go
GRANT INSERT ON csprojectupdatetracker TO PUBLIC
go
GRANT UPDATE ON csprojectupdatetracker TO PUBLIC
go
GRANT DELETE ON csprojectupdatetracker TO PUBLIC
go