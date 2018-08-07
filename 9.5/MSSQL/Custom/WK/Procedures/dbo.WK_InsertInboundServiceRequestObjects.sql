if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_InsertInboundServiceRequestObjects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_InsertInboundServiceRequestObjects
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[WK_InsertInboundServiceRequestObjects]
@messageId varchar(512),
@createdate datetime,
@lastuserid varchar(512),
@lastmaintdate datetime,
@requestobject varchar(MAX)

AS

BEGIN

DECLARE @rowExists int
SET @rowExists = 0

--Check if the messageid exists. If it does then update else insert

select @rowExists = count(messageid)
from WK_InboundServiceRequestObjects
where messageid = @messageId

IF @rowExists > 0
  BEGIN   
    UPDATE  WK_InboundServiceRequestObjects
    SET     lastuserid = @lastuserid, 
            lastmaintdate = @lastmaintdate,
            requestobject = @requestobject
    WHERE   messageid = @messageId
  END

IF @rowExists = 0
  BEGIN
    INSERT INTO dbo.WK_InboundServiceRequestObjects
      ( 
        messageid,
        createDate,
        lastuserid,
        lastmaintdate,
        requestobject                                   
      ) 
    VALUES 
      ( 
        @messageId,
        @createdate,
        @lastuserid ,
        @lastmaintdate,
        @requestobject                                
      ) 
  END

END