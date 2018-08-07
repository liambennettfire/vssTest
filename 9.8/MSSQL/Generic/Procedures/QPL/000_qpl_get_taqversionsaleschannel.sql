if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionsaleschannel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionsaleschannel
GO

CREATE PROCEDURE qpl_get_taqversionsaleschannel (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionsaleschannel
**  Desc: This stored procedure returns all Sales Units Sales Channel information
**        for the given P&L version. 
**
**  Auth: Kate
**  Date: December 20 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT v.maxyearcode, COALESCE(g.sortorder,0) channelorder, g.datadesc channeldesc, 
      s.saleschannelcode origsaleschannelcode, 0 grosstotal, 0 nettotal, 0.00 percenttotal, s.*
  FROM taqversionsaleschannel s, taqversion v, gentables g
  WHERE s.taqprojectkey = v.taqprojectkey AND
      s.plstagecode = v.plstagecode AND
      s.taqversionkey = v.taqversionkey AND
      s.saleschannelcode = g.datacode AND
      g.tableid = 118 AND
      s.taqprojectkey = @i_projectkey AND
      s.plstagecode = @i_plstage AND
      s.taqversionkey = @i_versionkey AND
      s.taqprojectformatkey = @i_formatkey
  ORDER BY channelorder, channeldesc

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversion/taqversionsaleschannel tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqversionsaleschannel TO PUBLIC
GO
