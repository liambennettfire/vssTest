SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[export_MBI_TablesToText]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[export_MBI_TablesToText]
GO


CREATE PROCEDURE export_MBI_TablesToText(@database	VARCHAR(100),
					@server		VARCHAR(100),
					@userid		VARCHAR(30))
AS
BEGIN
/* BCP table outs		*/

		execute export_tableToText  @database,'export_title','mbi_title','E:\DataFeeds\Out\MBI\',@server,'qsidba','qsidba'

		execute export_tableToText  @database,'export_author','mbi_author','E:\DataFeeds\Out\MBI\',@server,'qsidba','qsidba'

		execute export_tableToText  @database,'export_subject','mbi_subject','E:\DataFeeds\Out\MBI\',@server,'qsidba','qsidba'

		execute export_tableToText  @database,'export_comment','mbi_comment','E:\DataFeeds\Out\MBI\',@server,'qsidba','qsidba'

		execute export_tableToText @database,'export_assoctitle','mbi_assoctitle','E:\DataFeeds\Out\MBI\',@server,'qsidba','qsidba'

END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

