SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_datetypecode' ) 
drop function qutl_get_datetypecode
go

CREATE FUNCTION [dbo].[qutl_get_datetypecode]
    ( @i_qsicode as integer,@i_datedescription as varchar(40)) 

RETURNS integer

/**************************************************************************************
**  File: 
**  Name: qutl_get_datetypecode
**  Desc: This function returns the datetypecode based on qsicode or datadesc.
**        It will try to match on qsicode first; if that fails, it will match on 
**        description.  0 will be returned if datetypecode is not found.      
**
**    Auth: SLB
**    Date: 10JJUL2015
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
     (@i_datedescription is NULL))
      RETURN 0
  
  IF @i_qsicode IS NOT NULL AND @i_qsicode <> 0
      SELECT TOP 1 @RETURN = datetypecode FROM datetype
		  WHERE (qsicode = @i_qsicode)
  ELSE
   	  SELECT TOP 1 @RETURN= datetypecode FROM datetype
		  WHERE (LOWER(description) = LOWER(@i_datedescription)) 
       
 IF @RETURN is NULL
   SET @RETURN = 0
   
RETURN @RETURN

END

GO


