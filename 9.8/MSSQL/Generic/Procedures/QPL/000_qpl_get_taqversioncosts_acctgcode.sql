if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversioncosts_acctgcode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncosts_acctgcode
GO

CREATE PROCEDURE qpl_get_taqversioncosts_acctgcode (
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey  integer,
  @i_acctgcode  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversioncosts_acctgcode
**  Desc: This stored procedure returns taqversioncosts row for given chargecode.
**
**  Auth: Kate Wiewiora
**  Date: January 27, 2010
**************************************************************************************
**	Change History
**************************************************************************************
**  Date	Author	Description
**	----	------	-----------
**	1/20/16	Kate	Took out the restriction for NOT NULL amounts (see case 35860)
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
       
  SELECT y.taqversionformatyearkey, COALESCE(g.qsicode,0) qsicode, g.alternatedesc1, c.versioncostsamount, c.unitcost 
  FROM taqversioncosts c, taqversionformatyear y, gentables g
  WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND
      y.yearcode = g.datacode AND
      g.tableid = 563 AND
      y.taqprojectkey = @i_projectkey AND
      y.plstagecode = @i_plstage AND
      y.taqversionkey = @i_versionkey AND
      y.taqprojectformatkey = @i_formatkey AND
      c.acctgcode = @i_acctgcode
  ORDER BY g.sortorder

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear/taqversioncosts tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ', taqprojectformatkey=' +
      CAST(@i_formatkey AS VARCHAR) + ', acctgcode=' + CAST(@i_acctgcode AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC ON qpl_get_taqversioncosts_acctgcode TO PUBLIC
GO
