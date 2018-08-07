if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qimport_get_template_master') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qimport_get_template_master
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qimport_get_template_master
 (@i_templatekey    integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qimport_get_template_master
**  Desc: This gets import template info.  Will get specific template info
**        if i_templatekey > 0
**
**    Auth: Alan Katzen
**    Date: 4 January 2006
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_templatekey > 0 BEGIN
    SELECT *
    FROM imp_template_master m
    WHERE m.templatekey = @i_templatekey 
  END
  ELSE BEGIN
    SELECT *
    FROM imp_template_master m
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on imp_template_master.'  
  END 

GO
GRANT EXEC ON qimport_get_template_master TO PUBLIC
GO


