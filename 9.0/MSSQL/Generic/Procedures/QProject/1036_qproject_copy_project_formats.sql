IF EXISTS (SELECT *
             FROM sys.objects
             WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_formats]')
               AND type IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qproject_copy_project_formats]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_formats]    Script Date: 07/16/2008 10:31:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_formats]
(
  @i_copy_projectkey INTEGER,
  @i_copy2_projectkey INTEGER,
  @i_new_projectkey INTEGER,
  @i_userid VARCHAR(30),
  @i_cleardatagroups_list VARCHAR(MAX),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
**  Name: [qproject_copy_project_formats]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************/

DECLARE 
  @error_var                    INT,
  @rowcount_var                 INT,
  @newkey                       INT,
  @v_cursor_taqprojectformatkey INT,
  @v_maxsort  int,
  @v_sortorder  int
        
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy project key not passed to copy formats (' + cast(
      @error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS
      VARCHAR)
      RETURN
    END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'new project key not passed to copy formats (' + cast(@error_var
      AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)
      RETURN
    END

  DECLARE taqProjectTitleCursor CURSOR FOR
    SELECT taqprojectformatkey, MAX(sortorder)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey AND titlerolecode = 2
    GROUP BY taqprojectformatkey
    ORDER BY taqprojectformatkey ASC

  OPEN taqProjectTitleCursor

  FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_maxsort

  WHILE (@@FETCH_STATUS = 0)
  BEGIN

    EXEC get_next_key @i_userid, @newkey OUTPUT

    INSERT INTO taqprojecttitle
      (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
      discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
      projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, 
      relateditem2name, relateditem2status, relateditem2participants, lastuserid, lastmaintdate, decimal1, decimal2)
    SELECT @newkey, @i_new_projectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
      discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
      projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, 
      relateditem2name, relateditem2status, relateditem2participants, @i_userid, getdate(), decimal1, decimal2
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey
      AND taqprojectformatkey = @v_cursor_taqprojectformatkey
      AND titlerolecode = 2

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy/insert into taqprojecttitle failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)
      CLOSE taqProjectTitleCursor
      DEALLOCATE taqProjectTitleCursor
      RETURN
    END
    
    FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey, @v_maxsort
  END

  CLOSE taqProjectTitleCursor
  DEALLOCATE taqProjectTitleCursor

  /* 4/30/12 - KW - From case 17842:
  Project Format (4): copy from i_copy_projectkey; add non-existing project formats from i_copy2_projectkey */
  IF @i_copy2_projectkey > 0
  BEGIN
    DECLARE taqProjectTitleCursor CURSOR FOR
      SELECT t1.taqprojectformatkey
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND t1.titlerolecode = 2 AND
         NOT EXISTS (SELECT * FROM taqprojecttitle t2 
                     WHERE t1.mediatypecode = t2.mediatypecode AND t1.mediatypesubcode = t2.mediatypesubcode AND t2.taqprojectkey = @i_copy_projectkey)
      ORDER BY taqprojectformatkey ASC     

    OPEN taqProjectTitleCursor

    SET @v_sortorder = @v_maxsort + 1

    FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey

    WHILE (@@FETCH_STATUS = 0)
    BEGIN

      EXEC get_next_key @i_userid, @newkey OUTPUT

      INSERT INTO taqprojecttitle
        (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
        projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2, quantity1, quantity2, 
        relateditem2name, relateditem2status, relateditem2participants, lastuserid, lastmaintdate, decimal1, decimal2)
      SELECT @newkey, @i_new_projectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind, taqprojectformatdesc, 
        projectrolecode, titlerolecode, keyind, @v_sortorder, indicator1, indicator2, quantity1, quantity2, 
        relateditem2name, relateditem2status, relateditem2participants, @i_userid, getdate(), decimal1, decimal2
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy2_projectkey
        AND taqprojectformatkey = @v_cursor_taqprojectformatkey
        AND titlerolecode = 2

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'copy/insert into taqprojecttitle failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)
        CLOSE taqProjectTitleCursor
        DEALLOCATE taqProjectTitleCursor
        RETURN
      END
      
      SET @v_sortorder = @v_sortorder + 1
      
      FETCH taqProjectTitleCursor INTO @v_cursor_taqprojectformatkey
    END

    CLOSE taqProjectTitleCursor
    DEALLOCATE taqProjectTitleCursor
  END

END
go
