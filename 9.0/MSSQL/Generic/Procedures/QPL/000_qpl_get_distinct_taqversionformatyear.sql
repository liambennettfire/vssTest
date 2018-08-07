if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_distinct_taqversionformatyear') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_distinct_taqversionformatyear
GO

CREATE PROCEDURE qpl_get_distinct_taqversionformatyear (  
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_distinct_taqversionformatyear
**  Desc: This stored procedure returns distinct yearcode for given version.
**
**  Auth: Kate
**  Date: November 23 2009
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  SELECT DISTINCT y.yearcode, g.alternatedesc1 yeardesc, g.sortorder
  FROM taqversionformatyear y, gentables g
  WHERE y.yearcode = g.datacode AND
    g.tableid = 563 AND
    y.taqprojectkey = @i_projectkey AND
    y.plstagecode = @i_plstage AND 
    y.taqversionkey = @i_versionkey
  ORDER BY g.sortorder

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionformatyear table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qpl_get_distinct_taqversionformatyear TO PUBLIC
GO
