IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_total_cost_budget_HMH' ) 
     DROP PROCEDURE calc_total_cost_budget_HMH 
GO

CREATE PROCEDURE [dbo].[calc_total_cost_budget_HMH] (
  @projectkey INT,
  @result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_total_cost_budget_HMH
**  Desc: Misc item calculation - Total Budget from Campaign.  Used by both Campaigns and 
**        Projects
**
**  Auth: SLB
**  Date: July 27 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:    Author:          Description:
**    --------  --------        --------------------------------------------------------
**    
********************************************************************************************/
  
BEGIN
DECLARE
    @v_usageclass_qsicode int,
    @v_budget_cost  float
   
   SET @v_budget_cost = 0
   SET @result = 0

-- Get the Usage Class qsicode
  SELECT @v_usageclass_qsicode = s.qsicode
  FROM taqproject p, subgentables s
  WHERE s.tableid = 550 AND
    s.datacode = p.searchitemcode AND
    s.datasubcode = p.usageclasscode AND
    p.taqprojectkey = @projectkey

  IF @v_usageclass_qsicode = 9 --Marketing Campaign
    BEGIN
    --Coop (61) taken out from HMH Total 
	  SELECT @result = COALESCE(SUM(floatvalue),0)
	  FROM taqprojectmisc
	  WHERE taqprojectkey = @projectkey AND
		  misckey IN (SELECT misckey 
					  FROM bookmiscitems 
					  WHERE firedistkey IN (57,58,59,60,62,63,76,77,78,79,80,133))
    END
  ELSE
    BEGIN
	    EXEC calc_cost_campaign @projectkey,57, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,58, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	 
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,59, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,60, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	    SET @v_budget_cost = 0
	/*  Coop is not to be added into Total for HMH */
	    --EXEC calc_cost_campaign @projectkey,61, @v_budget_cost OUTPUT
	    --SET @result = @result + @v_budget_cost	    
	    --SET @v_budget_cost = 0 
	    EXEC calc_cost_campaign @projectkey,62, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	    
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,63, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	 
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,76, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,77, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,78, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost			         
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,79, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,80, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	    SET @v_budget_cost = 0
	    EXEC calc_cost_campaign @projectkey,133, @v_budget_cost OUTPUT
	    SET @result = @result + @v_budget_cost	
	 END
END

GO

GRANT EXEC ON calc_total_cost_budget_HMH TO PUBLIC
GO

