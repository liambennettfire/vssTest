if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsalesunit_sum') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsalesunit_sum
GO

CREATE PROCEDURE qpl_get_taqversionsalesunit_sum (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_get_taqversionsalesunit_sum
**  Desc: This stored procedure returns the SUM of Gross Sales Units for given P&L Version by Format.
**
**  Auth: Kate Wiewiora
**  Date: March 3 2008
*****************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT c.taqprojectformatkey, SUM(u.grosssalesunits) sum_grossunits
  FROM taqversionsaleschannel c, taqversionsalesunit u
  WHERE c.taqversionsaleskey = u.taqversionsaleskey AND
	  c.taqprojectkey = @i_projectkey AND
	  c.plstagecode = @i_plstage AND
	  c.taqversionkey = @i_versionkey
  GROUP BY c.taqprojectformatkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionsaleschannel/taqversionsalesunit tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsalesunit_sum TO PUBLIC
GO
