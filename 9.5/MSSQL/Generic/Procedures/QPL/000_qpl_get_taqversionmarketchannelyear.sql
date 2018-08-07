if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionmarketchannelyear') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionmarketchannelyear
GO

CREATE PROCEDURE qpl_get_taqversionmarketchannelyear (  
  @i_marketkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionmarketchannelyearchannelyear
**  Desc: This stored procedure returns all Market Sales Channel Year information
**        for the given market.
**
**  Auth: Kate
**  Date: September 29 2011
**************************************************************************************/

DECLARE
  @v_error  INT
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT *
  FROM taqversionmarketchannelyear
  WHERE targetmarketkey = @i_marketkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionmarketchannelyear table (targetmarketkey=' + CAST(@i_marketkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionmarketchannelyear TO PUBLIC
GO
