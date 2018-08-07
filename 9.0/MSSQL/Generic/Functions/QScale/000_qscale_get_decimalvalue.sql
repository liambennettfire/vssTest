if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_decimalvalue') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_decimalvalue
GO

CREATE FUNCTION get_decimalvalue
    (@i_taqversionformatyearkey as integer,@i_qsicode as integer) 

RETURNS NUMERIC(15,4)


/******************************************************************************
**  File: 
**  Name: get_itemdetailcode
**  Desc: This function returns the decimalvalue
**         
**
**    Auth: Kusum Basra
**    Date: 26 March 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_decimalvalue NUMERIC(15,4)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  

  SET @v_decimalvalue = 0
  
  RETURN @v_decimalvalue
   
END
GO

GRANT EXEC ON dbo.get_decimalvalue TO public
GO
