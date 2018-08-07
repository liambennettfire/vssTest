if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_format_all_channels') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_format_all_channels
GO

CREATE PROCEDURE qpl_get_format_all_channels (  
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_formatkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_format_all_channels
**  Desc: This stored procedure returns all sales channels/sub-channels that currently
**        exist in the system, along with info if the given channel/sub-channel
**        already has row on taqversionsaleschannel table for the passed p&l format.
**
**  Auth: Kate
**  Date: August 31 2012
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
   
  SELECT sg.datacode saleschannelcode, sg.datasubcode saleschannelsubcode, 
    g.datadesc channeldesc, sg.datadesc subchanneldesc, 
    COALESCE(g.sortorder,0) channelorder, COALESCE(sg.sortorder,0) subchannelorder,
    COALESCE((SELECT taqversionsaleskey FROM taqversionsaleschannel c 
     WHERE c.taqprojectkey = @i_projectkey AND c.plstagecode = @i_plstage AND 
      c.taqversionkey = @i_versionkey AND c.taqprojectformatkey = @i_formatkey AND
      c.saleschannelcode = sg.datacode AND c.saleschannelsubcode = sg.datasubcode),0) taqversionsaleskey
  FROM gentables g, subgentables sg
  WHERE g.tableid = 118 AND
    sg.tableid = g.tableid AND
    sg.datacode = g.datacode
  UNION
  SELECT g.datacode saleschannelcode, 0 saleschannelsubcode, 
    g.datadesc channeldesc, '' subchanneldesc, 
    COALESCE(g.sortorder,0) channelorder, 0 subchannelorder,  
    COALESCE((SELECT taqversionsaleskey FROM taqversionsaleschannel c 
     WHERE c.taqprojectkey = @i_projectkey AND c.plstagecode = @i_plstage AND 
      c.taqversionkey = @i_versionkey AND c.taqprojectformatkey = @i_formatkey AND
      c.saleschannelcode = g.datacode AND c.saleschannelsubcode = 0),0) taqversionsaleskey
  FROM gentables g
  WHERE g.tableid = 118 AND
    NOT EXISTS (SELECT * FROM subgentables sg 
    WHERE sg.tableid = 118 AND sg.datacode = g.datacode)
  ORDER BY channelorder, channeldesc, subchannelorder, subchanneldesc   
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get all sales channels (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_format_all_channels TO PUBLIC
GO
