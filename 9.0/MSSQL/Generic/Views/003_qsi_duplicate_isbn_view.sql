if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qsi_duplicate_isbn_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[qsi_duplicate_isbn_view]
GO

CREATE VIEW qsi_duplicate_isbn_view AS
SELECT isbn, COUNT(*) count 
FROM isbn, printing 
WHERE isbn.bookkey = printing.bookkey AND
  printing.printingkey = 1 AND printing.issuenumber = 1 AND 
  isbn IS NOT NULL
GROUP BY isbn HAVING COUNT(*) > 1
go

GRANT SELECT ON qsi_invalid_isbn_view TO public
go
