IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_printing_formats_for_relate') )
DROP PROCEDURE dbo.qproject_get_printing_formats_for_relate
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_printing_formats_for_relate]
 (@i_projectkey				integer,
  @i_taqprojectformatkey	integer,
  @o_error_code				integer output,
  @o_error_desc				varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_printing_formats_for_relate
**  Desc: This stored procedure returns all related projects that match
**		  the specified itemtype/usageclass (or all if 0 itemtype/usageclass)
**
**    Auth: Dustin Miller
**    Date: April 19 2016
**
*******************************************************************************/

DECLARE @error_var    INT

BEGIN

  DECLARE @v_itemtypecode INT
  DECLARE @v_usageclasscode INT

  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 14

  SELECT @v_usageclasscode = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtypecode
	AND qsicode = 40

  SELECT prv.relatedprojectkey, prv.relatedprojectname,
  tpr.searchitemcode as relateditemtypecode, tpr.usageclasscode as relatedusageclasscode,
  tpr.taqprojectstatuscode as relatedstatus, tpr.taqprojecttype as relatedtype, tpo.orgentrykey as relatedorgentrykey,
  tprr.relationshipcode1, tprr.relationshipcode2,
  tvf.taqprojectformatkey as relatedformatkey
  FROM projectrelationshipview prv
  JOIN taqproject tpr
  ON prv.relatedprojectkey = tpr.taqprojectkey
  JOIN taqprojectrelationship tprr
  ON prv.taqprojectrelationshipkey = tprr.taqprojectrelationshipkey
  JOIN taqversionformat tvf
  ON prv.relatedprojectkey = tvf.taqprojectkey
  LEFT JOIN taqprojectorgentry tpo
  ON prv.relatedprojectkey = tpo.taqprojectkey
  WHERE prv.taqprojectkey = @i_projectkey
    AND tpr.searchitemcode = @v_itemtypecode
	AND tpr.usageclasscode = @v_usageclasscode
	AND NOT EXISTS (SELECT * FROM taqversionformatrelatedproject WHERE taqprojectkey = @i_projectkey AND taqversionformatkey = @i_taqprojectformatkey
					AND relatedprojectkey = prv.relatedprojectkey AND relatedversionformatkey = tvf.taqprojectformatkey)
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Failed to find projectrelationshipview data (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

END
go

GRANT EXEC ON qproject_get_printing_formats_for_relate TO PUBLIC
GO

