if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_journal') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_journal
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qproject_get_journal()
RETURNS @journalinfo TABLE(
	journalkey INT,
	templateind INT
)
AS
BEGIN

  DECLARE @v_journalkey integer,
          @v_itemtypecode integer,
          @v_usageclasscode integer,
          @v_templateind integer
          
  -- get usageclass and itemtype based on qsicode
  SELECT @v_itemtypecode = datacode,
         @v_usageclasscode = datasubcode
    FROM subgentables
   WHERE tableid = 550
     AND qsicode = 4  -- journal
     
  IF @v_itemtypecode > 0 AND @v_usageclasscode > 0 BEGIN
    DECLARE temp_cur CURSOR fast_forward FOR
     SELECT taqprojectkey,COALESCE(templateind,0)
       FROM taqproject
      WHERE searchitemcode = @v_itemtypecode
        AND usageclasscode = @v_usageclasscode

    OPEN temp_cur

    FETCH from temp_cur INTO @v_journalkey,@v_templateind

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @journalinfo (journalkey,templateind)
      VALUES (@v_journalkey,@v_templateind)
    
      FETCH from temp_cur INTO @v_journalkey,@v_templateind
    END
    
    CLOSE temp_cur
    DEALLOCATE temp_cur
  END    

  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

