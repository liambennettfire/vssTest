if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getDatacodeDatasubcodeForPrimaryMarketID') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getDatacodeDatasubcodeForPrimaryMarketID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WK_getDatacodeDatasubcodeForPrimaryMarketID]
@MarketID int
AS

DECLARE @tableID int
DECLARE @datacode int
DECLARE @datasubcode int
DECLARE @gentablesdesc varchar(512)
DECLARE @subgentablesdesc varchar(512)

SET @tableID = -1
SET @datacode = -1
SET @datasubcode = -1
SET @gentablesdesc = ''
SET @subgentablesdesc = ''

BEGIN

SELECT @tableID = sg.tableid, 
       @datacode = sg.datacode, 
       @datasubcode = sg.datasubcode,
       @gentablesdesc = [dbo].[rpt_get_gentables_desc]( sg.tableid, sg.datacode, '1' ),
       @subgentablesdesc = [dbo].[rpt_get_subgentables_desc]( sg.tableid, sg.datacode, sg.datasubcode, '1' )
FROM subgentables sg
WHERE   tableid = 433
    and externalcode in 
    (  select datadescshort as externalcode from gentables where tableid = 414 and datacode = @MarketID  )
END

--IF @tableID = -1
--  BEGIN
--    if exists( SELECT sg.datacode FROM subgentables sg WHERE   tableid = 433 and datacode = @MarketID  )
--        BEGIN    
--            SELECT  @tableID = sg.tableid, 
--                    @datacode = sg.datacode, 
--                    @datasubcode = sg.datasubcode,
--                    @gentablesdesc = [dbo].[rpt_get_gentables_desc]( sg.tableid, sg.datacode, '1' ),
--                    @subgentablesdesc = [dbo].[rpt_get_subgentables_desc]( sg.tableid, sg.datacode, sg.datasubcode, '1' )
--            FROM subgentables sg
--            WHERE   tableid = 433 and datasubcode = @MarketID   
--        END
--  END

IF @tableID = -1
  BEGIN
    -- if we still have -1's then set it all to null and return.
    SET @tableID = null
    SET @datacode = null
    SET @datasubcode = null
    SET @gentablesdesc = null
    SET @subgentablesdesc = null 
  END

    SELECT @tableID as tableID, @datacode as datacode, @datasubcode as datasubcode, @gentablesdesc as gentablesdesc, @subgentablesdesc as subgentablesdesc

GRANT EXEC ON WK_getDatacodeDatasubcodeForPrimaryMarketID TO PUBLIC
