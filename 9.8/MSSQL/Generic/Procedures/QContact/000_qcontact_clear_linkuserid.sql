IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcontact_clear_linkuserid]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcontact_clear_linkuserid]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qcontact_clear_linkuserid]
 (@i_linkuserid		integer,
  @o_error_code		integer output,
  @o_error_desc		varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_clear_linkuserid
**  Desc: This stored procedure sets the userid linked to this globalcontact
**			to null.  There should only be one userid set.
**  Parameters:
**		@i_linkuserid - value for 'userid' column of globalcontact table
**
**  Auth: Lisa Cormier
**  Date: 12 Aug 2008
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  UPDATE globalcontact SET userid = null WHERE userid = @i_linkuserid

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing globalcontact table from qcontact_clear_linkuserid stored proc'  
  END 

GO

GRANT EXEC on qcontact_clear_linkuserid TO PUBLIC
GO


