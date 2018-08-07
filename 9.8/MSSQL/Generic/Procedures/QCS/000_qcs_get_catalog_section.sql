/****** Object:  StoredProcedure [dbo].[qcs_get_catalog_section]    Script Date: 8/3/2016 3:52:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_catalog_section]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_catalog_section]
GO

/****** Object:  StoredProcedure [dbo].[qcs_get_catalog_section]    Script Date: 8/3/2016 3:52:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_catalog_section]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[qcs_get_catalog_section] AS' 
END
GO

--modified 8/3/16 BL: added order by project type so that sections would be sent to the cloud in series,set, imprint order to resolve an issue with imprint =belknap press making into the HUP prod detail breadcrumb


ALTER PROCEDURE [dbo].[qcs_get_catalog_section]
 (@i_projectkey               integer,
  @i_relationshiptype_qsicode integer)
AS

DECLARE
  @v_relationshiptype_datacode  INT,
  @v_visibility	VARCHAR(10),
  @error_var    INT,
  @rowcount_var INT,
  @errorDesc	NVARCHAR(2000),
  @i_displaytypemisckey int,
  @i_displaytypegencode int
          
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

  select @i_displaytypemisckey = misckey from bookmiscitems where qsicode=34 
  select @i_displaytypegencode = datacode from gentables where tableid = 525 and qsicode=2
   
  SELECT rv.taqprojectrelationshipkey,
         rv.relatedprojectkey,
         @v_visibility visibility,
         0 summarymode,
         rv.relatedprojectname as "name",
         rv.relatedprojectname as "label",
         '' as "description",
         (select eloquencefieldtag from gentables where tableid = 521 and datacode = p.taqprojecttype) 'type',
         (select eloquencefieldtag from gentables where tableid = 647 and datacode = r.datacode1) displaytypetag,
         (select eloquencefieldtag from gentables where tableid = 648 and datacode = r.datacode2) ordertypetag,
         COALESCE(r.quantity1,99999) ordernumber,
		 (select eloquencefieldtag from subgentables where tableid = 525 and datacode = @i_displaytypegencode and datasubcode=tm.longvalue) titledisplaytype
    FROM taqprojectrelationship r 
	inner join Projectrelationshipview rv on r.taqprojectrelationshipkey = rv.taqprojectrelationshipkey
	inner join taqproject p on rv.relatedprojectkey = p.taqprojectkey
	left outer join taqprojectmisc tm on p.taqprojectkey =tm.taqprojectkey and tm.misckey=@i_displaytypemisckey
   WHERE 
     rv.taqprojectkey = @i_projectkey
	 AND rv.relationshipcode = @v_relationshiptype_datacode 
	 order by p.taqprojecttype desc

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @errorDesc = 'Error retrieving catalog section info (projectkey = ' + cast(@i_projectkey as varchar) + '/qsicode = ' + cast(@i_relationshiptype_qsicode as varchar) + ')'
    RAISERROR(@errorDesc, 16, 1)
	return   
  END 
END





GO

GRANT EXECUTE ON [dbo].[qcs_get_catalog_section] TO [public] AS [dbo]
GO


