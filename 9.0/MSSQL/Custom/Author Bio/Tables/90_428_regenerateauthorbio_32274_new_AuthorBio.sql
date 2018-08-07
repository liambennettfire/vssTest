
IF (EXISTS (SELECT *
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_SCHEMA = 'dbo'
					AND TABLE_NAME = 'regenerateauthorbio'))
	DROP TABLE [dbo].[regenerateauthorbio]
GO

CREATE TABLE dbo.regenerateauthorbio(
	id UNIQUEIDENTIFIER NOT NULL,
	bookkey INT NOT NULL,
	printingkey INT NULL,
	created DATETIME NULL,
	updated DATETIME NULL,	
	lastmaintdate DATETIME NULL,
	lastuserid VARCHAR(30) NULL
)

GO

CREATE UNIQUE INDEX regenerateauthorbio_qp ON regenerateauthorbio (id)
GO

GRANT SELECT ON regenerateauthorbio TO PUBLIC
go
GRANT INSERT ON regenerateauthorbio TO PUBLIC
go
GRANT UPDATE ON regenerateauthorbio TO PUBLIC
go
GRANT DELETE ON regenerateauthorbio TO PUBLIC
go