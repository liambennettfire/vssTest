if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_decimalvalue') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_decimalvalue
GO

CREATE FUNCTION get_decimalvalue
    (@i_taqversionformatyearkey as integer, @i_qsicode as integer) 

RETURNS NUMERIC(15,4)

/******************************************************************************
**  Name: get_decimalvalue
**  Desc: This function returns the decimalvalue
**
**	Auth: Kusum Basra
**	Date: 26 March 2012
*******************************************************************************
**	Change History
*******************************************************************************
**	Date:       Author:         Description:
**	--------    --------        -------------------------------------------
**    
*******************************************************************************/
BEGIN
  DECLARE
    @v_decimalvalue NUMERIC(15,4)

  SET @v_decimalvalue = 0
  
  --IF @i_qsicode = 7 BEGIN	--Spine Size
    --SET @v_decimalvalue = 1.125	--hardcoded for testing usefunctionfordecimalind (for Spine Size)
  --END
  
  RETURN @v_decimalvalue
   
END
GO

GRANT EXEC ON dbo.get_decimalvalue TO public
GO
