IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qproject_copy_project_comp_relationships')
               AND
               OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_copy_project_comp_relationships
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_comp_relationships] (
  @i_copy_projectkey INTEGER,
  @o_new_projectkey INTEGER,
  @i_userid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

/***************************************************************************************
**  Name: qproject_copy_project_comp_relationships
**  Desc: This stored procedure copies competitive and comparative titles from a project 
**        template to a new project and it's currently driven from [qproject_copy_project]
**        as a 10 copydatagroup "Project Relationships"
**
**
**  Auth: Jon Hess
**  Date: 12/14/2012
**  Case: 14197 originally
****************************************************************************************/

  DECLARE @v_count                           INT,
          @v_error                           INT,
          @taqprojectformatkey_var           INT,
          @_new_taqprojectformatkey_var      INT,
          @v_associationtypecode             INT,
          @v_competitivetitlesassotypecode   INT,
          @v_comparativetitlesassotypecode   INT,
          @v_taqprojecttitle_projectrolecode INT,
          @v_taqprojecttitle_titlerolecode   INT,
          @v_Commentkey1                     INT,
          @v_Commentkey2                     INT,
          @format_bookkey_var                INT,
          @v_newcommentkey01                 INT,
          @v_newcommentkey02                 INT
  BEGIN

    SET @o_error_code = 0
    SET @o_error_desc = ''

    --PRINT 'Begin qproject_copy_project_comp_relationships'

    --Cursor to obtain Competitive and Comparative Titles.
    DECLARE project_competitive_comparative_cur CURSOR FOR
    SELECT coalesce(f.taqprojectformatkey, 0),
           coalesce(f.bookkey, 0),
           f.titlerolecode,
           coalesce(f.Commentkey1, 0) AS Commentkey1,
           coalesce(f.Commentkey2, 0) AS Commentkey2
      FROM taqprojecttitle f
      WHERE f.taqprojectkey = @i_copy_projectkey
        AND
        f.projectrolecode = 2
        AND
        (f.titlerolecode = 5 OR f.titlerolecode = 6)
      ORDER BY f.primaryformatind DESC,
               f.mediatypecode,
               f.taqprojectformatdesc

    OPEN project_competitive_comparative_cur

    FETCH project_competitive_comparative_cur INTO @taqprojectformatkey_var,
    @format_bookkey_var, @v_taqprojecttitle_titlerolecode, @v_Commentkey1, @v_Commentkey2
    WHILE @@fetch_status = 0
      BEGIN

        SELECT @v_competitivetitlesassotypecode = datacode
          FROM gentables g
          WHERE tableid = 440
            AND
            qsicode = 17

        SELECT @v_comparativetitlesassotypecode = datacode
          FROM gentables g
          WHERE tableid = 440
            AND
            qsicode = 3

        IF @v_taqprojecttitle_titlerolecode = 5
          SET @v_associationtypecode = @v_competitivetitlesassotypecode
        ELSE
        IF @v_taqprojecttitle_titlerolecode = 6
          SET @v_associationtypecode = @v_comparativetitlesassotypecode

        -- I need to create copies of the comments for either-or or both commentkey1 and 2 and put those commentkeys in the respective columns on associatedtitles

        IF @v_Commentkey1 > 1
          BEGIN
            EXEC get_next_key @i_userid, @v_newcommentkey01 OUTPUT

            --PRINT '@v_newcommentkey01: ' + cast(@v_newcommentkey01 AS VARCHAR(255))

            INSERT
              INTO qsicomments (commentkey,
                                commenttypecode,
                                commenttypesubcode,
                                parenttable,
                                commenttext,
                                commenthtml,
                                commenthtmllite,
                                lastuserid,
                                lastmaintdate,
                                invalidhtmlind,
                                releasetoeloquenceind)
              SELECT @v_newcommentkey01 AS commentkey,
                     q.commenttypecode,
                     q.commenttypesubcode,
                     q.parenttable,
                     q.commenttext,
                     q.commenthtml,
                     q.commenthtmllite,
                     @i_userid AS lastuserid,
                     GETDATE() AS lastmaintdate,
                     q.invalidhtmlind,
                     q.releasetoeloquenceind
                FROM qsicomments q
                WHERE q.commentkey = @v_Commentkey1

          --PRINT 'Rows effected: ' + cast(@@rowcount AS VARCHAR(255))

          END

        IF @v_Commentkey2 > 1
          BEGIN
            EXEC get_next_key @i_userid, @v_newcommentkey02 OUTPUT

            --PRINT '@v_newcommentkey02: ' + cast(@v_newcommentkey02 AS VARCHAR(255))

            INSERT
              INTO qsicomments (commentkey,
                                commenttypecode,
                                commenttypesubcode,
                                parenttable,
                                commenttext,
                                commenthtml,
                                commenthtmllite,
                                lastuserid,
                                lastmaintdate,
                                invalidhtmlind,
                                releasetoeloquenceind)
              SELECT @v_newcommentkey02 AS commentkey,
                     q.commenttypecode,
                     q.commenttypesubcode,
                     q.parenttable,
                     q.commenttext,
                     q.commenthtml,
                     q.commenthtmllite,
                     @i_userid AS lastuserid,
                     GETDATE() AS lastmaintdate,
                     q.invalidhtmlind,
                     q.releasetoeloquenceind
                FROM qsicomments q
                WHERE q.commentkey = @v_Commentkey2
          END

        --PRINT 'Rows effected: ' + cast(@@rowcount AS VARCHAR(255))

        -- I will copy from taqprojecttitles back to taqprojecttitles with some new values.

        EXEC get_next_key @i_userid, @_new_taqprojectformatkey_var OUTPUT


        INSERT
          INTO taqprojecttitle
            (
            taqprojectformatkey,
            taqprojectkey,
            seasoncode,
            seasonfirmind,
            mediatypecode,
            mediatypesubcode,
            discountcode,
            price,
            initialrun,
            projectdollars,
            marketingplancode,
            primaryformatind,
            isbn,
            isbn10,
            ean,
            ean13,
            gtin,
            bookkey,
            taqprojectformatdesc,
            isbnprefixcode,
            lastuserid,
            lastmaintdate,
            gtin14,
            lccn,
            dsmarc,
            itemnumber,
            upc,
            eanprefixcode,
            printingkey,
            projectrolecode,
            titlerolecode,
            keyind,
            sortorder,
            indicator1,
            indicator2,
            quantity1,
            quantity2,
            relateditem2name,
            relateditem2status,
            relateditem2participants,
            templatekey,
            authorname,
            bisacstatus,
            origpubhousecode,
            pubdate,
            salesunitgross,
            salesunitnet,
            reportind,
            productidtype,
            bookpos,
            lifetodatepointofsale,
            yeartodatepointofsale,
            previousyearpointofsale,
            pagecount,
            illustrations,
            quantity,
            volumenumber,
            Commentkey1,
            Commentkey2,
            editiondescription,
            title,
            associationtypecode,
            associationtypesubcode)
          SELECT @_new_taqprojectformatkey_var,
                 @o_new_projectkey,
                 t.seasoncode,
                 t.seasonfirmind,
                 t.mediatypecode,
                 t.mediatypesubcode,
                 t.discountcode,
                 t.price,
                 t.initialrun,
                 t.projectdollars,
                 t.marketingplancode,
                 t.primaryformatind,
                 t.isbn,
                 t.isbn10,
                 t.ean,
                 t.ean13,
                 t.gtin,
                 t.bookkey,
                 t.taqprojectformatdesc,
                 t.isbnprefixcode,
                 @i_userid,
                 getdate(),
                 t.gtin14,
                 t.lccn,
                 t.dsmarc,
                 t.itemnumber,
                 t.upc,
                 t.eanprefixcode,
                 t.printingkey,
                 t.projectrolecode,
                 t.titlerolecode,
                 t.keyind,
                 t.sortorder,
                 t.indicator1,
                 t.indicator2,
                 t.quantity1,
                 t.quantity2,
                 t.relateditem2name,
                 t.relateditem2status,
                 t.relateditem2participants,
                 t.templatekey,
                 t.authorname,
                 t.bisacstatus,
                 t.origpubhousecode,
                 t.pubdate,
                 t.salesunitgross,
                 t.salesunitnet,
                 t.reportind,
                 t.productidtype,
                 t.bookpos,
                 t.lifetodatepointofsale,
                 t.yeartodatepointofsale,
                 t.previousyearpointofsale,
                 t.[pagecount],
                 t.illustrations,
                 t.quantity,
                 t.volumenumber,
                 @v_newcommentkey01,
                 @v_newcommentkey02,
                 t.editiondescription,
                 t.title,
                 t.associationtypecode,
                 t.associationtypesubcode
            FROM taqprojecttitle t
            WHERE taqprojectkey = @i_copy_projectkey
              AND
              taqprojectformatkey = @taqprojectformatkey_var

        --cursor bottom fetch
        FETCH project_competitive_comparative_cur INTO @taqprojectformatkey_var,
        @format_bookkey_var, @v_taqprojecttitle_titlerolecode, @v_Commentkey1, 
          @v_Commentkey2

      END

    --cursor close and deallocate
    CLOSE project_competitive_comparative_cur
    DEALLOCATE project_competitive_comparative_cur

  --PRINT 'End qproject_copy_project_comp_relationships'

  END
GO

GRANT EXEC ON qproject_copy_project_comp_relationships TO PUBLIC
GO