if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_qsicomment_by_key') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_qsicomment_by_key
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_qsicomment_by_key]
 (@i_commentkey     integer,
  @i_parenttable    varchar(2000),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_qsicomment_by_key
**  Desc: This stored procedure returns comment information
**        from the qsicomments table for a specific citation. 
**
**    Auth: Lisa Cormier
**    Date: 24 Aug 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

-- 09/24/2009 Lisa not using parettable column in qsicomments table.
--  IF ( len(isnull(@i_parenttable,'')) > 0 )
--  BEGIN
--    SELECT * from qsicomments where commentkey = @i_commentkey and parenttable = @i_parenttable
--  END
--  ELSE
--  BEGIN
    SELECT * from qsicomments where commentkey = @i_commentkey
--  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing qsicomments: commentkey = ' + cast(@i_commentkey AS VARCHAR) + 
                        ' / parenttable = ' + isnull(@i_parenttable, 'none')
    RETURN 
  END 

GO

GRANT EXEC ON qutl_get_qsicomment_by_key TO PUBLIC
GO