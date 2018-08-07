if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_check_titlestatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_check_titlestatus
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_check_titlestatus
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/*****************************************************************************************************
**  File: 
**  Name: qtitle_check_titlestatus
**  Desc: This stored procedure checks the title status. 
** 
**        Returns:  -99 for titles with no access
**                  -98 for titles with limited access (calling location should decide how to proceed)
**
**    Auth: Alan Katzen
**    Date: 29 March 2004
*******************************************************************************************************
**    Change History
*******************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @count_var INT
  DECLARE @titlestatusdesc_var varchar(255)
  DECLARE @qsicode_var INT

  SET @titlestatusdesc_var = ''

  SELECT @count_var = count(*)
    FROM book b, gentables g
   WHERE b.titlestatuscode = g.datacode and
         g.tableid = 149 and 
         g.qsicode in (1,2) and
         b.bookkey = @i_bookkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error Retrieving Title Status: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 
  IF @count_var > 0 BEGIN
    -- title status is set to a status that prevents access to the title
    SELECT @titlestatusdesc_var=datadesc, @qsicode_var=qsicode
      FROM book b, gentables g
     WHERE b.titlestatuscode = g.datacode and
           g.tableid = 149 and 
           g.qsicode in (1,2) and
           b.bookkey = @i_bookkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error Retrieving Title Status: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
    END 

    SET @o_error_code = -99  -- -99 means No Access to this Title
    IF @qsicode_var = 2 BEGIN
      -- Title Requested
      SET @o_error_code = -98
      SET @o_error_desc = 'No Access:  Titles With a Status of ' + @titlestatusdesc_var + 
                          ' Must Be Setup in TMM Enterprise Before They May Be Accessed.'    
    END
    ELSE BEGIN
      -- Advance Contract Transmitted
      SET @o_error_desc = 'No Access:  Titles With a Status of ' + @titlestatusdesc_var + 
                          ' Cannot Be Accessed.'    
    END
    return
  END

GO
GRANT EXEC ON qtitle_check_titlestatus TO PUBLIC
GO
