
/****** Object:  StoredProcedure [dbo].[qcs_get_catalog_section]    Script Date: 07/07/2015 08:50:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_get_catalog_section]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_get_catalog_section]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_section]
 (@i_projectkey               integer,
  @i_relationshiptype_qsicode integer,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

DECLARE
  @v_relationshiptype_datacode  INT,
  @error_var    INT,
  @rowcount_var INT
          
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_relationshiptype_datacode = datacode 
    FROM gentables 
   WHERE tableid = 582 and qsicode = @i_relationshiptype_qsicode
    
  SELECT rv.taqprojectrelationshipkey,rv.relatedprojectkey,'BROWSE' typetag,0 summarymode,rv.relatedprojectname as "name",
         rv.relatedprojectname as "label",--'' as "description",
         (select eloquencefieldtag from gentables where tableid = 647 and datacode = r.datacode1) displaytypetag,
         (select eloquencefieldtag from gentables where tableid = 648 and datacode = r.datacode2) ordertypetag,
         COALESCE(r.quantity1,99999) ordernumber
    FROM taqprojectrelationship r, projectrelationshipview rv
   WHERE r.taqprojectrelationshipkey = rv.taqprojectrelationshipkey
     AND rv.taqprojectkey = @i_projectkey
     AND rv.relationshipcode = @v_relationshiptype_datacode 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error retrieving catalog section info (projectkey = ' + cast(@i_projectkey as varchar) + '/qsicode = ' + cast(@i_relationshiptype_qsicode as varchar) + ')'
    return   
  END 
END


GO

grant execute on dbo.qcs_get_catalog_section  to public
go
