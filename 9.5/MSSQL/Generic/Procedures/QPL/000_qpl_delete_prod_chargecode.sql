if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_delete_prod_chargecode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_delete_prod_chargecode
GO

CREATE PROCEDURE qpl_delete_prod_chargecode (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_versionkey     integer,
  @i_formatkey      integer,
  @i_chargecode     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************************************
**  Name: qpl_delete_prod_chargecode
**  Desc: This stored procedure deletes chargecode costs for ALL printings for given P&L Version/Format - 
**        the 2 visible printings on Production Costs by Printing page, and all other printings.
**
**  Auth: Kate
**  Date: March 21 2008
**********************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  DELETE FROM taqversioncosts
  WHERE acctgcode = @i_chargecode AND
      taqversionformatyearkey IN 
        (SELECT taqversionformatyearkey
         FROM taqversionformatyear
         WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_versionkey AND
            taqprojectformatkey = @i_formatkey)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not delete Production Costs from taqversioncosts table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ', acctgcode=' + CAST(@i_chargecode AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_delete_prod_chargecode TO PUBLIC
GO
