if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_GetMessageQueueErrorById') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_GetMessageQueueErrorById
GO

CREATE PROCEDURE dbo.WK_GetMessageQueueErrorById
@messageId varchar(512)
AS

BEGIN

select messageid, attemptCounter, createDate, lastuserid, lastmaintdate from WK_MessageQueueErrors 
where messageid like '%' + @messageId + '%'

END