if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_element_contactlist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_element_contactlist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qelement_get_element_contactlist
 (@i_elementkey           integer,
  @i_bookkey              integer,
  @i_projectkey           integer,
  @i_rolecode             integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS
/******************************************************************************
**  File: qelement_get_element_contactlist
**  Name: qelement_get_element_contactlist
**  Desc: This procedure calls a function to get contacts associated with an 
**        element.  
**
**    Auth: Alan Katzen
**    Date: 15 May 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  SELECT * FROM dbo.qelement_build_element_contactlist(@i_elementkey,@i_bookkey,@i_projectkey,@i_rolecode)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error building element contactlist'
    RETURN  
  END 
  
ExitHandler:

GO
GRANT EXEC ON qelement_get_element_contactlist TO PUBLIC
GO


