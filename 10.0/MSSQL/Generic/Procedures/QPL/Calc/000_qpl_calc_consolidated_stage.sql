if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_consolidated_stage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_consolidated_stage
GO

CREATE PROCEDURE qpl_calc_consolidated_stage (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_itemkey      INT,
  @i_display_currency INT,
  @o_result       FLOAT OUTPUT)
AS

/**************************************************************************************************
**  Name: qpl_calc_consolidated_stage
**  Desc: This stored procedure consolidates calculated amount for a given p&l summary item from
**        all projects related to each other via project relationships defined on Project Relationship 
**        gentable with P&L Relationship indicator (gentables 582, gen1ind=1).
**
**  Auth: Kate W
**  Date: November 5 2013
*******************************************************************************************/

DECLARE
  @v_active_projectkey  INT,
  @v_allow_alt_currencies TINYINT,
  @v_approval_currency  INT,
  @v_associtemkey INT,
  @v_calcvalue  DECIMAL(18,4),
  @v_count  INT,
  @v_cur_input_currency INT,
  @v_cur_projectkey INT,
  @v_currencyind  TINYINT,
  @v_default_currency INT,
  @v_display_currency INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),  
  @v_exchangerate_itemkey INT,
  @v_exchangerate DECIMAL(18,4),
  @v_input_currency INT,
  @v_total_calcvalue  DECIMAL(18,4),
  @v_Is_Master_Project INT      
    
BEGIN

  SET @v_total_calcvalue = 0
  SET @v_allow_alt_currencies = 0
  SET @v_exchangerate_itemkey = 0
  SET @v_currencyind = 0
  SET @v_Is_Master_Project = 0  
  
  SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@i_projectkey)
 
  IF @v_Is_Master_Project <= 0 -- Not calculating consolidated for any Project that is NOT a Master Project. See Case 31557
    RETURN @v_total_calcvalue   
  
  -- This function will return the active projectkey to use for processing related projects
  -- Ex: For approved acquisition projects, the returned active projectkey will be its related work projectkey.
  -- For non-approved acquisitions, the returned active projectkey is self
  SELECT @v_active_projectkey = out_projectkey 
  FROM dbo.rpt_get_active_taq_work() 
  WHERE in_projectkey = @i_projectkey
  
  -- Check if client uses alternate currencies  
  SELECT @v_count = COUNT(*)
  FROM clientoptions
  WHERE optionid = 115
  
  IF @v_count > 0
    SELECT @v_allow_alt_currencies = optionvalue
    FROM clientoptions
    WHERE optionid = 115
    
  -- Get the associated itemkey - this is the itemkey we are consolidating from all related projects
  SELECT @v_associtemkey = assocplsummaryitemkey, @v_currencyind = currencyind
  FROM plsummaryitemdefinition
  WHERE plsummaryitemkey = @i_itemkey
    
  -- Default currency to US Dollars
  SELECT @v_default_currency = datacode 
  FROM gentables 
  WHERE tableid = 122 AND qsicode = 2	--US Dollars      
  
  IF @v_allow_alt_currencies = 1
  BEGIN
    -- For clients using alternate currencies, use project's input and approval currency
    SELECT @v_input_currency = COALESCE(plenteredcurrency,0), @v_approval_currency = COALESCE(plapprovalcurrency,0)
    FROM taqproject
    WHERE taqprojectkey = @v_active_projectkey
    
    -- Get the plsummaryitemkey for the Exchange Rate summary item
    SELECT @v_count = COUNT(*)
    FROM plsummaryitemdefinition
    WHERE qsicode = 1  
    
    IF @v_count > 0
      SELECT @v_exchangerate_itemkey = plsummaryitemkey
      FROM plsummaryitemdefinition
      WHERE qsicode = 1    
  END
  ELSE
  BEGIN
    SET @v_input_currency = @v_default_currency
    SET @v_approval_currency = @v_default_currency
  END
  
  -- Default display currency to the input currency of the passed active project, or US Dollars if input currency not set
  IF @i_display_currency > 0
    SELECT @v_display_currency = @i_display_currency
  ELSE IF @v_input_currency > 0
    SET @v_display_currency = @v_input_currency
  ELSE
    SET @v_display_currency = @v_default_currency
  
  -- Loop through all related projects and condolidate the values for the given p&l summary item key 
  DECLARE related_projects_cur CURSOR FOR
    SELECT @v_active_projectkey
    UNION
    SELECT taqprojectkey2 
    FROM taqprojectrelationship 
    WHERE taqprojectkey1 = @v_active_projectkey AND 
      relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1) AND
      relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
    UNION
    SELECT taqprojectkey1
    FROM taqprojectrelationship
    WHERE taqprojectkey2 = @v_active_projectkey AND
      relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0) AND
      relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
  		
  OPEN related_projects_cur

  FETCH related_projects_cur INTO @v_cur_projectkey

  WHILE @@fetch_status = 0
  BEGIN
  
    EXEC qpl_run_pl_calcsql @v_cur_projectkey, @i_plstage, 0, 0, @v_associtemkey, @v_display_currency,
      @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
      
    -- For clients allowing alternate currency, if display currency is different from input currency, 
    -- use the exchange rate to convert currency values to display currency
    IF @v_allow_alt_currencies = 1 AND @v_currencyind = 1
    BEGIN
      SELECT @v_cur_input_currency = plenteredcurrency
      FROM taqproject
      WHERE taqprojectkey = @v_cur_projectkey
      
      IF @v_cur_input_currency <> @v_display_currency
      BEGIN
        EXEC qpl_run_pl_calcsql @v_cur_projectkey, @i_plstage, 0, 0, @v_exchangerate_itemkey, @v_display_currency,
          @v_exchangerate OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        
        SET @v_calcvalue = @v_calcvalue * @v_exchangerate
      END
    END                   
    
    SET @v_total_calcvalue = @v_total_calcvalue + COALESCE(@v_calcvalue,0)
    
    FETCH related_projects_cur INTO @v_cur_projectkey
  END

  CLOSE related_projects_cur 
  DEALLOCATE related_projects_cur

  SET @o_result = @v_total_calcvalue
  RETURN  
	
END
GO

GRANT EXEC ON qpl_calc_consolidated_stage TO PUBLIC
GO
