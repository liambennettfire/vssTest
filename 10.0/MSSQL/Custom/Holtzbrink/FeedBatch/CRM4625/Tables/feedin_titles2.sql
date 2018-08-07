IF exists (select * from dbo.sysobjects where id = object_id(N'feedin_titles2') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
  DROP TABLE feedin_titles2

GO

CREATE TABLE feedin_titles2
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
	discountcode VARCHAR(12) NULL,
	nextisbn VARCHAR(10) NULL
)

GO



