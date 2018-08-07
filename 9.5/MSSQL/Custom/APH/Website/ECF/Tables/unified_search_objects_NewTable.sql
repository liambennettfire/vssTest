SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

/****** Object:  Table [dbo].[qweb_unified_search_objects]    Script Date: 01/14/2011 09:52:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_unified_search_objects]') AND type in (N'U'))
DROP TABLE [dbo].[qweb_unified_search_objects]
GO

CREATE TABLE [dbo].[qweb_unified_search_objects](
  [search_object_id] int identity(1,1),
  [agency] [varchar](8000) NOT NULL,
  [isbn] [varchar](8000)  NULL,
  [catalog_number] [varchar] (8000 ) NOT NULL,
  [title] [varchar] (8000) NOT NULL,
  [subtitle] [varchar] (8000) NULL,
  [author_displayname] [varchar] (8000) NULL,
  [format] [varchar] (8000) NOT NULL,
  [series] [varchar] (8000) NULL,
  [edition] [varchar] (8000) NULL,
  [state_edition] [varchar] (8000) NULL,
  [original_publisher] [varchar] (8000) NULL,
  [copyright_year] [varchar] (8000) NULL,
  [subjects] [varchar] (8000) NULL,
  [brief_description] [varchar](8000) NULL,
  [url] [varchar] (8000) NOT NULL,
  [grade] [varchar] (8000 ) NULL,
  [createdate] [datetime] NULL,
  [lastmaintdate] [datetime] NULL,
  [lastuserid] [varchar](50) NULL,
 CONSTRAINT [PK_unified_search_objects] PRIMARY KEY CLUSTERED 
(
	[search_object_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
