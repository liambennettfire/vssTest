IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_related_project_by_class') )
DROP PROCEDURE dbo.qproject_get_related_project_by_class
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_related_project_by_class]
 (@i_projectkey     integer,
  @i_itemtypecode	integer,
  @i_usageclasscode integer,
  @i_orglevelkey	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_related_project_by_class
**  Desc: This stored procedure returns all related projects that match
**		  the specified itemtype/usageclass (or all if 0 itemtype/usageclass)
**
**    Auth: Dustin Miller
**    Date: April 19 2016
**
*******************************************************************************/

DECLARE @error_var    INT

BEGIN

  SELECT prv.relatedprojectkey, prv.relatedprojectname,
  tpr.searchitemcode as relateditemtypecode, tpr.usageclasscode as relatedusageclasscode,
  tpr.taqprojectstatuscode as relatedstatus, tpr.taqprojecttype as relatedtype, tpo.orgentrykey as relatedorgentrykey,
  tprr.relationshipcode1, tprr.relationshipcode2
  FROM projectrelationshipview prv
  JOIN taqproject tpr
  ON prv.relatedprojectkey = tpr.taqprojectkey
  JOIN taqprojectrelationship tprr
  ON prv.taqprojectrelationshipkey = tprr.taqprojectrelationshipkey
  LEFT JOIN taqprojectorgentry tpo
  ON prv.relatedprojectkey = tpo.taqprojectkey AND (COALESCE(@i_orglevelkey, 0) = 0 OR tpo.orglevelkey = @i_orglevelkey)
  WHERE prv.taqprojectkey = @i_projectkey
    AND (COALESCE(@i_itemtypecode, 0) = 0 OR tpr.searchitemcode = @i_itemtypecode)
	AND (COALESCE(@i_usageclasscode, 0) = 0 OR tpr.usageclasscode = @i_usageclasscode)
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Failed to find projectrelationshipview data (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

END
go

GRANT EXEC ON qproject_get_related_project_by_class TO PUBLIC
GO

