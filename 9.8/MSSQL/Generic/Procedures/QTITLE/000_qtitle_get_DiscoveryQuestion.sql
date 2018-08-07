if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_DiscoveryQuestion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_DiscoveryQuestion
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_DiscoveryQuestion
 (@i_bookkey        integer,
  @i_discoverykey   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_DiscoveryQuestion
**  Desc: This stored procedure returns a Discovery Question Comment and 
**         relevent keys for the given bookkey/discoverykey.
**
**    Auth: Jon Hess
**    Date: 25 May 2010
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
          @rowcount_var INT,
          @questionComment varchar(MAX),
          @answerComment varchar(MAX),
          @questionCommentKey INT,
          @answerCommentKey INT
        
SET  @questionComment = ( select commenthtml from qsicomments where commentkey in 
( select questioncommentkey from discoveryquestions where discoverykey = @i_discoverykey and bookkey = @i_bookkey ) )
SET @questionCommentKey = ( select questioncommentkey from discoveryquestions where discoverykey = @i_discoverykey and bookkey = @i_bookkey  )

SET  @answerComment = ( select commenthtml from qsicomments where commentkey in 
( select answercommentkey from discoveryquestions where discoverykey = @i_discoverykey and bookkey = @i_bookkey ) )
SET @answerCommentKey = ( select answercommentkey from discoveryquestions where discoverykey = @i_discoverykey and bookkey = @i_bookkey  )


SELECT	@questionComment as questionComment,
		    @answerComment as answerComment,
        @questionCommentKey as questionCommentKey,
        @answerCommentKey as answerCommentKey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing discoveryquestions/qsicomments: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' / discoverykey = ' + cast(@i_discoverykey AS VARCHAR)
    RETURN 
  END 

GO
GRANT EXEC ON qtitle_get_DiscoveryQuestion TO PUBLIC
GO


