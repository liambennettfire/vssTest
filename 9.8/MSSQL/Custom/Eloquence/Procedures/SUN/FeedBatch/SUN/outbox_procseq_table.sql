/****** Object:  Table [dbo].[outbox_procseq]    Script Date: 08/27/2007 18:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[outbox_procseq](
	[stepcount] [int] NULL,
	[totaltitles] [int] NULL,
	[success] [int] NULL
) ON [PRIMARY]


Insert into [dbo].[outbox_procseq]
Select 0,0,0

Grant all on [dbo].[outbox_procseq] to public