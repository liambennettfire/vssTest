if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionmarket') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionmarket
GO

CREATE PROCEDURE qpl_get_taqversionmarket (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_marketkey  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqversionmarket
**  Desc: This stored procedure returns all markets for the given version, or
**        if marketkey is passed, market info for the given key.
**
**  Auth: Kate
**  Date: September 29 2011
**************************************************************************************/

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_gentableid INT,
  @v_suballowed TINYINT,
  @v_sub2allowed  TINYINT
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  
  SELECT @v_count = COUNT(*)
  FROM clientdefaults
  WHERE clientdefaultid = 54
  
  SET @v_gentableid = 0
  IF @v_count > 0
  BEGIN
    SELECT @v_gentableid = clientdefaultvalue
    FROM clientdefaults
    WHERE clientdefaultid = 54
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access clientdefaults table (clientdefaultid=54).'
    END
  END

  SELECT @v_suballowed = COALESCE(subgenallowed,0), @v_sub2allowed = COALESCE(sub2genallowed,0)
  FROM gentablesdesc
  WHERE tableid = @v_gentableid
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access gentablesdesc table (tableid=' + CONVERT(VARCHAR, @v_gentableid) + ').'
  END

  IF @i_marketkey > 0 --used in TargetMarketInfo.ascx
  BEGIN
    SELECT @v_gentableid gentableid, @v_suballowed subgenallowed, @v_sub2allowed sub2genallowed, *
    FROM taqversionmarket 
    WHERE targetmarketkey = @i_marketkey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access taqversionmarket table (targetmarketkey=' + CAST(@i_marketkey AS VARCHAR) + ').'
    END
  END
  
  ELSE  --used in TargetMarket.ascx
  BEGIN
  
    SELECT m.*, @v_gentableid gentableid, @v_suballowed subgenallowed, @v_sub2allowed sub2genallowed, 
      (SELECT COALESCE(SUM(c.sellthroughunits),0) FROM taqversionmarketchannelyear c 
      WHERE c.targetmarketkey = m.targetmarketkey) totalsellthroughunits
    FROM taqversionmarket m
    WHERE m.taqprojectkey = @i_projectkey AND
      m.plstagecode = @i_plstage AND
      m.taqversionkey = @i_versionkey        

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access taqversionmarket table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
        ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
    END
  END

END
GO

GRANT EXEC ON qpl_get_taqversionmarket TO PUBLIC
GO
