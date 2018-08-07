if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_sales_goal') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_sales_goal
GO

CREATE PROCEDURE calc_sales_goal (  
  @projectkey   INT,
  @firedistkey  INT,
  @result       FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: calc_sales_goal
**  Desc: Misc item calculation - Sales Goal item of given type.
**
**  Auth: Kate
**  Date: March 16 2009
*******************************************************************************************/

DECLARE
  @v_count  int,
  @v_misckey int,
  @v_misctype int,
  @v_usageclass_qsicode int,
  @v_key1  int,
  @v_key2  int,
  @v_related_projectkey int,
  @v_sales_goal  float,
  @v_this_cost  float  
BEGIN

  SET @result = NULL
  SET @v_sales_goal = 0
  
  -- Get the misckey for the associated marketing campaign firedistkey passed in
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE firedistkey = @firedistkey
  
  IF @v_count = 0
    RETURN
  
  SELECT @v_misckey = misckey, @v_misctype = misctype
  FROM bookmiscitems
  WHERE firedistkey = @firedistkey
  
  -- Get the Usage Class qsicode for the current project
  SELECT @v_usageclass_qsicode = s.qsicode
  FROM taqproject p, subgentables s
  WHERE s.tableid = 550 AND
    s.datacode = p.searchitemcode AND
    s.datasubcode = p.usageclasscode AND
    p.taqprojectkey = @projectkey

  IF @v_usageclass_qsicode = 10 --Marketing Plan
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
      
        IF @v_usageclass_qsicode = 9 --Marketing Campaign
          BEGIN
            SELECT @v_count = COUNT(*)
            FROM taqprojectmisc
            WHERE taqprojectkey = @v_related_projectkey AND misckey = @v_misckey
            
            IF @v_count > 0
            BEGIN
              IF @v_misctype = 1  --Numeric
                SELECT @v_this_cost = longvalue 
                FROM taqprojectmisc
                WHERE taqprojectkey = @v_related_projectkey AND misckey = @v_misckey
              ELSE  --Float
                SELECT @v_this_cost = floatvalue 
                FROM taqprojectmisc
                WHERE taqprojectkey = @v_related_projectkey AND misckey = @v_misckey

              SET @v_sales_goal = @v_sales_goal + COALESCE(@v_this_cost,0)
            END
          END
          
        FETCH NEXT FROM cur_related_projects INTO @v_key1, @v_key2
      END /* WHILE cur_related_projects */

      CLOSE cur_related_projects 
      DEALLOCATE cur_related_projects
      
    END
    
  SET @result = @v_sales_goal
  
END
GO

GRANT EXEC ON calc_sales_goal TO PUBLIC
GO
