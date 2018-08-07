if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_uomcode') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_uomcode
GO

CREATE FUNCTION get_uomcode
    (@i_taqversionformatyearkey as integer,@i_qsicode as integer) 

RETURNS INT


/******************************************************************************
**  File: 
**  Name: get_itemdetailcode
**  Desc: This function returns the unitofmeasurecode
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
  DECLARE @v_uomcode INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  

  SET @v_uomcode = 0
  
  RETURN @v_uomcode
   
END
GO

GRANT EXEC ON dbo.get_uomcode TO public
GO
