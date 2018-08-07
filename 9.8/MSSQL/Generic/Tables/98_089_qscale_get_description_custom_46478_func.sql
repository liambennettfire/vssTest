if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_description_custom') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_description_custom
GO

CREATE FUNCTION get_description_custom
    (@i_taqversionformatyearkey as integer, @i_qsicode as integer) 

RETURNS VARCHAR(4000)

/******************************************************************************
**  Name: get_description_custom
**  Desc: Stub function called by get_description_custom
*******************************************************************************/
  
BEGIN
  DECLARE
    @v_desc VARCHAR(4000)

  SET @v_desc = ''
  
  RETURN @v_desc   
END
GO

GRANT EXEC ON dbo.get_description_custom TO public
GO
