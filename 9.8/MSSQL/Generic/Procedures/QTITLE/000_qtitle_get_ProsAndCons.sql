if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_ProsAndCons') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_ProsAndCons
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_ProsAndCons
 (@i_bookkey	  integer,
  @i_associatetitlesbookkey integer,
  @i_sortorder    integer,
  @i_associationtypecode integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qtitle_get_ProsAndCons
**  Desc: This stored procedure gets Pros and Cons html comment from qsicomments
**	      for a given associatedtitles row.
**
**	Auth: Jon Hess
**	Date: 1 June 2010
**
**  6/25/10 - Kate - Rewritten to get full HTML comment (original code retrieved first 2000 chars).
**  7/12/10 - Jon  - Added associationTypeCode to subquery as data was allowing multiple rows to return.
**
****************************************************************************************************/

DECLARE @v_error  INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''


SELECT 
 (SELECT COALESCE(commentkey1, -1) FROM associatedtitles 
    WHERE bookkey = @i_bookkey AND associatetitlebookkey = @i_associatetitlesbookkey AND sortorder = @i_sortorder AND associationtypecode = @i_associationtypecode) prosCommentKey,
 (SELECT COALESCE(commentkey2, -1) FROM associatedtitles 
    WHERE bookkey = @i_bookkey AND associatetitlebookkey = @i_associatetitlesbookkey AND sortorder = @i_sortorder AND associationtypecode = @i_associationtypecode) consCommentKey,
 (SELECT commenthtml FROM qsicomments 
    WHERE commentkey IN 
      (SELECT commentkey1 FROM associatedtitles 
       WHERE bookkey = @i_bookkey AND associatetitlebookkey = @i_associatetitlesbookkey AND sortorder = @i_sortorder AND associationtypecode = @i_associationtypecode)) prosComment,
 (SELECT commenthtml FROM qsicomments 
    WHERE commentkey IN 
      (SELECT commentkey2 FROM associatedtitles 
       WHERE bookkey = @i_bookkey AND associatetitlebookkey = @i_associatetitlesbookkey AND sortorder = @i_sortorder AND associationtypecode = @i_associationtypecode)) consComment

  -- Save the @@ERROR and @@ROWCOUNT values in local variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing associatedtitles/qsicomments: bookkey=' + cast(@i_bookkey AS VARCHAR) + 
        ', associatetitlebookkey=' + cast(@i_associatetitlesbookkey AS VARCHAR) + ', sortorder=' + cast(@i_sortorder AS VARCHAR)
    RETURN 
  END 

END
GO
GRANT EXEC ON qtitle_get_ProsAndCons TO PUBLIC
GO


