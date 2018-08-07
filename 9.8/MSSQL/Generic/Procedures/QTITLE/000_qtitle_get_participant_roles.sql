if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_participant_roles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_participant_roles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_participant_roles
 (@i_bookkey        integer,
  @i_bookcontactkey integer,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_participant_roles
**  Desc: This stored procedure returns all roles for a participant
**        from the bookcontactrole table.              
**
**    Auth: Alan Katzen
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:     Description:
**    --------    --------      -------------------------------------------
**    09/25/08      Lisa        Cloned from qproject_get_participant_roles
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT r.*, b.globalcontactkey
    FROM bookcontactrole r 
    join bookcontact b on r.bookcontactkey = b.bookcontactkey
   WHERE b.bookkey = @i_bookkey and
         b.bookcontactkey = @i_bookcontactkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing bookcontactrole: bookkey = ' + cast(@i_bookkey AS VARCHAR)+ ' bookcontactkey = ' + cast(@i_bookcontactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_participant_roles TO PUBLIC
GO
