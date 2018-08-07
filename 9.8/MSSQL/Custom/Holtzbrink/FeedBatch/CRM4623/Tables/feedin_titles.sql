IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.feedin_titles') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
  DROP TABLE dbo.feedin_titles

GO

CREATE TABLE feedin_titles
(
	isbn VARCHAR(10) NULL,
	bisacstatuscode VARCHAR(10) NULL,
	retailprice VARCHAR(20) NULL,
	canadianprice VARCHAR(20) NULL,
	categorycode VARCHAR(12) NULL,
	pubdate VARCHAR(12) NULL,
	reldate VARCHAR(12) NULL,
	cartonqty VARCHAR(10) NULL,
	projectisbn VARCHAR(20) NULL,
	canadianrestriction VARCHAR(10) NULL,
	discountcode VARCHAR(10) NULL,
	netprice VARCHAR(20) NULL,
	delivery_date VARCHAR(12) NULL)


GO

GRANT ALL ON feedin_titles TO PUBLIC
GO

create index feedin_titles_p1 
    ON dbo.feedin_titles (isbn)
GO

