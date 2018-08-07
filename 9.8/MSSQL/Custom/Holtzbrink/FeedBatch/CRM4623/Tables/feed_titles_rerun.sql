CREATE TABLE feed_titles_rerun
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
	delivery_date DATETIME NULL,
)
GO


create index feed_titles_rerun_p1 ON feed_titles_rerun(isbn)
GO

GRANT ALL ON feed_titles_rerun TO PUBLIC
GO


