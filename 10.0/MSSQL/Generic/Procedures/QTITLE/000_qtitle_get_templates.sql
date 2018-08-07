if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_templates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_templates
GO

CREATE PROCEDURE qtitle_get_templates
 (@i_usageclass     integer,
  @i_orgentrykey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_templates
**  Desc: This stored procedure returns templates for given Title usage class.
**
**  Auth: Kate
**  Date: 6/2/10
*************************************************************************************/

BEGIN

  DECLARE
    @v_error	INT,
    @v_orglevelkey INT,
    @v_orgentrykey INT,
    @v_parent_orgentrykey INT,
    @v_restrictedind  TINYINT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_orgentrykey > 0 BEGIN
    SELECT @v_orglevelkey = orglevelkey, @v_restrictedind = COALESCE(restricttemplatesind,0)
      FROM orgentry
     WHERE orgentrykey = @i_orgentrykey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0  BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not get orglevel from orgentry for orgentrykey ' + cast(@i_orgentrykey as varchar)
    END
    
    IF @v_orglevelkey > 0 BEGIN
      -- need to find templates for orgentrykey and templates at higher levels 
	    CREATE TABLE #TemplateList
	    (
	      projectkey int NOT NULL,
	      projecttitle varchar(4000)
	    )
      
      -- find all the templates for the orgentrykey passed in
      INSERT INTO #TemplateList (projectkey,projecttitle)
      SELECT DISTINCT b.bookkey projectkey, b.title projecttitle
      FROM book b, bookorgentry bo
      WHERE b.bookkey = bo.bookkey And 
        b.standardind = 'Y' AND 
        COALESCE(b.usageclasscode,0) IN (0,@i_usageclass) AND
        bo.orgentrykey = @i_orgentrykey AND
        b.bookkey in (select bookkey from printing where printingkey > 0)
        
      SELECT @v_error = @@ERROR
      IF @v_error <> 0  BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get title templates from book table.'
        DROP TABLE #TemplateList
        RETURN
      END
      
      IF @v_orglevelkey > 1 BEGIN
        -- work backwards from the orglevel for the passed in orgentrykey 
        -- to find templates at higher levels for the parentorgentrykeys
        SET @v_orgentrykey = @i_orgentrykey
        SET @v_orglevelkey = @v_orglevelkey - 1
        
        WHILE @v_orglevelkey >= 1 AND @v_restrictedind = 0 
        BEGIN 
        
          SELECT @v_parent_orgentrykey = orgentryparentkey, 
            @v_restrictedind = (SELECT COALESCE(o.restricttemplatesind,0) FROM orgentry o WHERE o.orgentrykey = orgentry.orgentryparentkey)
          FROM orgentry
          WHERE orgentrykey = @v_orgentrykey

          SELECT @v_error = @@ERROR
          IF @v_error <> 0  BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not get parent orgentrykey from orgentry for orgentrykey ' + cast(@v_orgentrykey as varchar)
            DROP TABLE #TemplateList
            RETURN
          END

          SET @v_orgentrykey = @v_parent_orgentrykey
                   
          IF @v_orgentrykey > 0 BEGIN
            -- find templates defined only up to the parent level 
            INSERT INTO #TemplateList (projectkey,projecttitle)
            SELECT DISTINCT b.bookkey projectkey, b.title projecttitle
            FROM book b, bookorgentry bo
            WHERE b.bookkey = bo.bookkey And 
              b.standardind = 'Y' AND 
              COALESCE(b.usageclasscode,0) IN (0,@i_usageclass) AND
              bo.orgentrykey = @v_orgentrykey AND
              b.bookkey in (select bookkey from printing where printingkey > 0) AND
              b.bookkey in (select bookkey from bookorgentry
                            group by bookkey
                            having count(*) = @v_orglevelkey)

            SELECT @v_error = @@ERROR
            IF @v_error <> 0  BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could not get title templates for orgentrykey ' + cast(@v_orgentrykey as varchar)
              DROP TABLE #TemplateList
              RETURN
            END          
          END

          SET @v_orglevelkey = @v_orglevelkey - 1
        END
      END
       
      SELECT * FROM #TemplateList
      ORDER BY projecttitle
      
      DROP TABLE #TemplateList
    END
  END
  ELSE BEGIN
    SELECT DISTINCT b.bookkey projectkey, b.title projecttitle
    FROM book b
    WHERE b.standardind = 'Y' AND 
      COALESCE(b.usageclasscode,0) IN (0,@i_usageclass) AND
      b.bookkey in (select bookkey from printing where printingkey > 0)
  END
   
  SELECT @v_error = @@ERROR
  IF @v_error <> 0  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get title templates from book table.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_templates TO PUBLIC
GO
