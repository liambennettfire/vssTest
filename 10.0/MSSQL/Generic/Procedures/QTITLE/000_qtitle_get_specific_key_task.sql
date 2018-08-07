if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_specific_key_task') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_specific_key_task
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_specific_key_task
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_datetypecode   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_get_specific_key_task
**  Desc: This stored procedure returns task information
**        from the taqprojecttask table for a title/printing key task. 
**
**    Auth: Alan Katzen
**    Date: 9/17/08
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_bookkey is null OR @i_bookkey <= 0 BEGIN
    return
  END
  
  SELECT COALESCE(d.datelabel,d.description) description,t.taqtaskkey
    FROM taqprojecttask t, datetype d
   WHERE t.datetypecode = d.datetypecode AND 
	       t.bookkey = @i_bookkey AND
	       t.printingkey = @i_printingkey AND
	       t.datetypecode = @i_datetypecode ANd
	       t.keyind = 1

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttask: bookkey/printingkey/datetype = ' + 
                        cast(@i_bookkey AS VARCHAR) + '/' + 
                        cast(@i_printingkey AS VARCHAR) + '/' +
                        cast(@i_datetypecode AS VARCHAR)
  END 

GO
GRANT EXEC ON qtitle_get_specific_key_task TO PUBLIC
GO


