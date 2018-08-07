/****** Object:  Table [dbo].[qpl_multicomponent]    Script Date: 11/11/2014 15:28:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_multicomponent]') AND type in (N'U'))
DROP TABLE [dbo].[qpl_multicomponent]
GO

/****** Object:  Table [dbo].[qpl_multicomponent]    Script Date: 11/11/2014 15:28:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[qpl_multicomponent](
	[qplmulticomponentkey] [int] IDENTITY(1,1) NOT NULL,
	[taqversionspecategorykey] [int] NULL,
	[key1] [int] NULL,
	[key2] [int] NULL,
	[key3] [int] NULL,
	[multicomptypekey] [int] NULL,
	[specitemcategorycode] [int] NULL,
	[tablelinkingkey] [int] NULL,
	[lastuserid] [varchar](50) NULL,
	[lastmaintdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[qplmulticomponentkey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

grant all on [qpl_multicomponent] to public
go

