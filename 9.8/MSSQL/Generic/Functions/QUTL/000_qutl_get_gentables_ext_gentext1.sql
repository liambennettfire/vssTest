SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'fn' and name = 'qutl_get_gentables_ext_gentext1' ) 
drop function qutl_get_gentables_ext_gentext1
go

CREATE FUNCTION [dbo].[qutl_get_gentables_ext_gentext1]
    ( @i_tableid as integer, @i_datacode as integer) 

RETURNS varchar(255)

/***********************************************************************************
**  File: 
**  Name: qutl_get_gentables_ext_gentext1
**  Desc: This function returns the gentables_ext gentext1.
**        NULL will be returned if gentext1 is not found.      
**
**    Auth: Uday A. Khisty
**    Date: 8 March 2016
************************************************************************************
**    Change History
************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
************************************************************************************/

BEGIN 
  DECLARE @RETURN varchar(255)


  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode= 0
      RETURN NULL
  
  
   SELECT @RETURN = gentext1 FROM gentables_ext
		  WHERE tableid = @i_tableid AND datacode = @i_datacode		 
   
RETURN @RETURN

END

GO

GRANT EXEC ON dbo.qutl_get_gentables_ext_gentext1 TO public
GO
