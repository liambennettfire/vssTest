if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_description') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_description
GO

CREATE FUNCTION get_description
    (@i_taqversionformatyearkey as integer, @i_qsicode as integer) 

RETURNS VARCHAR(4000)

/******************************************************************************
**  Name: get_description
**  Desc: This function returns the description
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
  DECLARE
    @v_desc VARCHAR(4000)

  SET @v_desc = ''
  
  --IF @i_qsicode = 7 BEGIN	--Spine Size
  --  SET @v_desc = '1 1/16"'	--hardcoded for testing usefunctionfordescind (for Spine Size)
  --END
  
  RETURN @v_desc
   
END
GO

GRANT EXEC ON dbo.get_description TO public
GO
