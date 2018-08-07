IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_copy_project_comp_titles') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_copy_project_comp_titles
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_comp_titles] (
  @i_copy_projectkey INTEGER,
  @i_new_titlebookkey INTEGER,
  @i_userid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

/***************************************************************************************
**  Name: qproject_copy_project_comp_titles
**  Desc: This stored procedure copies competitive and comparative titles from project
**        taqprojecttitles table to associatedttitles at the title level during a
**        transmittotmm scenario. **
**
**  Auth: Jon Hess
**  Date: 12/09/2012
**  Case: 14197 originally
**
**  1/7/13 - KW - rewritten to allow for any associatedtitles tabs to be transferred
**  (not only Comparative/Competitive titles)
****************************************************************************************/

DECLARE 
  @v_assotype INT,
  @v_assosubtype  INT,
  @v_authorkey	INT,
  @v_bookkey  INT,
  @v_commentkey1  INT,
  @v_commentkey2  INT,
  @v_elotabind  TINYINT,  
  @v_error	INT,
  @v_new_commentkey1  INT,
  @v_new_commentkey2  INT,
  @v_ProductIdType	INT,
  @v_rowcount INT,
  @v_sortorder INT,
  @v_taqprojectformatkey  INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  PRINT 'BEGIN qproject_copy_project_comp_titles'

  --Cursor to obtain all associated title tab rows stored on taqprojecttitle
  DECLARE assotitles_cur CURSOR FOR
    SELECT p.taqprojectformatkey, p.bookkey, p.associationtypecode, p.associationtypesubcode, 
    COALESCE(g.gen1ind, 0) elotabind, COALESCE(p.commentkey1, 0) AS commentkey1, COALESCE(p.commentkey2, 0) AS commentkey2
    FROM taqprojecttitle p, gentables g
    WHERE p.associationtypecode = g.datacode
      AND g.tableid = 440
      AND p.taqprojectkey = @i_copy_projectkey
      AND p.associationtypecode > 0
             
  OPEN assotitles_cur

  FETCH assotitles_cur 
  INTO @v_taqprojectformatkey, @v_bookkey, @v_assotype, @v_assosubtype, @v_elotabind, @v_commentkey1, @v_commentkey2
  
  WHILE @@fetch_status = 0
  BEGIN
    SET @v_new_commentkey1 = NULL
    SET @v_new_commentkey2 = NULL

    IF @v_bookkey IS NULL OR @v_bookkey < 0
      SET @v_bookkey = 0

    SET @v_rowcount = 0
    IF @v_bookkey > 0
      SELECT @v_rowcount = COUNT(*)
      FROM associatedtitles 
      WHERE bookkey = @i_new_titlebookkey  
        AND associationtypecode = @v_assotype  
        AND associationtypesubcode = @v_assosubtype  
        AND associatetitlebookkey = @v_bookkey

    IF @v_rowcount > 0
      GOTO fetchnext

    -- Create copies of the comments for either or both commentkey1 and 2 and put those commentkeys in the respective columns on associatedtitles
    IF @v_commentkey1 > 0
    BEGIN
      EXEC get_next_key @i_userid, @v_new_commentkey1 OUTPUT

      INSERT INTO qsicomments 
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite,
        lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
      SELECT 
        @v_new_commentkey1, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite,
        @i_userid, getdate(), invalidhtmlind, NULL
      FROM qsicomments
      WHERE commentkey = @v_commentkey1
    END

    IF @v_commentkey2 > 1
    BEGIN
      EXEC get_next_key @i_userid, @v_new_commentkey2 OUTPUT

      INSERT INTO qsicomments 
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite,
        lastuserid, lastmaintdate, invalidhtmlind, releasetoeloquenceind)
      SELECT 
        @v_new_commentkey2, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite,
        @i_userid, getdate(), invalidhtmlind, NULL
      FROM qsicomments
      WHERE commentkey = @v_commentkey2
    END

    SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
    FROM associatedtitles 
    WHERE bookkey = @i_new_titlebookkey
      AND associationtypecode = @v_assotype 
      AND associationtypesubcode = @v_assosubtype

    PRINT '@v_taqprojectformatkey: ' + CONVERT(VARCHAR, @v_taqprojectformatkey)
    PRINT '@v_bookkey: ' + CONVERT(VARCHAR, @v_bookkey)
    PRINT '@v_assotype: ' + CONVERT(VARCHAR, @v_assotype)
    PRINT '@v_assosubtype: ' + CONVERT(VARCHAR, @v_assosubtype)
    PRINT '@v_commentkey1: ' + CONVERT(VARCHAR, @v_commentkey1)
    PRINT '@v_commentkey2: ' + CONVERT(VARCHAR, @v_commentkey2)
    PRINT '@v_new_commentkey1: ' + CONVERT(VARCHAR, @v_new_commentkey1)
    PRINT '@v_new_commentkey2: ' + CONVERT(VARCHAR, @v_new_commentkey2)
    PRINT '@v_sortorder: ' + CONVERT(VARCHAR, @v_sortorder)
    
    INSERT INTO associatedtitles 
      (bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder,
      isbn, title, authorname, bisacstatus, origpubhousecode, mediatypecode, mediatypesubcode,
      price, pubdate, salesunitgross, salesunitnet, reportind, authorkey, lastuserid, lastmaintdate,
      productidtype, bookpos, lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale,
      releasetoeloquenceind, pagecount, illustrations, quantity, volumenumber,
      commentkey1, commentkey2, editiondescription, itemnumber)
    SELECT 
      @i_new_titlebookkey, @v_assotype, @v_assosubtype, @v_bookkey, @v_sortorder,
      CASE 
        WHEN (COALESCE(bookkey, 0) = 0) THEN ean
        ELSE isbn 
      END, title, authorname, bisacstatus, origpubhousecode, mediatypecode, mediatypesubcode,
      price, pubdate, salesunitgross, salesunitnet, reportind, 0, @i_userid, getdate(),
      productidtype, bookpos, lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale,
      0, pagecount, illustrations, quantity, volumenumber,
      @v_new_commentkey1, @v_new_commentkey2, editiondescription, itemnumber
    FROM taqprojecttitle
    WHERE taqprojectformatkey = @v_taqprojectformatkey

    IF @v_bookkey > 0
    BEGIN
      SELECT @v_ProductIdType = 
      CASE (SELECT LTRIM(RTRIM(LOWER(columnname))) FROM productnumlocation WHERE productnumlockey=1)
        WHEN 'isbn' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=1)
        WHEN 'isbn10' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=1)
        WHEN 'ean' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
        WHEN 'ean13' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
        WHEN 'gtin' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=3)
        WHEN 'gtin14' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=3)
        WHEN 'upc' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=4)
        WHEN 'itemnumber' THEN (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=6)
        ELSE (SELECT datacode FROM gentables WHERE tableid=551 AND qsicode=2)
      END

      SELECT @v_authorkey =
      CASE
        WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = @v_bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = @v_bookkey AND primaryind=1)
        ELSE 0
      END
      
      IF @v_authorkey > 0
        UPDATE associatedtitles
        SET authorkey = @v_authorkey
        WHERE bookkey = @i_new_titlebookkey
          AND associationtypecode = @v_assotype
          AND associationtypesubcode = @v_assosubtype
          AND associatetitlebookkey = @v_bookkey
          AND sortorder = @v_sortorder

      IF @v_elotabind = 1
      BEGIN
        EXECUTE qtitle_reciprocal_relationship @i_new_titlebookkey, @v_bookkey, @v_assotype, @v_assosubtype,
          @v_ProductIdType, 'A', @v_authorkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
          
        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to transfer taqprojecttitle to associatedtitles: Failed calling qtitle_reciprocal_relationship'
          RETURN
        END
      END
      ELSE
      BEGIN
        EXECUTE qtitle_reciprocal_relationship_noneelo @i_new_titlebookkey, @v_bookkey, @v_assotype,
          @v_ProductIdType, 'A', @v_AuthorKey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
          
        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to translate competitive/comparitive titles: Failed calling qtitle_reciprocal_relationship_noneelo'
          RETURN
        END
      END
    END --@v_bookkey > 0

    fetchnext:
    FETCH assotitles_cur 
    INTO @v_taqprojectformatkey, @v_bookkey, @v_assotype, @v_assosubtype, @v_elotabind, @v_commentkey1, @v_commentkey2

  END

  CLOSE assotitles_cur
  DEALLOCATE assotitles_cur
  
  PRINT 'END qproject_copy_project_comp_titles'

END
GO

GRANT EXEC ON qproject_copy_project_comp_titles TO PUBLIC
GO