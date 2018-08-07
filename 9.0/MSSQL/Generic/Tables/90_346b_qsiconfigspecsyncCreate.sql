/****** Object:  Table [dbo].[qsiconfigspecsync]    Script Date: 11/11/2014 15:14:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qsiconfigspecsync]') AND type in (N'U'))
DROP TABLE [dbo].[qsiconfigspecsync]
GO

/****** Object:  Table [dbo].[qsiconfigspecsync]    Script Date: 11/11/2014 15:14:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[qsiconfigspecsync](
	[qsiconfigspecsynckey] [int] IDENTITY(1,1) NOT NULL,
	[specitemcategory] [int] NULL,
	[specitemcode] [int] NULL,
	[multicomptypekey] [int] NULL,
	[itemtype] [int] NULL,
	[usageclass] [int] NULL,
	[exceptioncode] [int] NULL,
	[syncfromspecsind] [int] NULL,
	[synctospecsind] [int] NULL,
	[specitemtype] [varchar](2) NULL,
	[datatype] [varchar](10) NULL,
	[tablename] [varchar](255) NULL,
	[columnname] [varchar](255) NULL,
	[keycolumn1] [varchar](255) NULL,
	[keycolumn2] [varchar](255) NULL,
	[keycolumn3] [varchar](255) NULL,
	[keycolumnconcat] [varchar](255) NULL,
	[mappingkey] [int] NULL,
	[activeind] [int] NULL,
	[lastuserid] [varchar](255) NULL,
	[lastmaintdate] [datetime] NULL,
	[parentspecitemcategory] [int] NULL,
	[firstprintonly] [int] NULL,
	[defaultuomvalue] [int] NULL,
	[bestid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[qsiconfigspecsynckey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[qsiconfigspecsyncmapping]    Script Date: 11/11/2014 15:19:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qsiconfigspecsyncmapping]') AND type in (N'U'))
DROP TABLE [dbo].[qsiconfigspecsyncmapping]
GO


/****** Object:  Table [dbo].[qsiconfigspecsyncmapping]    Script Date: 11/11/2014 15:19:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[qsiconfigspecsyncmapping](
	[qsiconfigspecsyncmappingkey] [int] IDENTITY(1,1) NOT NULL,
	[mappingkey] [int] NULL,
	[tablevaluedatatype] [varchar](255) NULL,
	[tablevalue] [varchar](255) NULL,
	[specitemvaluedatatype] [varchar](255) NULL,
	[specitemvalue] [varchar](255) NULL,
	[activeind] [int] NULL,
	[lastuserid] [varchar](255) NULL,
	[lastmaintdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[qsiconfigspecsyncmappingkey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO