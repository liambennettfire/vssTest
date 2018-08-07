if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_total_unitcost_by_formatyear') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_total_unitcost_by_formatyear
GO

CREATE FUNCTION dbo.qpl_get_total_unitcost_by_formatyear
(
  @i_formatkey as integer,
  @i_yearsort as integer
) 
RETURNS FLOAT

/*******************************************************************************************************
**  Name: qpl_get_total_unitcost_by_formatyear
**  Desc: This function returns the Total Unit Cost for given Format/Year.
**
**  Auth: Kate Wiewiora
**  Date: April 2 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_total_unitcost FLOAT
  
  -- First check if costs exist for this Format/Year
  SELECT @v_count = COUNT(*)
  FROM taqversionformatyear y, taqversioncosts c
  WHERE y.taqversionformatyearkey = c.taqversionformatyearkey AND
      y.taqprojectformatkey = @i_formatkey AND 
      y.yearcode <= @i_yearsort AND 
      c.printingnumber > 0
  
  IF @v_count = 0
    RETURN 0   -- no costs for this Format/Year - return 0 unit cost 
  
  -- Get all Format/Year total unit cost values for years prior or equal to the requested year, if printingnumber > 0
  -- IMPORTANT: must sort from the latest year backwards, so that the value for the closest previous year is returned
  DECLARE costs_cur CURSOR FOR 
    SELECT SUM(c.unitcost) 
    FROM taqversionformatyear y, taqversioncosts c, gentables g
    WHERE y.taqversionformatyearkey = c.taqversionformatyearkey AND
      y.yearcode = g.datacode AND
      g.tableid = 563 AND
      y.taqprojectformatkey = @i_formatkey AND 
      g.sortorder <= @i_yearsort AND 
      c.printingnumber > 0
    GROUP BY c.printingnumber
    ORDER BY c.printingnumber DESC
    
  OPEN costs_cur
  
  -- Fetch and return the FIRST closest previous year's Total Unit Cost
  FETCH costs_cur INTO @v_total_unitcost

  CLOSE costs_cur 
  DEALLOCATE costs_cur    

  RETURN @v_total_unitcost

END
GO

GRANT EXEC ON dbo.qpl_get_total_unitcost_by_formatyear TO public
GO
