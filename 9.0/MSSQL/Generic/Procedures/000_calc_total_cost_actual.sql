if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_total_cost_actual') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_total_cost_actual
GO

CREATE PROCEDURE calc_total_cost_actual (  
  @projectkey   INT,
  @result       FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_total_cost_actual
**  Desc: Misc item calculation - Total Actual Cost.
**
**  Auth: Kate
**  Date: March 4 2009
*******************************************************************************************/

DECLARE
  @v_count  int,
  @v_key1 int,
  @v_key2 int,
  @v_related_projectkey int,
  @v_usageclass_qsicode int,
  @v_total_actual_cost  float,
  @v_campaign_key1  int,
  @v_campaign_key2  int,
  @v_campaign_related_projectkey  int,
  @v_this_cost	float
  
BEGIN

  SET @result = NULL
  SET @v_total_actual_cost = 0
   
  -- Get the Usage Class qsicode
  SELECT @v_usageclass_qsicode = s.qsicode
  FROM taqproject p, subgentables s
  WHERE s.tableid = 550 AND
    s.datacode = p.searchitemcode AND
    s.datasubcode = p.usageclasscode AND
    p.taqprojectkey = @projectkey

  IF @v_usageclass_qsicode = 3 OR @v_usageclass_qsicode = 7 --Marketing Project (3) or Marketing Exhibit (7)
    BEGIN
      SELECT @v_total_actual_cost = COALESCE(SUM(floatvalue),0)
      FROM taqprojectmisc
      WHERE taqprojectkey = @projectkey AND
          misckey IN (SELECT misckey 
                      FROM bookmiscitems 
                      WHERE firedistkey IN (49,50,51,52,53,54,55,82,83,84,85,86))
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
      
        IF @v_usageclass_qsicode = 3 OR @v_usageclass_qsicode = 7 --Marketing Project (3) or Marketing Exhibit (7)
          BEGIN
            SELECT @v_this_cost = COALESCE(SUM(floatvalue),0)
            FROM taqprojectmisc
            WHERE taqprojectkey = @v_related_projectkey AND
                misckey IN (SELECT misckey 
                            FROM bookmiscitems 
                            WHERE firedistkey IN (49,50,51,52,53,54,55,82,83,84,85,86))
            
            SET @v_total_actual_cost = @v_total_actual_cost + @v_this_cost
          END
        ELSE IF @v_usageclass_qsicode = 9 --Marketing Campaign (9)
          BEGIN
            DECLARE cur_related_campaign_projects CURSOR FOR
              SELECT taqprojectkey1, taqprojectkey2 
              FROM taqprojectrelationship 
              WHERE taqprojectkey1 = @v_related_projectkey OR taqprojectkey2 = @v_related_projectkey

            OPEN cur_related_campaign_projects

            FETCH NEXT FROM cur_related_campaign_projects INTO @v_campaign_key1, @v_campaign_key2

            WHILE (@@FETCH_STATUS <> -1)
            BEGIN
                          
              IF @v_campaign_key1 = @v_related_projectkey
                SET @v_campaign_related_projectkey = @v_campaign_key2
              ELSE
                SET @v_campaign_related_projectkey = @v_campaign_key1            
            
              SELECT @v_usageclass_qsicode = s.qsicode
              FROM taqproject p, subgentables s
              WHERE s.tableid = 550 AND
                s.datacode = p.searchitemcode AND
                s.datasubcode = p.usageclasscode AND
                p.taqprojectkey = @v_campaign_related_projectkey
                
              IF @v_usageclass_qsicode = 3 OR @v_usageclass_qsicode = 7 --Mktg Project (3) or Mktg Exhibit (7)
              BEGIN
                SELECT @v_this_cost = COALESCE(SUM(floatvalue),0)
                FROM taqprojectmisc
                WHERE taqprojectkey = @v_campaign_related_projectkey AND
                    misckey IN (SELECT misckey 
                                FROM bookmiscitems 
                                WHERE firedistkey IN (49,50,51,52,53,54,55,82,83,84,85,86))
                
                SET @v_total_actual_cost = @v_total_actual_cost + @v_this_cost
              END
              
              FETCH NEXT FROM cur_related_campaign_projects INTO @v_campaign_key1, @v_campaign_key2
            END /* WHILE cur_related_campaign_projects */
            
            CLOSE cur_related_campaign_projects 
            DEALLOCATE cur_related_campaign_projects            
          END
          
        FETCH NEXT FROM cur_related_projects INTO @v_key1, @v_key2
      END /* WHILE cur_related_projects */

      CLOSE cur_related_projects 
      DEALLOCATE cur_related_projects
      
    END
    
  SET @result = @v_total_actual_cost
  
END
GO

GRANT EXEC ON calc_total_cost_actual TO PUBLIC
GO
