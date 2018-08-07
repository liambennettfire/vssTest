if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionformatyear') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionformatyear
GO

CREATE PROCEDURE qpl_get_taqversionformatyear (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @i_byprintrun   tinyint,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionformatyear
**  Desc: This stored procedure returns info from taqversionformatyear for a 
**  given projectkey, stage, version, and format.
**
**  Auth: Alan Katzen
**  Date: November 7, 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
        
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  IF @i_byprintrun = 1  --retrieve by Print Run, only records with printingnumber > 0
    SELECT y.taqversionformatyearkey, COALESCE(y.printingnumber,1) printingnumber, y.quantity, COALESCE(g.alternatedesc1, g.datadesc) yeardesc, g.qsicode,
      (dbo.qpl_get_format_totalrequiredqty(y.taqprojectkey, y.plstagecode, y.taqversionkey, y.taqprojectformatkey) * y.percentage / 100) calc_quantity, g.datadesc yearnumdesc
    FROM taqversionformatyear y, gentables g
    WHERE y.yearcode = g.datacode AND
      g.tableid = 563 AND 
      y.taqprojectkey = @i_projectkey AND
      y.plstagecode = @i_plstage AND 
      y.taqversionkey = @i_versionkey AND
      y.taqprojectformatkey = @i_formatkey AND
      y.printingnumber > 0
    ORDER BY y.printingnumber, g.sortorder
  ELSE
    SELECT y.taqversionformatyearkey, y.yearcode, COALESCE(g.alternatedesc1,g.datadesc) yeardesc, 
      CASE WHEN g.sortorder = 0 THEN COALESCE(y.printingnumber,1) ELSE y.printingnumber END printingnumber, g.datadesc yearnumdesc
    FROM taqversionformatyear y, gentables g
    WHERE y.yearcode = g.datacode AND
      g.tableid = 563 AND
      y.taqprojectkey = @i_projectkey AND
      y.plstagecode = @i_plstage AND 
      y.taqversionkey = @i_versionkey AND
      y.taqprojectformatkey = @i_formatkey 
    ORDER BY g.sortorder  

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionformatyear TO PUBLIC
GO
