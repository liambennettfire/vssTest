if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_InsertMessageQueueError') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_InsertMessageQueueError
GO

CREATE PROCEDURE dbo.WK_InsertMessageQueueError
@messageId varchar(512),
@attemptCounter int,
@createdate datetime,
@lastuserid varchar(512),
@lastmaintdate datetime

AS

BEGIN
-- Insert new messageerror object here
SET NOCOUNT ON 

INSERT INTO dbo.WK_MessageQueueErrors
  ( 
    messageid,
    attemptCounter,
    createDate,
    lastuserid,
    lastmaintdate                                    
  ) 
VALUES 
  ( 
    @messageId,
    @attemptCounter,
    @createdate,
    @lastuserid ,
    @lastmaintdate                                 
  ) 

END