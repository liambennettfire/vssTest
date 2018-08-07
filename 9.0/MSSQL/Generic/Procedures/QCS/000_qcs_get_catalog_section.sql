IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_catalog_section]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_catalog_section]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_section]
 (@i_projectkey               integer,
  @i_relationshiptype_qsicode integer)
AS

DECLARE
  @v_relationshiptype_datacode  INT,
  @v_visibility	VARCHAR(10),
  @error_var    INT,
  @rowcount_var INT,
  @errorDesc	NVARCHAR(2000)
          
BEGIN
  SET @v_visibility = 'NONE'
  IF @i_relationshiptype_qsicode = 21 OR @i_relationshiptype_qsicode = 19 BEGIN
	SET @v_visibility = 'SEARCH'
  END
  ELSE IF @i_relationshiptype_qsicode = 31 BEGIN
	SET @v_visibility = 'BROWSE'
  END

  SELECT @v_relationshiptype_datacode = datacode 
    FROM gentables 
   WHERE tableid = 582 and qsicode = @i_relationshiptype_qsicode
    
  SELECT rv.taqprojectrelationshipkey,rv.relatedprojectkey,@v_visibility typetag,0 summarymode,rv.relatedprojectname as "name",
         rv.relatedprojectname as "label",'' as "description",
         (select eloquencefieldtag from gentables where tableid = 647 and datacode = r.datacode1) displaytypetag,
         (select eloquencefieldtag from gentables where tableid = 648 and datacode = r.datacode2) ordertypetag,
         COALESCE(r.quantity1,99999) ordernumber
    FROM taqprojectrelationship r, projectrelationshipview rv
   WHERE r.taqprojectrelationshipkey = rv.taqprojectrelationshipkey
     AND rv.taqprojectkey = @i_projectkey
     AND rv.relationshipcode = @v_relationshiptype_datacode 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @errorDesc = 'Error retrieving catalog section info (projectkey = ' + cast(@i_projectkey as varchar) + '/qsicode = ' + cast(@i_relationshiptype_qsicode as varchar) + ')'
    RAISERROR(@errorDesc, 16, 1)
	return   
  END 
END
GO

GRANT EXEC ON qcs_get_catalog_section TO PUBLIC
GO
