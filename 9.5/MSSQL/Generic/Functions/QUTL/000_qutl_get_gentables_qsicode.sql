SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_gentables_qsicode' ) 
drop function qutl_get_gentables_qsicode
go

CREATE FUNCTION [dbo].[qutl_get_gentables_qsicode]
    ( @i_tableid as integer, @i_datacode as integer,@i_datasubcode as integer, @i_datasub2code as integer) 

RETURNS integer

/***********************************************************************************
**  File: 
**  Name: qutl_get_gentables_qsicode
**  Desc: This function returns the gentables, subgentables or sub2gentables qsicode.
**        0 will be returned if qsicode is not found or NULL.      
**
**    Auth: SLB
**    Date: 5FEB2015
************************************************************************************
**    Change History
************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
************************************************************************************/

BEGIN 
  DECLARE @RETURN				integer


  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode= 0
      RETURN 0
  
  IF @i_datasub2code IS NOT NULL AND @i_datasub2code <>0 AND @i_datasubcode IS NOT NULL AND @i_datasubcode  <> 0 
      SELECT @RETURN = qsicode FROM sub2gentables
		  WHERE tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @i_datasub2code
  ELSE	IF (@i_datasub2code IS NULL or @i_datasub2code = 0) AND @i_datasubcode IS NOT NULL AND @i_datasubcode <> 0	  
      SELECT @RETURN = qsicode FROM subgentables
		  WHERE tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode 
  ELSE	IF (@i_datasub2code IS NULL or @i_datasub2code = 0) AND (@i_datasubcode IS NULL OR @i_datasubcode = 0) AND @i_datacode IS NOT NULL	  
      SELECT @RETURN = qsicode FROM gentables
		  WHERE tableid = @i_tableid AND datacode = @i_datacode  
		         
 IF @RETURN is NULL
   SET @RETURN = 0
   
RETURN @RETURN

END

GO


