SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_misckey' ) 
drop function qutl_get_misckey
go

CREATE FUNCTION [dbo].[qutl_get_misckey]
    ( @i_qsicode as integer, @i_firedistkey as integer ,@i_miscname as varchar(40)) 

RETURNS integer

/**************************************************************************************
**  File: 
**  Name: qutl_get_misckey
**  Desc: This function returns the misckey based on qsicode, firedistkey  or datadesc.
**        It will try to match on qsicode first; if that fails, it will match on 
**        datadesc.  0 will be returned if misckey is not found.      
**
**    Auth: SLB
**    Date: 10JAN2015
****************************************************************************************
**    Change History
****************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
****************************************************************************************/

BEGIN 
  DECLARE @RETURN				integer


  IF ((@i_qsicode is null OR @i_qsicode <= 0) AND
     ((@i_firedistkey is null OR @i_firedistkey <= 0)AND (@i_miscname is NULL)))
      RETURN 0
  
  IF @i_qsicode IS NOT NULL AND @i_qsicode <> 0
      SELECT TOP 1 @RETURN = misckey FROM bookmiscitems
		  WHERE (qsicode = @i_qsicode)
		  
  IF  (@RETURN = 0 OR @RETURN is NULL)and @i_firedistkey IS NOT NULL
   	  SELECT TOP 1 @RETURN= misckey FROM bookmiscitems
		  WHERE (firedistkey = @i_firedistkey)		  
  ELSE
   	  SELECT TOP 1 @RETURN= misckey FROM bookmiscitems
		  WHERE (LOWER(miscname) = LOWER(@i_miscname)) 
       
 IF @RETURN is NULL
   SET @RETURN = 0
   
RETURN @RETURN

END

GO


