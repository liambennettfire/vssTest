if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_productioncosts_by_year') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_productioncosts_by_year
GO

CREATE PROCEDURE qpl_get_productioncosts_by_year (
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*******************************************************************************************************************
**  Name: qpl_get_productioncosts_by_year
**  Desc: This stored procedure returns Total # of Gross Sales Units and Total Unit Cost for given Format by Year.
**
**  Auth: Kate Wiewiora
**  Date: April 4 2008
*******************************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT g.sortorder, u.yearcode, SUM(u.grosssalesunits) total_units, dbo.qpl_get_total_unitcost_by_formatyear(@i_formatkey, g.sortorder) total_unitcost
  FROM taqversionsalesunit u, taqversionsaleschannel c, gentables g
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
    u.yearcode = g.datacode AND 
    g.tableid = 563 AND
    c.taqprojectkey = @i_projectkey AND
    c.plstagecode = @i_plstage AND
    c.taqversionkey = @i_versionkey AND
    c.taqprojectformatkey = @i_formatkey
  GROUP BY g.sortorder, u.yearcode
       
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionsaleschannel/taqversionsalesunit tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END
END
GO

GRANT EXEC ON qpl_get_productioncosts_by_year TO PUBLIC
GO
