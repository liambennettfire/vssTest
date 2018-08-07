if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_royalty_rates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_royalty_rates
GO

CREATE PROCEDURE qcontract_get_royalty_rates (  
  @i_royaltykey   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qcontract_get_royalty_rates
**  Desc: This stored procedure returns contract royalty rates for given royaltykey.
**
**  Auth: Kate
**  Date: January 17 2012
****************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT * FROM taqprojectroyaltyrates
  WHERE royaltykey = @i_royaltykey
  ORDER BY lastthresholdind ASC, threshold ASC

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqprojectroyalty table (royaltykey=' + CAST(@i_royaltykey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qcontract_get_royalty_rates TO PUBLIC
GO
