if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_bookkeywords') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_bookkeywords 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_bookkeywords
 (@i_to_bookkey           integer,
  @i_from_bookkey         integer,
  @i_keyword_id_list      varchar(4000),
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_bookkeywords
**  Desc: Copies keywords from one title to another, avoiding duplicates.
**        @i_keyword_id_list is a comma delimited list. If NULL, all subjectkeys are copied.
**
**  Auth: Colman
**  Date: 07/20/2017
**  Case: 43941
************************************************************************************************
**  Change History
************************************************************************************************
**  Date:       Author:   Case:  Description:
**  ----------  --------  -----  ---------------------------------------------------------------
**  09/28/2017  Colman    46642  Title history not written out to when propagating or copying Keywords
************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_id INT, 
  @v_keyword VARCHAR(100), 
  @v_sortorder INT,
  @v_nextsortorder INT,
  @v_sortorder_varchar VARCHAR(20),
  @v_historyorder INT,
  @v_sql NVARCHAR(4000)
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- exec qutl_trace 'qtitle_copy_bookkeywords',
    -- '@i_to_bookkey', @i_to_bookkey, NULL,
    -- '@i_from_bookkey', @i_from_bookkey, NULL,
    -- '@i_keyword_id_list', NULL, @i_keyword_id_list
    
  SET @v_historyorder = 0
  SET @v_nextsortorder = 0
  
  SELECT @v_nextsortorder = ISNULL(MAX(sortorder), 0) FROM bookkeywords WHERE bookkey = @i_to_bookkey
  
  DECLARE @v_table TABLE (
    keyword VARCHAR(500),
    sortorder INT)
    
  SET @v_sql = 
  'SELECT keyword, sortorder
  FROM bookkeywords
  WHERE bookkey = ' + CONVERT(VARCHAR, @i_from_bookkey) +
  '  AND keyword NOT IN (SELECT keyword FROM bookkeywords WHERE bookkey = ' + CONVERT(VARCHAR, @i_to_bookkey) + ') '

  IF ISNULL(@i_keyword_id_list, '') <> ''
    SET @v_sql = @v_sql + '  AND id IN (' + @i_keyword_id_list + ')'

  INSERT INTO @v_table
  EXEC sp_executesql @v_sql, N'@i_to_bookkey INT, @i_from_bookkey INT, @i_keyword_id_list VARCHAR(4000)',  
     @i_to_bookkey, @i_from_bookkey, @i_keyword_id_list

  DECLARE keyword_cur CURSOR FOR
  SELECT keyword, sortorder
  FROM @v_table
  ORDER BY sortorder
      
  OPEN keyword_cur
  FETCH keyword_cur INTO @v_keyword, @v_sortorder

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    SET @v_nextsortorder = @v_nextsortorder + 1

    INSERT INTO bookkeywords 
      (bookkey, keyword, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@i_to_bookkey, @v_keyword, @v_nextsortorder, @i_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Unable to copy bookkeywords: bookkey' + cast(@i_from_bookkey AS VARCHAR)
      CLOSE keyword_cur
      DEALLOCATE keyword_cur
      RETURN
    END

    -- Update title history
    SET @v_historyorder = @v_historyorder + 1
    SET @v_sortorder_varchar = CAST(@v_nextsortorder as varchar)
    EXEC qtitle_update_titlehistory 'bookkeywords', 'keyword', @i_to_bookkey, 1, 0, @v_keyword, 'insert', @i_userid, @v_historyorder, '', @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    FETCH keyword_cur INTO @v_keyword, @v_sortorder
  END

  CLOSE keyword_cur
  DEALLOCATE keyword_cur
  
  -- Update Onix keyword list
  EXEC qtitle_update_Keywords_ONIX @i_to_bookkey, @i_userid, 0, @o_error_code output, @o_error_desc output
  IF @o_error_code <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update ONIX keywords: ' + @o_error_desc
    RETURN
  END

-- Propagate changes
  EXECUTE qtitle_copy_work_info @i_to_bookkey, 'bookkeywords', 'keyword', @o_error_code OUTPUT, @o_error_desc OUTPUT
  IF @o_error_code <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to propagate keywords: ' + @o_error_desc
    RETURN
  END
END

GO

GRANT EXEC ON qtitle_copy_bookkeywords TO PUBLIC
GO