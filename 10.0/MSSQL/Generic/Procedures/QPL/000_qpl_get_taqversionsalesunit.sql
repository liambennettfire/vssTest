if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsalesunit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsalesunit
GO

CREATE PROCEDURE qpl_get_taqversionsalesunit (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey  integer,
  @i_getsummary tinyint,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_taqversionsalesunit
**  Desc: This stored procedure returns all Sales Unit Year records for given P&L Version/Format.
**
**  Auth: Kate
**  Date: December 20 2007
***************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_getsummary = 1 BEGIN
    SELECT yearcode, SUM(u.salespercent) percenttotal, SUM(u.grosssalesunits) grosstotal, SUM(u.netsalesunits) nettotal
    FROM taqversionsalesunit u, taqversionsaleschannel c
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_versionkey AND
        c.taqprojectformatkey = @i_formatkey
    GROUP BY yearcode
    ORDER BY yearcode
  END
  ELSE BEGIN
    SELECT u.*, CASE grosssalesunits WHEN 0 THEN NULL ELSE grosssalesunits END grosssalesunits_txt,
        CASE netsalesunits WHEN 0 THEN NULL ELSE netsalesunits END netsalesunits_txt
    FROM taqversionsalesunit u, taqversionsaleschannel c
    WHERE u.taqversionsaleskey = c.taqversionsaleskey AND
        c.taqprojectkey = @i_projectkey AND
        c.plstagecode = @i_plstage AND
        c.taqversionkey = @i_versionkey AND
        c.taqprojectformatkey = @i_formatkey
  END
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionsaleschannel/taqversionsalesunit tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsalesunit TO PUBLIC
GO
