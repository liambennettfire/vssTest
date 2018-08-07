if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_bookcategories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_bookcategories 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_bookcategories
 (@i_to_bookkey           integer,
  @i_from_bookkey         integer,
  @i_categorycode_list    varchar(4000),
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_bookcategories
**  Desc: Copies bookcategory rows from one title to another, avoiding duplicates.
**        @i_categorycode_list is a comma delimited list
**
**  Auth: Colman
**  Date: 07/20/2017
**  Case: 43941
************************************************************************************************
**  Change History
************************************************************************************************
**  Date:       Author:   Case:  Description:
**  ----------  --------  -----  ---------------------------------------------------------------
**
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_categorycode INT, 
  @v_sortorder INT,
  @v_sortorder_varchar VARCHAR(20), 
  @v_categorydesc VARCHAR(255),
  @v_historyorder INT,
  @v_categorytableid INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_historyorder = 0
  SET @v_categorytableid = 317
  SET @v_sortorder = 0
  
  SELECT @v_sortorder = ISNULL(MAX(sortorder), 0) FROM bookcategory WHERE bookkey = @i_to_bookkey
  
  WHILE LEN(@i_categorycode_list) > 0
  BEGIN
    SET @v_categorycode = CONVERT(INT, LEFT(@i_categorycode_list, CHARINDEX(',', @i_categorycode_list + ',') - 1))

    IF NOT EXISTS (
      SELECT 1 FROM bookcategory 
      WHERE bookkey = @i_to_bookkey 
        AND categorycode = @v_categorycode)
    BEGIN
      SET @v_sortorder = @v_sortorder + 1
      INSERT INTO bookcategory 
        (bookkey, categorycode, sortorder, lastuserid, lastmaintdate)
      VALUES
        (@i_to_bookkey, @v_categorycode, @v_sortorder, @i_userid, getdate())
    END
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy bookcategory: bookkey' + cast(@i_from_bookkey AS VARCHAR)
      RETURN
    END
    
    -- Update title history
    SET @v_categorydesc = NULL
    
    SELECT @v_categorydesc = RTRIM(datadesc) FROM gentables WHERE tableid = @v_categorytableid AND datacode = @v_categorycode
    SET @v_sortorder_varchar = CAST(@v_sortorder as VARCHAR)
    SET @v_historyorder = @v_historyorder + 1
    
    EXEC qtitle_update_titlehistory 'bookcategory', 'categorycode', @i_to_bookkey, 1, NULL, @v_categorydesc, 'insert', @i_userid, @v_historyorder, @v_categorydesc, @o_error_code OUTPUT, @o_error_desc OUTPUT
    EXEC qtitle_update_titlehistory 'bookcategory', 'sortorder', @i_to_bookkey, 1, NULL, @v_sortorder_varchar, 'insert', @i_userid, @v_historyorder, @v_categorydesc, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    -- Next row
    SET @i_categorycode_list = STUFF(@i_categorycode_list, 1, CHARINDEX(',', @i_categorycode_list + ','), '')
  END
  
-- Propagate changes
  EXECUTE qtitle_copy_work_info @i_to_bookkey, 'bookcategory', 'categorycode', @o_error_code OUTPUT, @o_error_desc OUTPUT
  IF @o_error_code = 0
    EXECUTE qtitle_copy_work_info @i_to_bookkey, 'bookcategory', 'sortorder', @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  IF @o_error_code <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to propagate booksubjectcategory: ' + @o_error_desc
    RETURN
  END
END
GO

GRANT EXEC ON qtitle_copy_bookcategories TO PUBLIC
GO