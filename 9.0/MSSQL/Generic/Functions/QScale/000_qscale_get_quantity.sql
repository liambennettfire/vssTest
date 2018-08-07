if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_quantity') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_quantity
GO

CREATE FUNCTION get_quantity
    (@i_taqversionformatyearkey as integer,@i_qsicode as integer) 

RETURNS INT

/******************************************************************************
**  File: 
**  Name: get_quantity
**  Desc: This function returns the quantity
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
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @v_selectqtysql VARCHAR(4000)
  DECLARE @v_sql        VARCHAR(4000)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_quantity   INT

  SET @v_quantity = 0

  IF @i_qsicode = 6 BEGIN
    SELECT @v_quantity = quantity 
     FROM taqversionformatyear
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey
  END
	  
  RETURN @v_quantity
 
END
GO

GRANT EXEC ON dbo.get_quantity TO public
GO
