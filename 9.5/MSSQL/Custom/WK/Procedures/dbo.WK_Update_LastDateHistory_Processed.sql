if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Update_LastDateHistory_Processed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Update_LastDateHistory_Processed
GO
CREATE PROCEDURE dbo.WK_Update_LastDateHistory_Processed
@bookkey int,
@datetypecode int,
@datekey int,
@lastmaintdate_processed datetime

AS
BEGIN

UPDATE WK_datehistory_lastprocessed
SET bookkey = @bookkey,
datetypecode = @datetypecode,
datekey = @datekey,
lastmaintdate_processed = @lastmaintdate_processed,
changeddate = getdate() 

END