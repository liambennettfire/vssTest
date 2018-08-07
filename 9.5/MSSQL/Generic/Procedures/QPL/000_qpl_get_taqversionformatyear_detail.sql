if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionformatyear_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionformatyear_detail
GO

CREATE PROCEDURE qpl_get_taqversionformatyear_detail (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*******************************************************************************************
**  Name: qpl_get_taqversionformatyear_detail
**  Desc: This stored procedure returns taqversionformatyear info for a given P&L version.
**
**  Auth: Kate Wiewiora
**  Date: March 3, 2008 
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT y.taqversionformatyearkey, y.taqprojectformatkey, y.yearcode, y.printingnumber, y.quantity, 
    y.percentage, COALESCE(y.templatechangedind,0) templatechangedind,
    (SELECT COUNT(*) FROM taqversioncosts c, cdlist cd 
     WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND c.acctgcode = cd.internalcode AND cd.placctgcategorycode = 2) num_prodcosts
  FROM taqversionformatyear y
  WHERE y.taqprojectkey = @i_projectkey AND
    y.plstagecode = @i_plstage AND 
    y.taqversionkey = @i_versionkey AND
    y.yearcode NOT IN (SELECT datacode FROM gentables WHERE tableid = 563 AND qsicode = 1)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionformatyear_detail TO PUBLIC
GO
