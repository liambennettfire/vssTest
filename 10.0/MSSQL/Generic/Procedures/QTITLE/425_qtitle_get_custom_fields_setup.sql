if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_custom_fields_setup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_custom_fields_setup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_custom_fields_setup
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_custom_fields_setup
**  Desc: This gets the custom field label information for display purposes.
*******************************************************************************/
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT customfieldname, customfieldlabel, customfieldformat, titlesearchind,
	  CASE LOWER(LEFT(customfieldname, 9))
		  WHEN 'customcod' THEN 1
		  WHEN 'customind' THEN 2
		  WHEN 'customint' THEN 3
		  ELSE 4
    END AS sortorder
  FROM customfieldsetup
  ORDER BY sortorder, customfieldname

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found:'  
  END 

GO

GRANT EXEC ON qtitle_get_custom_fields_setup TO PUBLIC
GO


 