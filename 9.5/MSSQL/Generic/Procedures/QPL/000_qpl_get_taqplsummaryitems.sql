if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqplsummaryitems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqplsummaryitems
GO

CREATE PROCEDURE qpl_get_taqplsummaryitems (  
  @i_projectkey     integer,
  @i_pllevel        integer,
  @i_plheading      integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_taqplsummaryitems
**  Desc: This stored procedure returns all items for given projectkey and P&L Level.
**
**  Auth: Kate
**  Date: September 4 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  IF @i_pllevel = 1 --Stage
    SELECT p.*, i.position, g.sortorder
    FROM taqplsummaryitems p, plsummaryitemdefinition i, gentables g
    WHERE p.plsummaryitemkey = i.plsummaryitemkey AND
        p.plstagecode = g.datacode AND
        g.tableid = 562 AND    
        p.taqprojectkey = @i_projectkey AND 
        p.taqversionkey = 0 AND
        i.summaryheadingcode = @i_plheading
    ORDER BY g.sortorder, i.position

  ELSE IF @i_pllevel = 2  --Version
    SELECT p.*
    FROM taqplsummaryitems p, plsummaryitemdefinition i
    WHERE p.plsummaryitemkey = i.plsummaryitemkey AND
        p.taqprojectkey = @i_projectkey AND 
        p.taqversionkey > 0 AND
        p.yearcode = 0 AND
        i.summaryheadingcode = @i_plheading
    ORDER BY p.plstagecode, p.taqversionkey, i.position

  ELSE IF @i_pllevel = 3  --Year
    SELECT p.*, i.position, g.sortorder yearsort
    FROM taqplsummaryitems p
      LEFT OUTER JOIN gentables g ON p.yearcode = g.datacode AND g.tableid = 563,
      plsummaryitemdefinition i
    WHERE p.plsummaryitemkey = i.plsummaryitemkey AND            
        p.taqprojectkey = @i_projectkey AND 
        p.taqversionkey > 0 AND
        (i.summaryheadingcode = @i_plheading OR i.summaryheadingcode = 5)
    UNION
    SELECT p.*, i.position, g.sortorder yearsort
    FROM taqplsummaryitems p
      LEFT OUTER JOIN gentables g ON p.yearcode = g.datacode AND g.tableid = 563,
      plsummaryitemdefinition i
    WHERE p.plsummaryitemkey = i.plsummaryitemkey AND            
        p.taqprojectkey = @i_projectkey AND 
        p.taqversionkey > 0 AND
        p.plsummaryitemkey IN (SELECT assocplsummaryitemkey FROM plsummaryitemdefinition i2, taqplsummaryitems p2
    WHERE p2.plsummaryitemkey = i2.plsummaryitemkey AND            
        p2.taqprojectkey = @i_projectkey AND 
        p2.taqversionkey > 0 AND
        (i2.summaryheadingcode = @i_plheading OR i2.summaryheadingcode = 5))
    ORDER BY p.plstagecode, p.taqversionkey, i.position, yearsort    

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqplsummaryitems/plsummaryitemdefinition tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', level=' + CAST(@i_pllevel AS VARCHAR) + ', summaryheadingcode=' + CAST(@i_plheading AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_taqplsummaryitems TO PUBLIC
GO
