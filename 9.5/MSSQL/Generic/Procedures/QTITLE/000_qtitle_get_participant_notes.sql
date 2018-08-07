if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_participant_notes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_participant_notes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_participant_notes
 (@i_bookkey        integer,
  @i_bookcontactkey integer,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_participant_notes
**  Desc: This stored procedure returns notes for a participant
**        from the bookcontact table. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:			Author:     Description:
**    --------		--------    -------------------------------------------
**    24 Sep 08		Lisa		cloned from qproject_get_participant_notes
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT b.*
    FROM bookcontact b 
   WHERE b.bookkey = @i_bookkey and
         b.bookcontactkey = @i_bookcontactkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR)+ ' bookcontactkey = ' + cast(@i_bookcontactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_participant_notes TO PUBLIC
GO


