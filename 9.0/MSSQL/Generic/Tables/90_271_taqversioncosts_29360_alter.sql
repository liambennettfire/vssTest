UPDATE taqversioncosts SET taqversionspeccategorykey = 0 WHERE taqversionspeccategorykey IS NULL
go

ALTER TABLE taqversioncosts
ALTER COLUMN taqversionspeccategorykey INT NOT NULL
go

ALTER TABLE taqversioncosts
ADD CONSTRAINT DF_taqversioncosts_taqversionspeccategorykey DEFAULT 0 FOR taqversionspeccategorykey
go

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[taqversioncosts]') AND name = N'taqversioncosts_qp')
ALTER TABLE [dbo].[taqversioncosts] DROP CONSTRAINT [taqversioncosts_qp]
go

ALTER TABLE taqversioncosts 
ADD CONSTRAINT taqversioncosts_qp PRIMARY KEY (taqversionformatyearkey, acctgcode, taqversionspeccategorykey)
GO
