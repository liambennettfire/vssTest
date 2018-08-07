IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_num_participants]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qtitle_get_num_participants]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qtitle_get_num_participants]
 (@i_bookkey			integer,
  @i_printingkey        integer,
  @o_numparticipants	integer output,
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_num_participants
**
**  Called by AddContact dialog to determine sort order for new contacts.
**
**  Author: Lisa Cormier
**  Date:   Oct. 2008
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_numparticipants = 0

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @maxnum_var INT

    SELECT @maxnum_var = max(sortorder) 
      FROM bookcontact 
     WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'max sort not found'
  END 

  IF @maxnum_var >= 0 BEGIN
    SET @o_numparticipants = @maxnum_var
  END
GO

GRANT EXEC on qtitle_get_num_participants TO PUBLIC
GO