IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qtitle_copy_booksubjectcategories') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_booksubjectcategories 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_booksubjectcategories
 (@i_to_bookkey           integer,
  @i_from_bookkey         integer,
  @i_subjectkey_list      VARCHAR(4000),
  @i_userid               VARCHAR(30),
  @o_error_code           integer output,
  @o_error_desc           VARCHAR(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_booksubjectcategories
**  Desc: Copies booksubjectcategories FROM one title to another, avoiding duplicates.
**        @i_subjectkey_list is a comma delimited list. If NULL, all subjectkeys are copied.
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
  @v_subjectkey INT,
  @v_subjectkey_new INT,
  @v_categorytableid INT, 
  @v_categorycode INT, 
  @v_categorysubcode INT, 
  @v_sortorder INT, 
  @v_sortorder_varchar VARCHAR(20), 
  @v_nextsortorder INT,
  @v_categorysub2code INT,
  @v_categorydesc VARCHAR(255),
  @v_categorysubdesc VARCHAR(255),
  @v_categorysub2desc VARCHAR(255),
  @v_fielddetail VARCHAR(255),
  @v_historyorder INT,
  @v_sql NVARCHAR(4000)
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_historyorder = 0

  DECLARE @v_table TABLE (
    subjectkey INT, 
    categorytableid INT, 
    categorycode INT, 
    categorysubcode INT, 
    sortorder INT, 
    categorysub2code INT)
  
  SET @v_sql = 
  'SELECT catfrom.subjectkey, catfrom.categorytableid, catfrom.categorycode, catfrom.categorysubcode, catfrom.sortorder, catfrom.categorysub2code
  FROM booksubjectcategory catfrom 
    LEFT JOIN booksubjectcategory catto 
    ON catto.bookkey = ' + CONVERT(VARCHAR, @i_to_bookkey) +
    ' AND catto.categorytableid = catfrom.categorytableid 
    AND ISNULL(catto.categorycode,0) = ISNULL(catfrom.categorycode,0)
    AND ISNULL(catto.categorysubcode,0) = ISNULL(catfrom.categorysubcode,0)
    AND ISNULL(catto.categorysub2code,0) = ISNULL(catfrom.categorysub2code,0)
  WHERE catfrom.bookkey = ' + CONVERT(VARCHAR, @i_from_bookkey) +
    ' AND catto.subjectkey IS NULL'

  IF ISNULL(@i_subjectkey_list, '') <> ''
    SET @v_sql = @v_sql + ' AND catfrom.subjectkey IN (' + @i_subjectkey_list + ')'

  SET @v_sql = @v_sql + ' ORDER BY catfrom.sortorder'

  INSERT INTO @v_table
  EXEC sp_executesql @v_sql, N'@i_to_bookkey INT, @i_from_bookkey INT, @i_subjectkey_list VARCHAR(4000)',  
     @i_to_bookkey, @i_from_bookkey, @i_subjectkey_list

  DECLARE cat_cur CURSOR FOR
    SELECT subjectkey, categorytableid, categorycode, categorysubcode, sortorder, categorysub2code
    FROM @v_table

  OPEN cat_cur
  FETCH cat_cur INTO
    @v_subjectkey, @v_categorytableid, @v_categorycode, @v_categorysubcode, @v_sortorder, @v_categorysub2code

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    EXEC get_next_key @i_userid, @v_subjectkey_new OUTPUT
    SELECT @v_nextsortorder = ISNULL(MAX(sortorder), 0) + 1 FROM booksubjectcategory WHERE bookkey = @i_to_bookkey AND categorytableid = @v_categorytableid

    INSERT INTO booksubjectcategory 
      (bookkey, subjectkey, categorytableid, categorycode, categorysubcode, sortorder, lastuserid, lastmaintdate, categorysub2code)
    VALUES
      (@i_to_bookkey, @v_subjectkey_new, @v_categorytableid, @v_categorycode, @v_categorysubcode, @v_nextsortorder, @i_userid, getdate(), @v_categorysub2code)

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy booksubjectcategory: bookkey' + cast(@i_from_bookkey AS VARCHAR) + 
        'subjectkey=' + cast(@v_subjectkey as VARCHAR) + '.'
      CLOSE cat_cur
      DEALLOCATE cat_cur
      RETURN
    END

    -- Update title history
    SET @v_categorydesc = NULL
    SET @v_categorysubdesc = NULL
    SET @v_categorysub2desc = NULL
    SET @v_fielddetail = NULL
    
    SELECT @v_categorydesc = RTRIM(datadesc) FROM gentables WHERE tableid = @v_categorytableid AND datacode = @v_categorycode
    SELECT @v_categorysubdesc = RTRIM(datadesc) FROM subgentables WHERE tableid = @v_categorytableid AND datacode=@v_categorycode AND datasubcode = @v_categorysubcode
    SELECT @v_categorysub2desc = RTRIM(datadesc) FROM sub2gentables WHERE tableid = @v_categorytableid AND datacode=@v_categorycode AND datasubcode = @v_categorysubcode AND datasub2code = @v_categorysub2code
    SET @v_historyorder = @v_historyorder + 1
    SET @v_sortorder_varchar = CAST(@v_nextsortorder as VARCHAR)
    
    IF @v_categorydesc IS NOT NULL
    BEGIN
      SET @v_fielddetail = @v_categorydesc
      IF @v_categorysubdesc IS NOT NULL
        SET @v_fielddetail = @v_fielddetail + ' - ' + @v_categorysubdesc
      IF @v_categorysub2desc IS NOT NULL
        SET @v_fielddetail = @v_fielddetail + ' - ' + @v_categorysub2desc
    END
    
    EXEC qtitle_update_titlehistory 'booksubjectcategory', 'categorycode', @i_to_bookkey, 1, NULL, @v_categorydesc, 'insert', @i_userid, @v_historyorder, @v_fielddetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
    EXEC qtitle_update_titlehistory 'booksubjectcategory', 'categorysubcode', @i_to_bookkey, 1, NULL, @v_categorysubdesc, 'insert', @i_userid, @v_historyorder, @v_fielddetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
    EXEC qtitle_update_titlehistory 'booksubjectcategory', 'categorysub2code', @i_to_bookkey, 1, NULL, @v_categorysub2desc, 'insert', @i_userid, @v_historyorder, @v_fielddetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
    EXEC qtitle_update_titlehistory 'booksubjectcategory', 'sortorder', @i_to_bookkey, 1, NULL, @v_sortorder_varchar, 'insert', @i_userid, @v_historyorder, @v_fielddetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    -- Next row
    FETCH cat_cur INTO
      @v_subjectkey, @v_categorytableid, @v_categorycode, @v_categorysubcode, @v_sortorder, @v_categorysub2code
  END

  CLOSE cat_cur
  DEALLOCATE cat_cur

-- Propagate changes
  EXECUTE qtitle_copy_work_info @i_to_bookkey, 'booksubjectcategory', 'categorycode', @o_error_code OUTPUT, @o_error_desc OUTPUT
  IF @o_error_code = 0
    EXECUTE qtitle_copy_work_info @i_to_bookkey, 'booksubjectcategory', 'categorysubcode', @o_error_code OUTPUT, @o_error_desc OUTPUT
  IF @o_error_code = 0
    EXECUTE qtitle_copy_work_info @i_to_bookkey, 'booksubjectcategory', 'categorysub2code', @o_error_code OUTPUT, @o_error_desc OUTPUT
  IF @o_error_code = 0
    EXECUTE qtitle_copy_work_info @i_to_bookkey, 'booksubjectcategory', 'sortorder', @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  IF @o_error_code <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to propagate booksubjectcategory: ' + @o_error_desc
    RETURN
  END
END

GO

GRANT EXEC ON qtitle_copy_booksubjectcategories TO PUBLIC
GO
