if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_by_relationship_type') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_relationships_by_relationship_type
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_relationships_by_relationship_type
 (@i_projectkey           integer,
  @i_relationship_qsicode integer,
  @i_useindropdown        integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_relationships_by_relationship_type
**  Desc: This stored procedure returns all relationships
**        from projectrelationshipview for a specific relationshiptype. 
**        NOTE: This is designed to be used in the filter dropdowns in Journals
**              so the number of returned colums needs to be limited for speed
**
**    Auth: Alan Katzen
**    Date: 11 May 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:        Author:         Description:
**    --------     --------        -------------------------------------------
**    06/23/2016   UK			   Case 38574 - Task 003	
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_relationship_datacode INT

  SELECT @v_relationship_datacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = @i_relationship_qsicode

  SELECT distinct prv.relatedprojectkey, prv.relatedprojectname, t.lastmaintdate
    FROM projectrelationshipview prv INNER JOIN taqproject t ON prv.relatedprojectkey = t.taqprojectkey
   WHERE prv.taqprojectkey = @i_projectkey 
     AND prv.relationshipcode = @v_relationship_datacode
ORDER BY prv.relatedprojectname asc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving from projectrelationshipview: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_relationships_by_relationship_type TO PUBLIC
GO


