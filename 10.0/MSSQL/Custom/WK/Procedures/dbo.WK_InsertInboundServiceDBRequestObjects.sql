if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_InsertInboundServiceDBRequestObjects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_InsertInboundServiceDBRequestObjects
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[WK_InsertInboundServiceDBRequestObjects]
@messageId varchar(512),
@createdate datetime,
@lastuserid varchar(512),
@lastmaintdate datetime,
@dbchangequestobject varchar(MAX)

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
    UPDATE  dbo.wk_inboundservicedbchangerequestobjects
    SET     lastuserid = @lastuserid, 
            lastmaintdate = @lastmaintdate,
            dbchangequestobject = @dbchangequestobject
    WHERE   messageid = @messageId
  END

IF @rowExists = 0
  BEGIN
    INSERT INTO dbo.wk_inboundservicedbchangerequestobjects
      ( 
        messageid,
        createDate,
        lastuserid,
        lastmaintdate,
        dbchangequestobject                                   
      ) 
    VALUES 
      ( 
        @messageId,
        @createdate,
        @lastuserid ,
        @lastmaintdate,
        @dbchangequestobject                                
      ) 
  END

END