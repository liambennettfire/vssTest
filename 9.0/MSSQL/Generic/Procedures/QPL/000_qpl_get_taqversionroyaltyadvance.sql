if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionroyaltyadvance') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionroyaltyadvance
GO

CREATE PROCEDURE qpl_get_taqversionroyaltyadvance (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,  
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_get_taqversionroyaltyadvance
**  Desc: This stored procedure returns Royalty Advance information from taqversionroyaltyadvance table.
**
**  Auth: Kate
**  Date: December 17 2009
***********************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_plcurrency_format VARCHAR(40)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_plcurrency_format = COALESCE(g.alternatedesc1, '$###,##0') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables g ON p.plenteredcurrency = g.datacode AND g.tableid = 122 
  WHERE p.taqprojectkey = @i_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject table to get P&L currency info (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END
  
  SELECT a.*, a.yearcode origyearcode, a.datetypecode origdatetypecode, a.dateoffsetcode origdateoffsetcode, @v_plcurrency_format currencyformat
  FROM taqversionroyaltyadvance a, gentables g, datetype d
  WHERE a.datetypecode = d.datetypecode AND
      a.yearcode = g.datacode AND
      g.tableid = 563 AND
      a.taqprojectkey = @i_projectkey AND
      a.plstagecode = @i_plstage AND
      a.taqversionkey = @i_versionkey
  ORDER BY d.sortorder, g.sortorder, a.datetypecode, a.dateoffsetcode
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionroyaltyadvance table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionroyaltyadvance TO PUBLIC
GO
