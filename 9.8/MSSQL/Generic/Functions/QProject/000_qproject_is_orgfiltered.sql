if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_is_orgfiltered') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_is_orgfiltered
GO

CREATE FUNCTION dbo.qproject_is_orgfiltered
(
  @i_projectkey   integer,
  @i_orglevel     integer,
  @i_orgentry     integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_is_orgfiltered
**  Desc: If the projectkey is filtered in at the passed orglevel or above, 
**        returns the filtered orglevel (<= @i_orglevel).
**        Returns 0 if the project has an orgentry with orglevel > i_orglevel.
**
**  Auth: Colman
**  Date: June 24, 2016
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_result INT,
    @v_count INT
    
  SET @v_result = 0
  SET @v_count = 0
  
  IF @i_orglevel > 0
  BEGIN
    WHILE @i_orglevel > 0 AND @i_orgentry > 0
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqproject tp
      WHERE tp.taqprojectkey = @i_projectkey
        AND EXISTS (SELECT * FROM taqprojectorgentry oea WHERE oea.taqprojectkey = @i_projectkey AND oea.orglevelkey = @i_orglevel AND oea.orgentrykey = @i_orgentry)
        AND NOT EXISTS (SELECT * FROM taqprojectorgentry oea WHERE oea.taqprojectkey = @i_projectkey AND oea.orglevelkey > @i_orglevel)

      IF @v_count > 0 OR @i_orglevel = 1
        BREAK
        
      SELECT @i_orgentry = COALESCE(orgentryparentkey,0) FROM orgentry WHERE orglevelkey = @i_orglevel AND orgentrykey = @i_orgentry
      SET @i_orglevel = @i_orglevel - 1
    END
  END
	
  IF @v_count > 0
    SET @v_result = @i_orglevel
  
  RETURN @v_result
  
END
GO

GRANT EXEC ON dbo.qproject_is_orgfiltered TO public
GO
