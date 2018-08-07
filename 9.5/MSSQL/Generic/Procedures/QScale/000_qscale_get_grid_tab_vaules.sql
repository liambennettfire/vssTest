if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_grid_tab_values') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_grid_tab_values
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_grid_tab_values
 (@i_projectkey          integer,
  @i_scaletabkey         integer,
  @i_itemcategorycode    integer,
  @i_itemcode            integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_grid_tab_values
**  Desc: This stored procedure returns all grid values for a tab. 
**
**    Auth: Alan Katzen
**    Date: 27 February 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

  SELECT sd.* 
    FROM taqprojectscaledetails sd, taqprojectscalerowvalues sr, taqprojectscalecolumnvalues sc
   WHERE sd.taqprojectkey = sr.taqprojectkey
     AND sd.rowkey = sr.taqscalerowkey
     AND sd.taqprojectkey = sc.taqprojectkey
     AND sd.columnkey = sc.taqscalecolumnkey
     AND sd.taqprojectkey = @i_projectkey 
     AND sd.itemcategorycode = @i_itemcategorycode 
     AND sd.itemcode = @i_itemcode 
     AND sr.scaletabkey = @i_scaletabkey
     AND sc.scaletabkey = @i_scaletabkey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqprojectscaledetails table.'
    RETURN
  END 
   
END

GO
GRANT EXEC ON qscale_get_grid_tab_values TO PUBLIC
GO


