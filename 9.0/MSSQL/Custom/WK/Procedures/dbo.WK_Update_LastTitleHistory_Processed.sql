if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Update_LastTitleHistory_Processed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Update_LastTitleHistory_Processed
GO

CREATE PROCEDURE dbo.WK_Update_LastTitleHistory_Processed
@lastidprocessed int
AS
BEGIN

UPDATE WK_titlehistory_lastprocessed
SET LastIdProcessed = @lastidprocessed,
changeddate = getdate()

END