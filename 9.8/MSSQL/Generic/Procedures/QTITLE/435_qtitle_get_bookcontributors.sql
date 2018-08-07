if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookcontributors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_bookcontributors
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_bookcontributors
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_roletypecode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_bookcontributors
**  Desc: This stored procedure returns bookcontributors for a 
**        bookkey, printingkey, and roletypecode (if passed in).
**              
**
**    Auth: Alan Katzen
**    Date: 18 April 2005
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

  IF @i_roletypecode > 0 BEGIN
    SELECT DISTINCT c.*, c.globalcontactkey contributorkey 
      FROM bookcontact c, bookcontactrole bcr
     WHERE c.bookcontactkey = bcr.bookcontactkey
       and c.bookkey = @i_bookkey
       and c.printingkey = @i_printingkey
       and bcr.rolecode = @i_roletypecode
  ORDER BY c.sortorder

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)
                          + ' and roletypecode = ' + cast(@i_roletypecode AS VARCHAR)   
    END 

    IF @rowcount_var = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)
                          + ' and roletypecode = ' + cast(@i_roletypecode AS VARCHAR)   
    END 

  END
  ELSE BEGIN
    SELECT DISTINCT c.*, c.globalcontactkey contributorkey
      FROM bookcontact c
     WHERE c.bookkey = @i_bookkey
       and c.printingkey = @i_printingkey
  ORDER BY c.sortorder

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    END 

    IF @rowcount_var = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    END 
  END


GO
GRANT EXEC ON qtitle_get_bookcontributors TO PUBLIC
GO


