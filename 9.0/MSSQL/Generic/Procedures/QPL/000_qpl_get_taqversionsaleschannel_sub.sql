if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsaleschannel_sub') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsaleschannel_sub
GO

CREATE PROCEDURE qpl_get_taqversionsaleschannel_sub (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionsaleschannel_sub
**  Desc: This stored procedure returns all Sales Units Sub Sales Channel information
**        for the given P&L version. 
**
**  Auth: Kate
**  Date: January 10 2008
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
        
  SELECT COALESCE(g.sortorder,0) channelorder, g.datadesc channeldesc, 
      COALESCE(sg.sortorder,0) subchannelorder, sg.datadesc subchanneldesc, 
      s.saleschannelcode origsaleschannelcode, v.maxyearcode, 0 grosstotal, 0 nettotal, 0.00 percenttotal, s.*
  FROM taqversionsaleschannel s, taqversion v, gentables g, subgentables sg
  WHERE s.taqprojectkey = v.taqprojectkey AND
      s.plstagecode = v.plstagecode AND
      s.taqversionkey = v.taqversionkey AND
      s.saleschannelcode = g.datacode AND
      g.tableid = 118 AND
      sg.tableid = g.tableid AND
      sg.datacode = g.datacode AND
      sg.datasubcode = s.saleschannelsubcode AND
      s.taqprojectkey = @i_projectkey AND
      s.plstagecode = @i_plstage AND
      s.taqversionkey = @i_versionkey AND
      s.taqprojectformatkey = @i_formatkey
  UNION
  SELECT COALESCE(g.sortorder,0) channelorder, g.datadesc channeldesc,
      0 subchannelorder, '' subchanneldesc, 
      s.saleschannelcode origsaleschannelcode, v.maxyearcode, 0 grosstotal, 0 nettotal, 0.00 percenttotal, s.*
  FROM taqversionsaleschannel s, taqversion v, gentables g
  WHERE s.taqprojectkey = v.taqprojectkey AND
      s.plstagecode = v.plstagecode AND
      s.taqversionkey = v.taqversionkey AND
      s.saleschannelcode = g.datacode AND
      g.tableid = 118 AND
      s.taqprojectkey = @i_projectkey AND
      s.plstagecode = @i_plstage AND
      s.taqversionkey = @i_versionkey AND
      s.taqprojectformatkey = @i_formatkey AND
      NOT EXISTS (SELECT * FROM subgentables sg 
                  WHERE sg.tableid = 118 AND sg.datacode = s.saleschannelcode AND sg.datasubcode = s.saleschannelsubcode)
  ORDER BY channelorder, channeldesc, subchannelorder, subchanneldesc

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversion/taqversionsaleschannel tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsaleschannel_sub TO PUBLIC
GO
