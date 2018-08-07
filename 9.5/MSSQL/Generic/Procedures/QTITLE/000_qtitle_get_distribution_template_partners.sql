if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distribution_template_partners') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_distribution_template_partners
GO

CREATE PROCEDURE qtitle_get_distribution_template_partners
 (@i_templatekey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_distribution_template_partners
**  Desc: This stored procedure returns all distribution template partners
**        for a selected distribution template.
**
**  Auth: Alan Katzen
**  Date: 9/10/10
*************************************************************************************/

BEGIN

  DECLARE @v_error	INT
  
  SELECT *
    FROM csdistributiontemplatepartner
   WHERE templatekey = @i_templatekey 
   
  SELECT @v_error = @@ERROR
  IF @v_error <> 0  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access csdistributiontemplatepartner'
  END
  
END
GO

GRANT EXEC ON qtitle_get_distribution_template_partners TO PUBLIC
GO
