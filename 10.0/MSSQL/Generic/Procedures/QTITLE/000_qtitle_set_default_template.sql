if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_set_default_template') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_set_default_template
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_set_default_template
 (@i_new_template_bookkey     integer,
  @i_old_template_bookkey     integer,
  @i_userid                   varchar(30),
  @o_error_code               integer       output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_set_default_template
**  Desc: This sets the default Template indicator for a title.
** 
**  NOTE: Use @i_old_template_projectkey to pass bookkey of current
**        default template.  We need this to reset the default indicator to 0.
**        Pass 0 if there currently is no default template.
**
**    Auth: Alan Katzen
**    Date: 16 September 2009
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_old_template_bookkey > 0 BEGIN
    -- reset current default template to not be the default template
    UPDATE book
       SET tmmwebtemplateind = 0,
           lastuserid = @i_userid,
           lastmaintdate = getdate()
     WHERE bookkey = @i_old_template_bookkey
  
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to reset current default template: bookkey = ' + cast(@i_old_template_bookkey AS VARCHAR)
      return
    END 
  END
  
  IF @i_new_template_bookkey > 0 BEGIN
    -- set as default template
    UPDATE book
       SET standardind = 'Y', 
           tmmwebtemplateind = 1,
           lastuserid = @i_userid,
           lastmaintdate = getdate()
     WHERE bookkey = @i_new_template_bookkey
  
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to set default template: bookkey = ' + cast(@i_new_template_bookkey AS VARCHAR)
      return
    END 
  END

GO
GRANT EXEC ON qtitle_set_default_template TO PUBLIC
GO


