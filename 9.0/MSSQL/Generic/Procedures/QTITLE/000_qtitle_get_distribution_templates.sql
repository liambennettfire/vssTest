if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distribution_templates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_distribution_templates
GO

CREATE PROCEDURE qtitle_get_distribution_templates
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_distribution_templates
**  Desc: This stored procedure returns all distribution templates.
**
**  Auth: Alan Katzen
**  Date: 9/9/10
*************************************************************************************/

BEGIN

  DECLARE @v_error	INT
  
  SELECT *
    FROM csdistributiontemplate
   
  SELECT @v_error = @@ERROR
  IF @v_error <> 0  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access csdistributiontemplate'
  END
  
END
GO

GRANT EXEC ON qtitle_get_distribution_templates TO PUBLIC
GO
