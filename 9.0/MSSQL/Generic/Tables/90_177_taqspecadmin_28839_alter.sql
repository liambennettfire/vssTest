ALTER TABLE taqspecadmin
ADD culturecode INT NULL,
    itemlabel VARCHAR(255),
    showdesc2ind TINYINT,
    showdesc2label VARCHAR(255)	
go

/****** Object:  Index [taqspecadmin_qp]    Script Date: 07/29/2014 08:57:15 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[taqspecadmin]') AND name = N'taqspecadmin_qp')
DROP INDEX [taqspecadmin_qp] ON [dbo].[taqspecadmin] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [taqspecadmin_qp]    Script Date: 07/29/2014 08:57:07 ******/
CREATE UNIQUE CLUSTERED INDEX [taqspecadmin_qp] ON [dbo].[taqspecadmin] 
(
	[itemcategorycode] ASC,
	[itemcode] ASC,
	[culturecode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
