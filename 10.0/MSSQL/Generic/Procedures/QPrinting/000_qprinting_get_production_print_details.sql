if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_production_print_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qprinting_get_production_print_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qprinting_get_production_print_details
 (@i_projectkey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_get_production_print_details
**  Desc: This procedure returns associated formats with the given contract workkey,
**				if no workkey, it will find formats for all works associated with contractprojkey
**
**	Auth: Dustin Miller
**	Date: February 24 2017
*******************************************************************************/

  DECLARE @v_workbookkey			 INT,
					@v_printrunitemcode  INT,
					@v_printrunusagecode INT,
					@v_printrunname      VARCHAR(255),
					@v_printrunkey       INT,
					@v_speccategorykey	 INT,
					@v_error						 INT,
          @v_rowcount					 INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

	--Spec Category Key for Summary
	SELECT TOP 1 @v_speccategorykey = taqversionspecategorykey
	FROM taqversionspeccategory
	WHERE taqprojectkey = @i_projectkey
	    AND itemcategorycode = (SELECT datacode FROM gentables WHERE tableid = 616 AND qsicode = 1)
	  --AND speccategorydescription = 'Summary'

	--Print Run
	SET @v_printrunitemcode = 0 
	SELECT @v_printrunitemcode = datacode
	FROM gentables
	WHERE tableid = 550
	  AND qsicode = 15

	SET @v_printrunusagecode = 0
	SELECT @v_printrunusagecode = datasubcode
	FROM subgentables
	WHERE tableid = 550
	  AND datacode = @v_printrunitemcode
		AND qsicode = 60

	SELECT DISTINCT TOP 1 @v_printrunkey = prv.relatedprojectkey, @v_printrunname = prv.relatedprojectname
  FROM projectrelationshipview prv
  JOIN taqproject tpr
  ON prv.relatedprojectkey = tpr.taqprojectkey
  JOIN taqprojectrelationship tprr
  ON prv.taqprojectrelationshipkey = tprr.taqprojectrelationshipkey
  LEFT JOIN taqprojectorgentry tpo
  ON prv.relatedprojectkey = tpo.taqprojectkey
  WHERE prv.taqprojectkey = @i_projectkey
    AND (COALESCE(@v_printrunitemcode, 0) = 0 OR tpr.searchitemcode = @v_printrunitemcode)
	  AND (COALESCE(@v_printrunusagecode, 0) = 0 OR tpr.usageclasscode = @v_printrunusagecode)

	
  SELECT p.taqprojecttitle, p.taqprojecttype, p.taqprojectstatuscode,
      @v_printrunkey printrunkey, @v_printrunname printrunname,
			@v_speccategorykey specategorykey
  FROM taqproject p
  join coreprojectinfo c on p.taqprojectkey = c.projectkey
  join taqprojectprinting_view tp on tp.taqprojectkey = c.projectkey
  left join qsiusers u on p.taqprojectownerkey = u.userkey  -- until we fix the cleanup of deleting qsiuser records, this will have to be an outer join
  LEFT JOIN taqprojectrights r ON r.taqprojectprintingkey = p.taqprojectkey
  LEFT JOIN taqproject rp ON rp.taqprojectkey = r.taqprojectkey
  WHERE p.taqprojectkey = @i_projectkey 

	-- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 
GO

GRANT EXEC ON qprinting_get_production_print_details TO PUBLIC
GO