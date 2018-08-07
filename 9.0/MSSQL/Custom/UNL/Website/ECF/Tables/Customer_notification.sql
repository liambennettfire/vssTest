if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].ProductEx_Journals') and OBJECTPROPERTY(id, N'IsTable') = 1)
drop table [dbo].[Customer_notification]

GO

CREATE TABLE [dbo].[Customer_notification](
	[Skuid] [int] NOT NULL,
	[Skustatus] [nvarchar](256) NOT NULL,
	[Customerid] [int] NULL,
	[Name] [nvarchar] (256) NOT NULL,
	[CustomerEmail] [nvarchar] (256) NOT NULL,
	[NotificationSentInd] [int] NOT NULL,
	[NotificationSentDate] [datetime] NULL,
	[lastmaintdate] [datetime] NULL,
	[lastuserid] [nvarchar](256) NOT NULL
	
) ON [PRIMARY]