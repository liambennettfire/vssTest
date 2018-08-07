if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsalesunit_other_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsalesunit_other_formats
GO

CREATE PROCEDURE qpl_get_taqversionsalesunit_other_formats (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qpl_get_taqversionsalesunit_other_formats
**  Desc: This stored procedure returns SUM of other formats Percentages, Gross Units and
**        Net Units - used for Sales Units grand total calculations across all formats.
**
**  Auth: Kate
**  Date: January 16 2008
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
        
  SELECT yearcode, SUM(u.salespercent) percenttotal, SUM(u.grosssalesunits) grosstotal, SUM(u.netsalesunits) nettotal
  FROM taqversionsalesunit u, taqversionsaleschannel c
  WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_versionkey AND
      c.taqprojectformatkey <> @i_formatkey
  GROUP BY yearcode
  ORDER BY yearcode

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionsaleschannel/taqversionsalesunit tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey<>' + CAST(@i_formatkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsalesunit_other_formats TO PUBLIC
GO
