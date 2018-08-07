if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_specific_bookcomment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_specific_bookcomment
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_specific_bookcomment
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_datacode       integer,
  @i_datasubcode    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_specific_bookcomment
**  Desc: This stored procedure returns comment information
**        from a comment table for a datacode/datasubcode. The specific
**        comment table is defined by the commenttype parameter.
**        (HTML - bookcommenthtml,RTF - bookcommentrtf,TEXT or blank - bookcomments)
**
**    Auth: Alan Katzen
**    Date: 30 April 2004
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

    SELECT c.* 
        FROM bookcomments c
       WHERE c.bookkey = @i_bookkey and
             c.printingkey = @i_printingkey and
             c.commenttypecode = @i_datacode and 
            c.commenttypesubcode = @i_datasubcode

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing bookcomments: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' / printingkey = ' + cast(@i_printingkey AS VARCHAR) + 
                        ' / datacode = ' + cast(@i_datacode AS VARCHAR) + 
                        ' / datasubcode = ' + cast(@i_datasubcode AS VARCHAR)
    RETURN 
  END 

GO
GRANT EXEC ON qtitle_get_specific_bookcomment TO PUBLIC
GO


