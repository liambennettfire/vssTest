SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_gentables_datacode' ) 
drop function qutl_get_gentables_datacode
go

CREATE FUNCTION [dbo].[qutl_get_gentables_datacode]
    ( @i_tableid as integer, @i_qsicode as integer ,@i_datadesc as varchar(40)) 

RETURNS integer

/***********************************************************************************
**  File: 
**  Name: qutl_get_gentables_datacode
**  Desc: This function returns the gentables datacode based on qsicode or datadesc.
**        It will try to match on qsicode first; if that fails, it will match on 
**        datadesc.  0 will be returned if datacode is not found.      
**
**    Auth: SLB
**    Date: 10JAN2015
************************************************************************************
**    Change History
************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
************************************************************************************/

BEGIN 
  DECLARE @RETURN				integer


  IF ((@i_tableid is null OR @i_tableid <= 0) OR
     ((@i_qsicode is null OR @i_qsicode= 0)AND (@i_datadesc is NULL)))
      RETURN 0
  
  IF @i_qsicode IS NOT NULL AND @i_qsicode <> 0
      SELECT TOP 1 @RETURN = datacode FROM gentables
		  WHERE (tableid = @i_tableid AND qsicode = @i_qsicode)
		  
  IF  @RETURN = 0 OR @RETURN is NULL
   	  SELECT TOP 1 @RETURN = datacode  FROM gentables
       WHERE (tableid = @i_tableid AND LOWER(datadesc) = @i_datadesc) 
       
 IF @RETURN is NULL
   SET @RETURN = 0
   
RETURN @RETURN

END

GO


