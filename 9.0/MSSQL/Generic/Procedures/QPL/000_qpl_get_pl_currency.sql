if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_currency') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_currency
GO

CREATE PROCEDURE qpl_get_pl_currency (  
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_pl_currency
**  Desc: This stored procedure returns valid P&L Currencies - US Dollars plus anything that 
**        has a value on the Currency to Currency gentables relationship (27)
**
**  Auth: Kate
**  Date: January 31 2014
***************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  SELECT code1 datacode, datadesc 
  FROM gentablesrelationshipdetail rd, gentables g
  WHERE rd.code1 = g.datacode 
    AND g.tableid = 122 
    AND gentablesrelationshipkey = 27
  UNION
  SELECT datacode, datadesc
  FROM gentables
  WHERE tableid = 122 AND qsicode = 2 --US Dollars

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentablesrelationshipdetail to get P&L currency.'
  END

END
GO

GRANT EXEC ON qpl_get_pl_currency TO PUBLIC
GO
