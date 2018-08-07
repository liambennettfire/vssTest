if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_DiscoveryQuestions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_DiscoveryQuestions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_DiscoveryQuestions
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_DiscoveryQuestions
**  Desc: This stored procedure returns Discovery Questions Comments for the
**          given bookkey/printingkey
**
**    Auth: Jon Hess
**    Date: 21 May 2010
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0 
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT
 
SELECT dq.discoverykey, sortorder, 
( select commenthtmllite from qsicomments where commentkey = dq.questioncommentkey ) as questionComment, 
( select commentkey from qsicomments where commentkey = dq.questioncommentkey ) as questionCommentKey,

( select commenthtmllite from qsicomments where commentkey = dq.answercommentkey ) as answerComment,
( select commentkey from qsicomments where commentkey = dq.answercommentkey ) as answerCommentKey 

FROM discoveryquestions dq
WHERE dq.bookkey = @i_bookkey


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing discoveryquestions: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' / printingkey = ' + cast(@i_printingkey AS VARCHAR)
    RETURN 
  END 

GO
GRANT EXEC ON qtitle_get_DiscoveryQuestions TO PUBLIC
GO


