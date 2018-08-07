if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionroyaltyrates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionroyaltyrates
GO

CREATE PROCEDURE qpl_get_taqversionroyaltyrates (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_formatkey    INT,
  @i_saleschannel INT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_get_taqversionroyaltyrates
**  Desc: This stored procedure returns Royalty Rates for given Format/Sales Channel.
**
**  Auth: Kate
**  Date: November 16 2007
*******************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT r.* 
  FROM taqversionroyaltyrates r, taqversionroyaltysaleschannel c
  WHERE r.taqversionroyaltykey = c.taqversionroyaltykey AND
      c.taqprojectkey = @i_projectkey AND
      c.plstagecode = @i_plstage AND
      c.taqversionkey = @i_plversion AND
      c.taqprojectformatkey = @i_formatkey AND
      c.saleschannelcode = @i_saleschannel
  ORDER BY lastthresholdind ASC, threshold ASC

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionroyaltyrates/taqversionroyaltysaleschannel tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_plversion AS VARCHAR) + 
      ', taqversionformatkey=' + CAST(@i_formatkey AS VARCHAR) + ', saleschannelcode=' + CAST(@i_saleschannel AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_taqversionroyaltyrates TO PUBLIC
GO
