if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_plsummaryitemcalc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_plsummaryitemcalc
GO

CREATE PROCEDURE qpl_get_plsummaryitemcalc
 (@i_plsummaryitemkey integer,
  @i_orgentrykey      integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qpl_get_plsummaryitemcalc
**  Desc: This stored procedure returns P&L Summary calculations from plsummaryitemcalc table.
**
**  Auth: Kate
**  Date: 21 August 2007
************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  SELECT * FROM plsummaryitemcalc
  WHERE plsummaryitemkey = @i_plsummaryitemkey AND
      orgentrykey = @i_orgentrykey
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access plsummaryitemcalc table (plsummaryitemkey=' + CAST(@i_plsummaryitemkey AS VARCHAR) +
      ', orgentrykey=' + CAST(@i_orgentrykey AS VARCHAR) + '.'
  END 

GO

GRANT EXEC ON qpl_get_plsummaryitemcalc TO PUBLIC
GO


