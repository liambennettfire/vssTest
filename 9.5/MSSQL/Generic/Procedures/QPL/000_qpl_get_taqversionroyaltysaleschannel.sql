if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionroyaltysaleschannel') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionroyaltysaleschannel
GO

CREATE PROCEDURE qpl_get_taqversionroyaltysaleschannel (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_formatkey    INT,
  @i_saleschannel INT,  
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_get_taqversionroyaltysaleschannel
**  Desc: This stored procedure returns Royalty Sales Channel information.
**
**  Auth: Kate
**  Date: December 3 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT * 
  FROM taqversionroyaltysaleschannel
  WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_plversion AND
      taqprojectformatkey = @i_formatkey AND
      saleschannelcode = @i_saleschannel

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionroyaltysaleschannel table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_plversion AS VARCHAR) + 
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ', saleschannelcode=' + CAST(@i_saleschannel AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionroyaltysaleschannel TO PUBLIC
GO
