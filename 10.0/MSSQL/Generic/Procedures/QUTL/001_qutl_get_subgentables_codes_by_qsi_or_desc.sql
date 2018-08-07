
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_get_subgentables_datacodes' ) 
drop procedure qutl_get_subgentables_datacodes
go


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_get_subgentables_codes_by_qsi_or_desc' ) 
drop procedure qutl_get_subgentables_codes_by_qsi_or_desc
go

CREATE PROCEDURE [dbo].[qutl_get_subgentables_codes_by_qsi_or_desc]
 (@i_tableid				integer,
  @i_qsicode				integer,
  @i_datadesc				varchar(40),
  @i_subqsicode				integer,
  @i_subdatadesc			varchar(40),
  @o_datacode	   		    integer output,
  @o_datasubcode			integer output,
  @o_error_code				integer output,
  @o_error_desc				varchar(2000) output)
 AS

/***********************************************************************************************
**  Name: qutl_get_subgentables_codes_by_qsi_or_desc
**  Desc: This stored procedure finds datacode and datasubcode based on qsicodes if they exist;
**        datadescs if they don't.  If none found, zeros are returned 
**    Auth: SLB
**    Date: 25 July 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
	--If subgentables qsicode exists, go straight to subgentables to find values  
    IF @i_subqsicode IS NOT NULL AND @i_subqsicode <> 0   BEGIN
       SELECT TOP 1 @o_datacode = datacode, @o_datasubcode = datasubcode FROM subgentables
		  WHERE (tableid = @i_tableid AND qsicode = @i_subqsicode)--Find Gentables datacode
		RETURN
		END
	
   -- get datacode from function by either qsicode or datadesc	
   exec @o_datacode = qutl_get_gentables_datacode @i_tableid, @i_qsicode, @i_datadesc
   IF @o_datacode = 0  BEGIN -- No Datacode Found 
      SET @o_datasubcode = 0
      SET @o_error_code = -1
      SET @i_qsicode = COALESCE (@i_qsicode, 0)
      SET @i_datadesc = COALESCE (@i_datadesc, ' ')
      SET @o_error_desc = 'Datacode not Found for qsicode = ' + CAST(@i_qsicode AS VARCHAR) + 
						' AND datadesc =' + @i_datadesc   
      RETURN 
      END  

   --- Get datasubcode based on datacode and sub data desc
   SELECT TOP 1 @o_datasubcode = datasubcode  FROM subgentables
       WHERE (tableid = @i_tableid  AND datacode = @o_datacode AND LOWER(datadesc) = @i_subdatadesc) 
   
   IF @o_datasubcode is NULL
       SET @o_datasubcode = 0

   IF @o_datasubcode = 0  BEGIN -- No Datasubcode Found 
      SET @o_error_code = -1
      SET @i_qsicode = COALESCE (@i_qsicode, 0)
      SET @i_datadesc = COALESCE (@i_datadesc, ' ')
      SET @o_error_desc = 'Datasubcode not Found for qsicode = ' + CAST(@i_qsicode AS VARCHAR) + 
						' AND datadesc =' + @i_datadesc    
      RETURN 
      END  
    
END

GO

GRANT EXEC ON qutl_get_subgentables_codes_by_qsi_or_desc TO PUBLIC
GO



