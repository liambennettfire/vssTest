if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_UpdateMessageQueueError') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_UpdateMessageQueueError
GO

CREATE PROCEDURE dbo.WK_UpdateMessageQueueError
@messageId varchar(512),
@attemptCounter int,
@lastuserid varchar(512),
@lastmaintdate datetime

AS

BEGIN

UPDATE dbo.WK_MessageQueueErrors
SET 
    attemptCounter  = ISNULL(@attemptCounter  , attemptCounter      ),
    lastuserid  = ISNULL(@lastuserid  , lastuserid      ),
    lastmaintdate  = ISNULL(@lastmaintdate  , lastmaintdate      )
where messageid like '%' + @messageId + '%'

END