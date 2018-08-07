IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'calc_cost_actual_by_project_type' ) 
     DROP PROCEDURE calc_cost_actual_by_project_type 
GO
  
CREATE PROCEDURE [dbo].[calc_cost_actual_by_project_type] (    
  @projectkey   INT,  
  @firedistkey  INT,  
  @result       FLOAT OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: calc_cost_actual_by_project_type  
**  Desc: Misc item calculation - Actual Cost of given type by project type.  
**  
**  Auth: Navroop  
**  Date: April 3 2014  
*******************************************************************************************/  
  
DECLARE  
  @v_count  int,  
  @v_misckey  int,  
  @v_usageclass_qsicode int,  
  @v_actual_cost  float,  
  @v_key1  int,  
  @v_key2  int,  
  @v_related_projectkey int,  
  @v_this_cost  float,  
  @v_campaign_key1  int,  
  @v_campaign_key2  int,  
  @v_campaign_related_projectkey  int  
     
    
BEGIN  
  
  SET @result = NULL  
  SET @v_actual_cost = 0  
    
  SELECT @v_count = COUNT(*)  
            FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
              WHERE misckey in (Select misckey from bookmiscitems where firedistkey=134)  
    and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
    
  IF @v_count = 0  
    RETURN  
  
  SELECT @v_misckey = misckey  
  FROM bookmiscitems  
  WHERE firedistkey = @firedistkey  
    
  -- Get the Usage Class qsicode  
  SELECT @v_usageclass_qsicode = s.qsicode  
  FROM taqproject p, subgentables s  
  WHERE s.tableid = 550 AND  
    s.datacode = p.searchitemcode AND  
    s.datasubcode = p.usageclasscode AND  
    p.taqprojectkey = @projectkey  
  
  IF @v_usageclass_qsicode = 3 OR @v_usageclass_qsicode = 7 --Marketing Project (3) or Marketing Exhibit (7)  
    BEGIN  
      SELECT @v_actual_cost = floatvalue   
    FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
          WHERE t.taqprojectkey = @projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=134)  
   and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
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
            SELECT @v_count = COUNT(*)  
            FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
              WHERE t.taqprojectkey = @v_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=134)  
    and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
  
            IF @v_count > 0  
            BEGIN  
              SELECT @v_this_cost = sum(floatvalue)  
     FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
              WHERE t.taqprojectkey = @v_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=134)  
    and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
      
  
              SET @v_actual_cost = @v_actual_cost + COALESCE(@v_this_cost,0)  
  
            END  
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
            SELECT @v_count = COUNT(*)  
            FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
              WHERE t.taqprojectkey = @v_campaign_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=134)  
    and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
               
               
              IF @v_count > 0  
                BEGIN  
              SELECT @v_this_cost = sum(floatvalue)  
     FROM taqprojectmisc m join taqproject t on t.taqprojectkey=m.taqprojectkey  
              WHERE t.taqprojectkey = @v_campaign_related_projectkey AND misckey in (Select misckey from bookmiscitems where firedistkey=134)  
    and t.taqprojecttype in (Select datacode from gentables where tableid=521 and externalcode=CAST (@firedistkey AS varchar(30)) )  
                    
                  SET @v_actual_cost = @v_actual_cost + COALESCE(@v_this_cost,0)         
    
                END  
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
      
  SET @result = @v_actual_cost  
    
END  


GO


GRANT EXEC ON calc_cost_actual_by_project_type TO PUBLIC
GO
