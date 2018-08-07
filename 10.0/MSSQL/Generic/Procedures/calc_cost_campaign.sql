IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_cost_campaign' ) 
     DROP PROCEDURE calc_cost_campaign 
GO

CREATE PROCEDURE [dbo].[calc_cost_campaign] (  
  @projectkey   INT,
  @firedistkey  INT,
  @result       FLOAT OUTPUT)
AS

/*********************************************************************************************
**  Name: calc_cost_campaign
**  Desc: Misc item calculation - budget costs for a campaign or summed across multiple campaigns
**        for a plan for the specified firedistkey
**
**  Auth: SLB
**  Date: July 27, 2016
**********************************************************************************************/

DECLARE
  @v_count  int,
  @v_usageclass_qsicode int,
  @v_budget_cost  float,
  @v_key1  int,
  @v_key2  int,
  @v_related_projectkey int,
  @v_this_cost  float,
  @v_campaign_key1  int,
  @v_campaign_key2  int,
  @v_campaign_related_projectkey  int
   
  
BEGIN

  SET @result = NULL
  SET @v_budget_cost = 0

  
  -- Get the Usage Class qsicode
  SELECT @v_usageclass_qsicode = s.qsicode
  FROM taqproject p, subgentables s
  WHERE s.tableid = 550 AND
    s.datacode = p.searchitemcode AND
    s.datasubcode = p.usageclasscode AND
    p.taqprojectkey = @projectkey

  IF @v_usageclass_qsicode = 9 --Marketing Campaign
    BEGIN
      SELECT @v_budget_cost = floatvalue 
		  FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey
          WHERE t.taqprojectkey = @projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=@firedistkey)
    END
  ELSE
    BEGIN
    
      DECLARE cur_related_projects CURSOR FOR
        SELECT taqprojectkey1, taqprojectkey2 
        FROM taqprojectrelationship 
        WHERE taqprojectkey1 = @projectkey OR taqprojectkey2 = @projectkey
      
       OPEN cur_related_projects

      FETCH NEXT FROM cur_related_projects INTO @v_key1, @v_key2

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
      
        IF @v_key1 = @projectkey
          SET @v_related_projectkey = @v_key2
        ELSE
          SET @v_related_projectkey = @v_key1
          
		
        SELECT @v_usageclass_qsicode = s.qsicode
        FROM taqproject p, subgentables s
        WHERE s.tableid = 550 AND
          s.datacode = p.searchitemcode AND
          s.datasubcode = p.usageclasscode AND
          p.taqprojectkey = @v_related_projectkey
      
        IF @v_usageclass_qsicode = 9 --Marketing Campaign (9)
          BEGIN
            SELECT @v_count = COUNT(*)
            FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey
              WHERE t.taqprojectkey = @v_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=@firedistkey)

            IF @v_count > 0
            BEGIN
              SELECT @v_this_cost = sum(floatvalue)
			  FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey
              WHERE t.taqprojectkey = @v_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=@firedistkey)

              SET @v_budget_cost = @v_budget_cost + COALESCE(@v_this_cost,0)

            END
          END
          
        FETCH NEXT FROM cur_related_projects INTO @v_key1, @v_key2
      END /* WHILE cur_related_projects */

      CLOSE cur_related_projects 
      DEALLOCATE cur_related_projects
      
    END
    
  SET @result = @v_budget_cost
  
END

GO

GRANT EXEC ON calc_cost_campaign TO PUBLIC
GO
