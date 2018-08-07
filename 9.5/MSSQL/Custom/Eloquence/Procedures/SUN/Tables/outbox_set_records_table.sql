/****** Object:  Table [dbo].[outbox_set_records]    Script Date: 08/27/2007 18:30:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
drop table [dbo].[outbox_set_records]
GO
CREATE TABLE [dbo].[outbox_set_records](
	[parentbookkey] [int] NULL,
	[childbookkey] [int] NULL,
	[parentisbn10] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parentisbn13] [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parenttitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parentprice] [float] NULL,
	[childitemnum] varchar(20) NULL,
	[childisbn10] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[childisbn13] [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[childtitle] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[childpublisher] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[childpublistprice] [float] NULL,
	[childnationallistprice] [float] NULL,
	[childquantity] [int] NULL,
	[itemform] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sortorder] [int] NULL,
	[imprint] varchar(255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF