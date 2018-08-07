IF EXISTS (SELECT
             *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qproject_get_ProsAndCons')
               AND
               OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_get_ProsAndCons
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qproject_get_ProsAndCons (
  @i_projectkey INTEGER,
  @i_bookkey INTEGER,
  @i_taqprojectformatkey INTEGER,
  @i_projectrolecode INTEGER,
  @i_titlerolecode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS /**************************************************************************************************
**  Name: qproject_get_ProsAndCons
**  Desc: This stored procedure gets Pros and Cons html comment from qsicomments
**	      for a given project-associated title row.
**
**	Auth: Jon Hess
**	Date: December 5th, 2011
**
****************************************************************************************************/

  DECLARE @v_error    INT,
          @v_rowcount INT

  BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = ''

    SELECT
      (SELECT
         coalesce(commentkey1, -1)
         FROM taqprojecttitle t
         WHERE taqprojectkey = @i_projectkey
           AND
           bookkey = @i_bookkey
           AND
           projectrolecode = @i_projectrolecode
           AND
           titlerolecode = @i_titlerolecode
           AND
           taqprojectformatkey = @i_taqprojectformatkey) prosCommentKey,
      (SELECT
         coalesce(commentkey2, -1)
         FROM taqprojecttitle t
         WHERE taqprojectkey = @i_projectkey
           AND
           bookkey = @i_bookkey
           AND
           projectrolecode = @i_projectrolecode
           AND
           titlerolecode = @i_titlerolecode
           AND
           taqprojectformatkey = @i_taqprojectformatkey) consCommentKey,
      (SELECT
         commenthtml
         FROM qsicomments
         WHERE commentkey IN (SELECT
                                coalesce(commentkey1, -1)
                                FROM taqprojecttitle t
                                WHERE taqprojectkey = @i_projectkey
                                  AND
                                  bookkey = @i_bookkey
                                  AND
                                  projectrolecode = @i_projectrolecode
                                  AND
                                  titlerolecode = @i_titlerolecode
                                  AND
                                  taqprojectformatkey = @i_taqprojectformatkey)) prosComment,
      (SELECT
         commenthtml
         FROM qsicomments
         WHERE commentkey IN (SELECT
                                coalesce(commentkey2, -1)
                                FROM taqprojecttitle t
                                WHERE taqprojectkey = @i_projectkey
                                  AND
                                  bookkey = @i_bookkey
                                  AND
                                  projectrolecode = @i_projectrolecode
                                  AND
                                  titlerolecode = @i_titlerolecode
                                  AND
                                  taqprojectformatkey = @i_taqprojectformatkey)) consComment

    -- Save the @@ERROR and @@ROWCOUNT values in local variables before they are cleared.
    SELECT
      @v_error = @@ERROR,
      @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0
      BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Error accessing taqprojecttitles/qsicomments: bookkey=' + cast(@i_bookkey AS VARCHAR) + ', projectkey=' + cast(@i_projectkey AS VARCHAR) + ', projectrolecode=' + cast(@i_projectrolecode AS VARCHAR) + ', titlerolecode=' + cast(@i_titlerolecode AS VARCHAR)
        RETURN
      END

  END
GO
GRANT EXEC ON qproject_get_ProsAndCons TO PUBLIC
GO