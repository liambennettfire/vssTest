if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionmarket_saleschannel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionmarket_saleschannel
GO

CREATE PROCEDURE qpl_get_taqversionmarket_saleschannel (  
  @i_marketkey  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_taqversionmarket_saleschannel
**  Desc: This stored procedure returns distinct market/salechannel info for the given market.
**
**  Auth: Kate
**  Date: October 11 2011
***************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_error  INT 
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT DISTINCT v.maxyearcode, COALESCE(g.sortorder,0) channelorder, g.datadesc channeldesc, 
      s.saleschannelcode origsaleschannelcode, 0 totalsellthrough, s.saleschannelcode, s.targetmarketkey
  FROM taqversionmarketchannelyear s, taqversionmarket m, taqversion v, gentables g
  WHERE s.targetmarketkey = m.targetmarketkey AND
      m.taqprojectkey = v.taqprojectkey AND
      m.plstagecode = v.plstagecode AND
      m.taqversionkey = v.taqversionkey AND
      s.saleschannelcode = g.datacode AND
      g.tableid = 118 AND
      m.targetmarketkey = @i_marketkey 
  ORDER BY channelorder, channeldesc

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionmarketchannelyear/taqversionmarket tables (targetmarketkey=' + CAST(@i_marketkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionmarket_saleschannel TO PUBLIC
GO
