if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_grid_tab_items') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_grid_tab_items
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_grid_tab_items
 (@i_scaletabkey         integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_grid_tab_items
**  Desc: This stored procedure returns all items configured for a scale tab.
**        It is possible for the same row to show up twice - once for fixed costs
**        and once for variable costs (that is why UNION ALL is used). 
**
**    Auth: Alan Katzen
**    Date: 22 February 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

  SELECT fixedcostlabel as costtypelabel, 1 as fixedcostind, *,
         CASE WHEN ltrim(rtrim(COALESCE(fixedcostlabel,''))) <> '' AND ltrim(rtrim(COALESCE(varcostlabel,''))) <> '' 
              THEN 1 ELSE 0 END fixedandvariablecostind
    FROM taqscaleadminspecitem
   WHERE scaletabkey = @i_scaletabkey
     AND parametertypecode = 3
     AND ltrim(rtrim(COALESCE(fixedcostlabel,''))) <> ''
  UNION ALL 
  SELECT varcostlabel as costtypelabel, 0 as fixedcostind, *,
         CASE WHEN ltrim(rtrim(COALESCE(fixedcostlabel,''))) <> '' AND ltrim(rtrim(COALESCE(varcostlabel,''))) <> '' 
              THEN 1 ELSE 0 END fixedandvariablecostind 
    FROM taqscaleadminspecitem
   WHERE scaletabkey = @i_scaletabkey
     AND parametertypecode = 3
     AND ltrim(rtrim(COALESCE(varcostlabel,''))) <> ''
  ORDER BY itemcategorycode, itemcode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqscaleadminspecitem table.'
    RETURN
  END 
END

GO
GRANT EXEC ON qscale_get_grid_tab_items TO PUBLIC
GO


