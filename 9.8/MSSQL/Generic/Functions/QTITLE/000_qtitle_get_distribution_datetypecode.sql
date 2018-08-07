if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_distribution_datetypecode') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.get_distribution_datetypecode
GO

CREATE FUNCTION dbo.get_distribution_datetypecode
(
  @i_qsicode as integer
) 
RETURNS integer

/******************************************************************************
**  Name: get_distribution_datetypecode
**  Desc: This function returns the datetypecode for 'Distribute Asset'
**        based on the qsicode
**  Author: Kusum Basra
**  Date: 28 March 2011
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count      INT,
    @v_datetypecode INT
    
  SELECT @v_count = COUNT(*)
    FROM datetype
   WHERE qsicode = @i_qsicode
    
  
  IF @v_count = 0 BEGIN
    RETURN 0
  END

  SELECT @v_datetypecode = datetypecode
    FROM datetype
   WHERE qsicode = @i_qsicode
    
  
  RETURN @v_datetypecode
END
GO

GRANT EXEC ON dbo.get_distribution_datetypecode TO public
GO
