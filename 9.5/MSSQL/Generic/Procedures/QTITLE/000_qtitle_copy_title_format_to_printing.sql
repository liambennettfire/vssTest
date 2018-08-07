if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_title_format_to_printing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_title_format_to_printing 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_title_format_to_printing
 (@i_bookkey                integer,
  @i_printingkey            integer,
  @i_userid                 varchar(30),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/***********************************************************************************************************
**  Name: qtitle_copy_title_format_to_printing
**  Desc: This stored procedure will copy title media and format to a printing after we create a printing
**
**  Auth: Uday A. Khisty
**  Date: 11 December 2014
**********************************************************************************************************
**    Change History
**********************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   --------------------------------------
**  04/06/16  Kate      Case 37148 - Copied version on Printing not selected.
**********************************************************************************************************/

DECLARE 
  @v_error  INT,
  @v_lastuserid	VARCHAR(30),
  @v_count INT,
  @v_projectkey INT,
  @v_taqprojectformatkey int,
  @v_cur_versionformatkey	INT,
  @v_cur_stage	INT,
  @v_cur_version INT,
  @v_itemtype_qsicode INT,
  @v_itemtypecode INT,
  @v_usageclass_qsicode INT,
  @v_usageclasscode	INT,
  @v_templateprojectkey INT,
  @v_mediatype  INT,
  @v_mediasubtype INT,
  @v_errordesc	VARCHAR(2000)   
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- COPY THE TITLES MEDIA/FORMAT TO IMPLICITLY CREATED PRINTING
  SELECT @v_count = COUNT(*)
  FROM taqprojectprinting_view
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
    
  IF @v_count > 0
  BEGIN
    SELECT @v_projectkey = taqprojectkey
    FROM taqprojectprinting_view
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
	  
    SELECT @v_itemtype_qsicode = g.qsicode, @v_usageclass_qsicode = sg.qsicode,
      @v_itemtypecode = sg.datacode, @v_usageclasscode = sg.datasubcode 
    FROM taqproject p
      JOIN gentables g ON p.searchitemcode = g.datacode AND g.tableid = 550
      JOIN subgentables sg ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode AND sg.tableid = 550
    WHERE taqprojectkey = @v_projectkey  
	    
    -- Get the most recent active stage on this project that has a selected version
    SELECT @v_cur_stage = dbo.qpl_get_most_recent_stage(@v_projectkey)
	  
    IF @v_cur_stage <= 0	--error occurred or no selected version exists for any active stage on this project
    BEGIN	
      -- Get the most recent stage existing on this project (regardless of whether it has a selected version)
      SELECT TOP(1) @v_cur_stage = g.datacode 
      FROM gentablesitemtype gi, gentables g, taqplstage p
      WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
        AND p.plstagecode = g.datacode AND p.taqprojectkey = @v_projectkey
        AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtypecode 
        AND (gi.itemtypesubcode = @v_usageclasscode OR gi.itemtypesubcode = 0)
      ORDER BY gi.sortorder DESC, g.sortorder DESC
	    
      IF @v_cur_stage <= 0	--no stages exist on this project
      BEGIN
        -- Get the first active stage for this project's Item Type and Usage Class
        SELECT TOP(1) @v_cur_stage = g.datacode FROM gentablesitemtype gi, gentables g
        WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
          AND gi.tableid = 562 AND gi.itemtypecode = @v_itemtypecode
          AND (gi.itemtypesubcode = @v_usageclasscode OR gi.itemtypesubcode = 0)
        ORDER BY gi.sortorder ASC, g.sortorder ASC
	      
        IF @v_cur_stage IS NULL
          SET @v_cur_stage = 0
      END
    END
	  
    -- Get the selected version for the most recent active stage on the project
    SELECT @v_cur_version = selectedversionkey 
    FROM taqplstage 
    WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_cur_stage
	  
    IF @v_cur_version IS NULL OR @v_cur_version = 0	--no selected version exist for any active stage on this project
    BEGIN
      -- Check if a version already exists (may have been copied from title acquisition)
      SELECT @v_count = COUNT(*)
      FROM taqversion
      WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_cur_stage

      IF @v_count = 1
      BEGIN
        SELECT @v_cur_version = taqversionkey
        FROM taqversion
        WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_cur_stage
      END
      ELSE
      BEGIN
        -- Get the next versionkey to use for this stage
        SELECT @v_cur_version = COALESCE(MAX(taqversionkey),0) + 1 
        FROM taqversion 
        WHERE taqprojectkey = @v_projectkey
      END
    END
	  
    --PRINT 'calling qpl_check_taqversion from qtitle_copy_title_format_to_printing'
    --PRINT '@v_projectkey=' + convert(varchar, @v_projectkey)
    --PRINT '@v_cur_stage=' + convert(varchar, @v_cur_stage)
    --PRINT '@v_cur_version=' + convert(varchar, @v_cur_version)
	  
    -- Call the stored procedure that will check if this version exists, and if not, it will add it.
    -- It will also add taqversionformat row if none exist for the version (in which case the generated taqversionformatkey will be passed out).
    EXEC qpl_check_taqversion @v_projectkey, @v_cur_stage, @v_cur_version, 
      @v_cur_versionformatkey OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT
	  
    IF @v_error < 0 BEGIN
      SET @o_error_desc = @v_errordesc
      SET @o_error_code = @v_error
      return
    END  
	 
    SELECT @v_count = COUNT(*)
    FROM taqversionformat
    WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version

    IF @v_count > 0
    BEGIN
      SELECT @v_mediatype = d.mediatypecode, @v_mediasubtype = d.mediatypesubcode
      FROM bookdetail d
      WHERE d.bookkey = @i_bookkey
	    
      UPDATE taqversionformat 
      SET mediatypecode = @v_mediatype, mediatypesubcode = @v_mediasubtype, lastuserid = @i_userid, lastmaintdate = GETDATE()
      WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_cur_stage AND taqversionkey = @v_cur_version 
    END  
  END  
  
END
GO

GRANT EXEC ON qtitle_copy_title_format_to_printing TO PUBLIC
GO
