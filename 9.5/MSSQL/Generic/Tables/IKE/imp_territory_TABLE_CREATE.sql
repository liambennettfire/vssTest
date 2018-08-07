/****** Object:  Table [dbo].[imp_territory]    Script Date: 5/11/2016 1:47:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/****** Object:  Table [dbo].[imp_territory]    Script Date: 5/11/2016 1:47:52 AM ******/
if not exists ( select 1 from INFORMATION_SCHEMA.TABLES where TABLE_TYPE='BASE TABLE' and TABLE_NAME='imp_territory') 
--DROP TABLE [dbo].[imp_territory]
--GO
begin


CREATE TABLE [dbo].[imp_territory](
	[batchkey] [int] NULL,
	[row_id] [int] NULL,
	[itemtype] [int] NULL,
	[forsaleind] [int] NULL,
	[contractexclusiveind] [int] NULL,
	[nonexclusivesubrightsoldind] [int] NULL,
	[currentexclusiveind] [int] NULL,
	[exclusivesubrightsoldind] [int] NULL,
	[CountryDesc] [varchar](200) NULL,
	[CountryCode] [int] NULL,
	[ExclusiveCode] [int] NULL,
	[DeleteInd] [int] NULL
) ON [PRIMARY]
end
else begin
	print 'WARNING: Table imp_territory already exists, do not want to drop it if it is in use. Double check the columns to make sure there are no updates.'
end

GO

SET ANSI_PADDING OFF
GO


