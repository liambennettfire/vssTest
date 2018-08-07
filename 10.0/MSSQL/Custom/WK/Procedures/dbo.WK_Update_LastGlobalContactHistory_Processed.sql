if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_Update_LastGlobalContactHistory_Processed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.[WK_Update_LastGlobalContactHistory_Processed]
GO

CREATE PROCEDURE [dbo].[WK_Update_LastGlobalContactHistory_Processed]
@lastidprocessed int
AS
BEGIN

UPDATE WK_globalcontacthistory_lastprocessed
SET LastIdProcessed = @lastidprocessed,
changeddate = getdate()

END
