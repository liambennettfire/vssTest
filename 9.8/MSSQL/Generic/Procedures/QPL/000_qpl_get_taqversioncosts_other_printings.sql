if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversioncosts_other_printings') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncosts_other_printings
GO

CREATE PROCEDURE qpl_get_taqversioncosts_other_printings (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @i_formatkey      integer,
  @i_chargecode     integer,
  @i_fromprinting   integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qpl_get_taqversioncosts_other_printings
**  Desc: This stored procedure returns the SUM of costs for a given chargecode from printings other than
**        displayed on screen - used for chargecode Total calculation in Production Costs by Printing.
**
**  Auth: Kate
**  Date: March 18 2008
**********************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_chargecode = 0  --No chargecode provided - return a list of sum totals for each chargecode
    SELECT c.acctgcode, SUM(c.versioncostsamount) sum_total
    FROM taqversioncosts c, taqversionformatyear y 
    WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND 
        y.taqprojectkey = @i_projectkey AND 
        y.plstagecode = @i_plstage AND 
        y.taqversionkey = @i_versionkey AND 
        y.taqprojectformatkey = @i_formatkey AND 
        (c.printingnumber < @i_fromprinting OR c.printingnumber >= @i_fromprinting + 2)
    GROUP BY c.acctgcode
    
  ELSE  --return specific chargecode sum total
    SELECT SUM(c.versioncostsamount) sum_total
    FROM taqversioncosts c, taqversionformatyear y 
    WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND 
        y.taqprojectkey = @i_projectkey AND 
        y.plstagecode = @i_plstage AND 
        y.taqversionkey = @i_versionkey AND 
        y.taqprojectformatkey = @i_formatkey AND 
        c.acctgcode = @i_chargecode AND
        (c.printingnumber < @i_fromprinting OR c.printingnumber >= @i_fromprinting + 2)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversioncosts/taqversionformatyear tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ', acctgcode=' + CAST(@i_chargecode AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversioncosts_other_printings TO PUBLIC
GO
