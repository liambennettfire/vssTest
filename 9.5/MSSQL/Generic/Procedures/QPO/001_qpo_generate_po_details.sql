/****** Object:  StoredProcedure [dbo].[qpo_generate_po_details]    Script Date: 04/01/2015 15:23:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_generate_po_details]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_generate_po_details]
GO

/****** Object:  StoredProcedure [dbo].[qpo_generate_po_details]    Script Date: 04/01/2015 15:23:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qpo_generate_po_details]
 (@i_report_projectkey  integer,
  @i_po_projectkey      integer,
  @i_gpokey             integer,
  @i_report_detail_type integer,
  @i_lastuserid         varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: po_generate_po_details
**  Desc: This procedure will be called from the Generate PO Report Function.
**        New projectkey key (PO report), related project key (PO Summary) and gpokey will be passed in. 
**
**	Auth: Kusum
**	Date: 06 August 2014
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  10/15/15    Kate      Rewritten
**  06/07/16    Kusum     Case 37691
**  10/07/16    Dustin	  Added gposection and gposubsection finishedgoodind
**  01/11/17    Uday	  Case 42531
*******************************************************************************/

DECLARE
  @v_bookkey  INT,
  @v_categorydesc VARCHAR(255),
  @v_categorykey  INT,
  @v_commentkey INT,
  @v_commenttext NVARCHAR(MAX),
  @v_commenttype_project  INT,
  @v_commentsubtype_top INT,
  @v_count  INT,
  @v_culturecode  INT,
  @v_date_string  VARCHAR(10),
  @v_decimalvalue FLOAT,
  @v_defaultuomcode INT,
  @v_detail VARCHAR(2000),
  @v_write_detail TINYINT,
  @v_detaillinenbr  INT,
  @v_desc1  VARCHAR(2000),
  @v_desc2  VARCHAR(2000),
  @v_duedate  DATETIME,
  @v_error  INT,
  @v_externalcode_int INT,
  @v_externalcode_str VARCHAR(30),
  @v_is_first_component TINYINT,
  @v_itemcategorycode INT,
  @v_itemcode INT,  
  @v_itemdesc VARCHAR(100),
  @v_itemdetaildesc VARCHAR(100),
  @v_itemlabel VARCHAR(255),
  @v_itemqty  INT,
  @v_itemtype INT,
  @v_itemtype_printing  INT,
  @v_itemtype_PO  INT,
  @v_key1 INT,
  @v_key2 INT,
  @v_key3 INT,
  @v_lastuserid VARCHAR(30),
  @v_loopnum  INT,
  @v_misckey  INT,
  @v_new_detailkey  INT,
  @v_new_sectionkey INT,
  @v_new_subsectionkey  INT,
  @v_num_items  INT,
  @v_num_notes  INT,
  @v_num_relatedprojects  INT,
  @v_po_formatkey INT,
  @v_printingkey  INT,
  @v_printingnum  INT,
  @v_prodnum  VARCHAR(50),
  @v_prodnum_label  VARCHAR(40),
  @v_productnumber VARCHAR(50),
  @v_productnumber2 VARCHAR(50),
  @v_productnumberstring VARCHAR(255),
  @v_projectdesc  VARCHAR(255),
  @v_projectkey INT,
  @v_quantity INT,
  @v_relatedcategorykey INT,
  @v_report_detail_display_type INT,
  @v_rowcount INT,
  @v_sectiondesc  VARCHAR(100),
  @v_sectiontype  INT,
  @v_sectiontype_title_prtg INT,
  @v_sectiontype_title_prtg_comp  INT,
  @v_sectiontype_project  INT,
  @v_sectiontype_project_comp INT,
  @v_showdecimalind TINYINT,
  @v_showdecimallabel VARCHAR(255),
  @v_showdescind  TINYINT,
  @v_showdesclabel  VARCHAR(255),
  @v_showdesc2ind TINYINT,
  @v_showdesc2label VARCHAR(255), 
  @v_showqtyind TINYINT,
  @v_showqtylabel VARCHAR(255),
  @v_showunitofmeasureind TINYINT,
  @v_sortorder_projects INT,
  @v_summary_component INT,
  @v_taqtasknote  VARCHAR(2000),
  @v_taskdesc VARCHAR(255),
  @v_title  VARCHAR(255),
  @v_top_instructions_added TINYINT,
  @v_top_instructions_commenttext NVARCHAR(MAX),
  @v_usageclass INT,
  @v_usageclass_PO  INT,
  @v_userkey  INT,
  @v_uomdesc  VARCHAR(40),
  @v_gpo_finishedgoodind TINYINT
 
 BEGIN

  --PRINT '@i_gpokey: ' + CONVERT(VARCHAR, @i_gpokey)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_detaillinenbr = 0
       
  SELECT @v_count = COUNT(*) 
  FROM taqversionrelatedcomponents_view
  WHERE taqprojectkey = @i_po_projectkey  

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to generate po details: Error accessing taqversionrelatedcomponents_view to verify components.'
    RETURN  
  END 
  
  IF @v_count <= 0 BEGIN
    print 'No taqversionrelatedcomponents_view records for the related projectkey: ' + cast(@i_po_projectkey as varchar) + '.'
    RETURN    
  END
  
  IF @i_lastuserid IS NULL
    SET @v_lastuserid = 'QSIADMIN'
  ELSE
    SET @v_lastuserid = @i_lastuserid

  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @v_lastuserid
  
  IF @i_report_detail_type > 0
    SET @v_report_detail_display_type = @i_report_detail_type
  ELSE
  BEGIN
    SELECT @v_misckey = misckey 
    FROM bookmiscitems 
    WHERE datacode = (SELECT datacode FROM gentables WHERE tableid = 525 AND qsicode = 1)  --Report Specification Detail Type
  
    SELECT @v_report_detail_display_type = longvalue 
    FROM taqprojectmisc 
    WHERE taqprojectkey = @i_report_projectkey AND misckey = @v_misckey

    IF @v_report_detail_display_type IS NULL OR @v_report_detail_display_type = 0 
      SELECT @v_report_detail_display_type = longvalue FROM bookmiscdefaults WHERE misckey = @v_misckey
  END
  
  SELECT @v_itemtype_printing = datacode FROM gentables WHERE tableid = 550 AND qsicode = 14 --Printing  
  SELECT @v_summary_component = datacode FROM gentables WHERE tableid = 616 and qsicode = 1     
 
  SELECT @v_sectiontype_title_prtg = datacode FROM gentables WHERE tableid = 249 AND qsicode = 2 --title/printing
  SELECT @v_sectiontype_title_prtg_comp = datacode FROM gentables WHERE tableid = 249 AND qsicode = 3 --title/printing/component
  SELECT @v_sectiontype_project = datacode FROM gentables WHERE tableid = 249 AND qsicode = 6 --project
  SELECT @v_sectiontype_project_comp = datacode FROM gentables WHERE tableid = 249 AND qsicode = 7 --project/component
 
  IF @v_report_detail_display_type IS NULL
    SET @v_report_detail_display_type = 0

  --PRINT '@v_report_detail_display_type=' + CONVERT(VARCHAR, @v_report_detail_display_type)
  
  -- Refresh everything for this gpokey - delete and then reinsert  
  IF @i_gpokey > 0
  BEGIN
    DELETE FROM gpodetail WHERE gpokey = @i_gpokey 
      
    DELETE FROM gposubsection WHERE gpokey = @i_gpokey 
     
    DELETE FROM gposection WHERE gpokey = @i_gpokey
    
    DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype IS NULL
    
    DELETE FROM gpocost WHERE gpokey = @i_gpokey
  END

  -- Get the Item Type and Usage Class of the passed related project (PO Summary project)
  SELECT @v_itemtype_PO = searchitemcode, @v_usageclass_PO = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_po_projectkey

  -- Get the culture for the project we are generating details from - @i_po_projectkey (which is the Purchase Order)
  SELECT @v_culturecode = projectculturecode FROM dbo.get_culture(@v_userkey, @i_po_projectkey, 0)

  --PRINT '@v_culturecode=' + CONVERT(VARCHAR, @v_culturecode)
  
  -- Check if single or multiple related projects exist for this PO
  SELECT @v_num_relatedprojects = COUNT(DISTINCT taqversionformatkey)
  FROM taqversionrelatedcomponents_view 
  WHERE taqprojectkey = @i_po_projectkey

  --PRINT '@v_num_relatedprojects=' + CONVERT(VARCHAR, @v_num_relatedprojects)

  -- If "PO Top Line Detail Instructions" Project comment is valid for the current PO usage class, we will need to write out the comment
  -- at the very top of all details. Get the comment here (@v_top_instructions_commenttext), outside of the loop.
  SELECT @v_commenttype_project = datacode, @v_commentsubtype_top = datasubcode --Project comment type; PO Top Level Detail Instruction comment subtype
  FROM subgentables
  WHERE tableid = 284 AND qsicode = 8

  SET @v_top_instructions_added = 0
  SET @v_top_instructions_commenttext = NULL

  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 284 
  AND datacode = @v_commenttype_project --Project comment
    AND datasubcode = @v_commentsubtype_top  --PO Top Level PO Detail Instructions
    AND itemtypecode = @v_itemtype_PO
    AND itemtypesubcode = @v_usageclass_PO

  IF @v_count > 0 --Comment is valid for the related PO's item type/usage class
  BEGIN
    -- Check if comment exists on the PO
    SELECT @v_count = COUNT(*)
    FROM taqprojectcomments 
    WHERE taqprojectkey = @i_po_projectkey
      AND commenttypecode = @v_commenttype_project
      AND commenttypesubcode = @v_commentsubtype_top

    SET @v_commentkey = 0
    IF @v_count > 0
      SELECT @v_commentkey = commentkey
      FROM taqprojectcomments 
      WHERE taqprojectkey = @i_po_projectkey
        AND commenttypecode = @v_commenttype_project
        AND commenttypesubcode = @v_commentsubtype_top

    IF @v_commentkey > 0
      SELECT @v_top_instructions_commenttext = commenttext
      FROM qsicomments
      WHERE @v_commentkey = @v_commentkey
  END

  -- Check if there are any components on this project that are related from another project (ex: PO components sitting on related Printing project)
  SELECT @v_count = COUNT(*)
  FROM taqversionrelatedcomponents_view 
  WHERE taqprojectkey = @i_po_projectkey AND relatedprojectkey <> taqprojectkey
  
  IF @v_count = 0	--there are no related components i.e. all components were added directly on the PO
    DECLARE cur_relatedprojects CURSOR FOR
      SELECT DISTINCT t.taqversionformatkey, t.relatedprojectkey, p.taqprojecttitle, p.searchitemcode, p.usageclasscode, 1
      FROM taqversionrelatedcomponents_view t, taqproject p
      WHERE t.relatedprojectkey = p.taqprojectkey 
        AND t.taqprojectkey = @i_po_projectkey 
  ELSE  
    -- Get all related projects for the project we are generating details from - @i_po_projectkey (which is the Purchase Order)
    -- For standard POs, the related projects would most likely be Printing projects
    DECLARE cur_relatedprojects CURSOR FOR
      SELECT DISTINCT t.taqversionformatkey, t.relatedprojectkey, p.taqprojecttitle, p.searchitemcode, p.usageclasscode, r.sortorder
      FROM taqversionrelatedcomponents_view t, taqproject p, taqprojectrelationship r
      WHERE t.relatedprojectkey = p.taqprojectkey 
        AND r.taqprojectkey1 = t.taqprojectkey
        AND r.taqprojectkey2 = t.relatedprojectkey
        AND t.taqprojectkey = @i_po_projectkey 
      ORDER BY r.sortorder, t.relatedprojectkey       

  OPEN cur_relatedprojects

  FETCH cur_relatedprojects
  INTO @v_po_formatkey, @v_projectkey, @v_projectdesc, @v_itemtype, @v_usageclass, @v_sortorder_projects
    
  WHILE @@fetch_status = 0
  BEGIN
    
    --PRINT ''
    --PRINT '@v_po_formatkey=' + CONVERT(VARCHAR, @v_po_formatkey)
    --PRINT '@v_projectkey=' + CONVERT(VARCHAR, @v_projectkey) + ' ' + @v_projectdesc
    --PRINT '@v_itemtype/@v_usageclass: ' + CONVERT(VARCHAR, @v_itemtype) + '/' + CONVERT(VARCHAR, @v_usageclass)
    
    IF @v_itemtype = @v_itemtype_printing
    BEGIN
      -- The related project for this PO is a Printing project - use the related bookkey/printingkey as key1/key2
      SELECT @v_bookkey = bookkey, @v_printingkey = printingkey, @v_title = title, 
        @v_printingnum = COALESCE(printingnum, printingkey), @v_productnumber = COALESCE(productnumber,'')
      FROM taqprojectprinting_view
      WHERE taqprojectkey = @v_projectkey

      SET @v_sectiontype = @v_sectiontype_title_prtg
      SET @v_key1 = @v_bookkey
      SET @v_key2 = @v_printingkey
      SET @v_key3 = NULL
      SET @v_detail = @v_productnumber + ' ' + @v_title + ', Prtg: ' + CONVERT(VARCHAR, @v_printingnum)
      SET @v_sectiondesc = @v_detail
    END
    ELSE
    BEGIN
      -- Get the first 2 Product IDs for this project
      SET @v_loopnum = 1
      SET @v_productnumberstring = ''

      DECLARE cur_productnumbers CURSOR FOR
        SELECT COALESCE(n.productnumber,''), COALESCE(g.datadesc,'')
        FROM taqproductnumbers n LEFT OUTER JOIN gentables g ON n.productidcode = g.datacode AND g.tableid = 594
        WHERE n.taqprojectkey = @v_projectkey 
        ORDER BY n.sortorder

      OPEN cur_productnumbers

      FETCH cur_productnumbers INTO @v_prodnum, @v_prodnum_label
    
      WHILE @@fetch_status = 0
      BEGIN

        IF @v_prodnum_label <> ''
        BEGIN
          IF @v_productnumberstring <> '' SET @v_productnumberstring = @v_productnumberstring + ', '
          SET @v_productnumberstring = @v_productnumberstring + @v_prodnum_label + ': '
          IF @v_prodnum <> ''
            SET @v_productnumberstring = @v_productnumberstring + @v_prodnum
          ELSE
            SET @v_productnumberstring = @v_productnumberstring + '(none)'
        END

        IF @v_loopnum = 1
          SET @v_productnumber = @v_prodnum
        ELSE IF @v_loopnum = 2
          SET @v_productnumber2 = @v_prodnum
        ELSE
          BREAK --only care about the first 2 product ids

        SET @v_loopnum = @v_loopnum + 1

        FETCH cur_productnumbers INTO @v_prodnum, @v_prodnum_label
      END

      CLOSE cur_productnumbers
      DEALLOCATE cur_productnumbers

      -- The related project for this PO is NOT a Printing project - use projectkey as key1
      SET @v_sectiontype = @v_sectiontype_project
      SET @v_key1 = @v_projectkey
      SET @v_key2 = NULL
      SET @v_key3 = NULL
      SET @v_detail = @v_projectdesc + ', ' + @v_productnumberstring
      SET @v_sectiondesc = @v_detail
      
      -- Get the related Printing project - need for generate_gpocost
      SELECT @v_projectkey = relatedprojectkey FROM taqversionformatrelatedproject WHERE taqprojectkey = @v_projectkey
    END

    -- Check how many components for the current related project on this PO have quantity filled in
    SELECT @v_count = COUNT(*)
    FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
    WHERE v.relatedcategorykey = c.taqversionspecategorykey
      AND v.taqprojectkey = @i_po_projectkey
      AND v.taqversionformatkey = @v_po_formatkey
      AND c.quantity > 0 
    				     
    IF @v_count = 1 --only one component has quantity filled in - use that quantity
      SELECT @v_quantity = c.quantity
      FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
      WHERE v.relatedcategorykey = c.taqversionspecategorykey
        AND v.taqprojectkey = @i_po_projectkey
        AND v.taqversionformatkey = @v_po_formatkey
        AND c.quantity > 0 				  
    ELSE IF @v_count > 1 -- multiple components/quantities
    BEGIN
      -- Check if all components have the same quantity
      SELECT @v_count = COUNT(DISTINCT c.quantity)
      FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
      WHERE v.relatedcategorykey = c.taqversionspecategorykey
        AND v.taqprojectkey = @i_po_projectkey
        AND v.taqversionformatkey = @v_po_formatkey
        AND c.quantity > 0
					 
      IF @v_count = 1 -- all componenet have the same quantity - get first row's quantity
        SELECT TOP 1 @v_quantity = c.quantity
        FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
        WHERE v.relatedcategorykey = c.taqversionspecategorykey
          AND v.taqprojectkey = @i_po_projectkey
          AND v.taqversionformatkey = @v_po_formatkey
          AND c.quantity > 0
      ELSE IF @v_count > 1  --multiple components with different quantities - get the Finished Good quantity
        SELECT TOP 1 @v_quantity = c.quantity
        FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
        WHERE v.relatedcategorykey = c.taqversionspecategorykey
          AND v.taqprojectkey = @i_po_projectkey
          AND v.taqversionformatkey = @v_po_formatkey
          AND c.quantity > 0
          AND c.finishedgoodind = 1
      ELSE
        SET @v_quantity = NULL
    END

    -- By default, set gposection description to project title followed by productnumber (for projects) or productnumber, title, printing (for titles).
    -- If Report Specification Detail Type=2 (Summary Component Item Detail Only) and a single project/printing, use 'Summary Information'.
    -- If Report Specification Detail Type=3 (Specification Item Detail) and a single project/printing, we will use component description at component level.
    IF @v_num_relatedprojects = 1  --single project/printing on this PO
      IF @v_report_detail_display_type = 2  --Summary Component Item Detail Only
        SET @v_sectiondesc = 'Summary Information'

    --PRINT '@v_sectiondesc: ' + @v_sectiondesc
    --PRINT '@v_quantity: ' + CONVERT(VARCHAR, @v_quantity)

    -- ***** GPOSECTION *****
    -- GPOSECTION will be at component level for single project/printing POs when Report Specification Detail Type=3 (Spec Item Detail) - set sectiontype here
    -- For all other cases, GPOSECTION will be at project level.
    IF @v_num_relatedprojects = 1 AND @v_report_detail_display_type = 3 
    BEGIN      
      IF @v_itemtype = @v_itemtype_printing
        SET @v_sectiontype = @v_sectiontype_title_prtg_comp
      ELSE
        SET @v_sectiontype = @v_sectiontype_project_comp
    END
    ELSE
    BEGIN
      EXEC get_next_key @v_lastuserid, @v_new_sectionkey OUT

      INSERT INTO gposection
        (gpokey, sectionkey, sectiontype, key1, key2, key3, quantity, description, lastuserid, lastmaintdate)
      VALUES
        (@i_gpokey, @v_new_sectionkey, @v_sectiontype, @v_key1, @v_key2, @v_key3, @v_quantity, @v_sectiondesc, @v_lastuserid, getdate())

      -- write out PO Top Line Detail Instructions, if comments exist into gpodetail
      IF @v_top_instructions_added = 0 AND @v_top_instructions_commenttext IS NOT NULL
      BEGIN
        SET @v_top_instructions_added = 1
        EXEC qpo_write_comment_details @i_po_projectkey, @i_gpokey, @v_new_sectionkey, @v_new_subsectionkey, 
          @v_top_instructions_commenttext, 6, @v_detaillinenbr out, @v_lastuserid
      END

      -- Generate project-level costs (by chargecode) and set on GPOCOST
      IF @v_report_detail_display_type IN (1,2)
      BEGIN
        EXEC qpo_generate_gpocost @i_po_projectkey, @v_projectkey, @i_gpokey, @v_new_sectionkey, 0,
          0, @v_report_detail_display_type, 0, @v_lastuserid, @o_error_code, @o_error_desc
					
        SELECT @o_error_code = @@ERROR
        IF @o_error_code <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not get generate gpocost rows'
        END
      END
    END

    -- ***** GPODETAIL - project level *****
    IF @v_report_detail_display_type IN (1,2) OR @v_num_relatedprojects > 1  --Project/Title Info Only or Summary report level OR multiple projects/printings
    BEGIN
      IF @v_report_detail_display_type = 2 AND @v_num_relatedprojects = 1  --Summary Component report level AND single project/printing
        SET @v_detail = 'Summary Information'

      IF @v_detail IS NOT NULL
      BEGIN
        IF @v_detaillinenbr > 0 --add empty line before subsequent project detail line
        BEGIN
          SET @v_detaillinenbr = @v_detaillinenbr + 100
          EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT

          INSERT INTO gpodetail
            (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, lastuserid, lastmaintdate)
          VALUES
            (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, 0, @v_detaillinenbr, '', 1, @v_lastuserid, getdate())
        END

        SET @v_detaillinenbr = @v_detaillinenbr + 100
        EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT

        INSERT INTO gpodetail
          (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
        VALUES
          (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, 0, @v_detaillinenbr, @v_detail, 1, 2, @v_lastuserid, getdate())
      END
    END

    ---- ***** GPODETAIL - component level *****
    IF @v_report_detail_display_type <> 1 --for all cases except report level = Project/Title Info Only
    BEGIN

      SET @v_is_first_component = 1

      IF @v_report_detail_display_type = 2  --Summary Component Item Detail Only
      BEGIN
        -- Summary Component: get if from the PO project itself if exists, otherwise get it from the related project (Printing project)
        SELECT @v_count = COUNT(*)
        FROM taqversionspeccategory
        WHERE taqprojectkey = @i_po_projectkey AND itemcategorycode = @v_summary_component

        IF @v_count > 0
          DECLARE cur_relatedcomponents CURSOR FOR
            SELECT taqversionspecategorykey, COALESCE(relatedspeccategorykey, taqversionspecategorykey) relatedcategorykey, 
              itemcategorycode, speccategorydescription, NULL
            FROM taqversionspeccategory
            WHERE taqprojectkey = @i_po_projectkey AND itemcategorycode = @v_summary_component
        ELSE
          DECLARE cur_relatedcomponents CURSOR FOR
            SELECT taqversionspecategorykey, COALESCE(relatedspeccategorykey, taqversionspecategorykey) relatedcategorykey, 
              itemcategorycode, speccategorydescription, NULL
            FROM taqversionspeccategory
            WHERE taqprojectkey = @v_projectkey AND itemcategorycode = @v_summary_component
      END
      ELSE BEGIN
        -- Loop through all components for this PO and format
        DECLARE cur_relatedcomponents CURSOR FOR
          SELECT v.taqversionspecategorykey, v.relatedcategorykey, c.itemcategorycode, c.speccategorydescription, c.quantity
          FROM taqversionrelatedcomponents_view v, taqversionspeccategory c    
          WHERE v.relatedcategorykey = c.taqversionspecategorykey
            AND v.taqprojectkey = @i_po_projectkey  
            AND v.taqversionformatkey = @v_po_formatkey
          ORDER BY c.sortorder, c.itemcategorycode
      END

      OPEN cur_relatedcomponents

      FETCH cur_relatedcomponents 
      INTO @v_categorykey, @v_relatedcategorykey, @v_itemcategorycode, @v_categorydesc, @v_quantity
    
      WHILE @@fetch_status = 0
      BEGIN

        --PRINT ' '
        --PRINT ' @v_categorykey=' + CONVERT(VARCHAR, @v_categorykey)
        --PRINT ' @v_relatedcategorykey=' + CONVERT(VARCHAR, @v_relatedcategorykey)
        --PRINT ' @v_itemcategorycode=' + CONVERT(VARCHAR, @v_itemcategorycode) + ' ' + @v_categorydesc
        --PRINT ' @v_quantity=' + CONVERT(VARCHAR, @v_quantity)

        SET @v_new_subsectionkey = 0
		SET @v_gpo_finishedgoodind = 0
        
        -- For single project/printing POs when Report Specification Detail Type=3 (Spec Item Detail), 
        -- write to GPOSECTION (component level) and GPOCOST
        IF @v_report_detail_display_type = 3 
        BEGIN      
          IF @v_itemtype = @v_itemtype_printing
          BEGIN
            SET @v_sectiontype = @v_sectiontype_title_prtg_comp
            SET @v_key3 = @v_categorykey
          END
          ELSE
          BEGIN
            SET @v_sectiontype = @v_sectiontype_project_comp
            SET @v_key2 = @v_categorykey
          END

		  SELECT @v_gpo_finishedgoodind = COALESCE(finishedgoodind, 0)
		  FROM taqversionspeccategory 
		  WHERE taqversionspecategorykey = @v_categorykey

          IF @v_num_relatedprojects > 1 --multiple project PO
          BEGIN
            EXEC get_next_key @v_lastuserid, @v_new_subsectionkey OUT

            -- write GPOSUBSECTION at component level
            INSERT INTO gposubsection
              (gpokey, sectionkey, subsectionkey, subsectiontype, key1, key2, key3, quantity, description, finishedgoodind, lastuserid, lastmaintdate)
            VALUES
              (@i_gpokey, @v_new_sectionkey, @v_new_subsectionkey, @v_sectiontype, @v_key1, @v_key2, @v_key3, @v_quantity, @v_categorydesc, @v_gpo_finishedgoodind, @v_lastuserid, getdate())
          END
          ELSE
          BEGIN --single project PO            
            EXEC get_next_key @v_lastuserid, @v_new_sectionkey OUT

            -- write GPOSECTION at component level
            INSERT INTO gposection
              (gpokey, sectionkey, sectiontype, key1, key2, key3, quantity, description, finishedgoodind, lastuserid, lastmaintdate)
            VALUES
              (@i_gpokey, @v_new_sectionkey, @v_sectiontype, @v_key1, @v_key2, @v_key3, @v_quantity, @v_categorydesc, @v_gpo_finishedgoodind, @v_lastuserid, getdate())

            -- write out PO Top Line Detail Instructions, if comments exist into gpodetail
            IF @v_top_instructions_added = 0 AND @v_top_instructions_commenttext IS NOT NULL
            BEGIN
              SET @v_top_instructions_added = 1
              EXEC qpo_write_comment_details @i_po_projectkey, @i_gpokey, @v_new_sectionkey, @v_new_subsectionkey, 
                @v_top_instructions_commenttext, 6, @v_detaillinenbr out, @v_lastuserid
            END
          END
          
          -- Generate costs and set on GPOCOST
          EXEC qpo_generate_gpocost @i_po_projectkey, @v_projectkey, @i_gpokey, @v_new_sectionkey, @v_new_subsectionkey,
            @v_categorykey, @v_report_detail_display_type, @v_is_first_component, @v_lastuserid, @o_error_code, @o_error_desc
					
          SELECT @o_error_code = @@ERROR
          IF @o_error_code <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not get generate gpocost rows'
          END
        END --IF @v_num_relatedprojects = 1 AND @v_report_detail_display_type = 3 

        IF @v_report_detail_display_type IN (3,0) --For Spec Item Detail report level
        BEGIN
          -- Check if spec items exist for this component, culture and Item Type/Usage Class
          SELECT @v_num_items = COUNT(*)
          FROM taqversionspecitems_view  i
            INNER JOIN taqspecadmin a ON a.itemcategorycode = i.itemcategorycode AND a.itemcode = i.itemcode AND a.culturecode = @v_culturecode
            LEFT OUTER JOIN gentablesitemtype gi ON gi.tableid = 616 AND gi.datacode = i.itemcategorycode AND gi.datasubcode = i.itemcode 
              AND gi.itemtypecode = @v_itemtype_PO AND COALESCE(gi.itemtypesubcode,0) IN (@v_usageclass_PO,0)
          WHERE i.taqversionspecategorykey = @v_categorykey

          --PRINT 'Num spec items for this component, culture, itemtype/usageclass: ' + CONVERT(VARCHAR, @v_num_items)

          -- If there are no spec items for this component and culture, check if notes exist for this component
          IF @v_num_items = 0
          BEGIN
            IF @v_relatedcategorykey > 0
              SELECT @v_num_notes = COUNT(*)
              FROM taqversionspecnotes
              WHERE taqversionspecategorykey = @v_relatedcategorykey AND showonpoind = 1
            ELSE
              SELECT @v_num_notes = COUNT(*)
              FROM taqversionspecnotes
              WHERE taqversionspecategorykey = @v_categorykey AND showonpoind = 1
          END

          --PRINT 'Num spec notes: ' + CONVERT(VARCHAR, @v_num_notes)

          -- If either spec items or notes exist for this component, write out the detail line for the component
          IF @v_num_items > 0 OR @v_num_notes > 0
          BEGIN
            IF @v_detaillinenbr > 0 --add empty line before subsequent Component lines
            BEGIN
              SET @v_detaillinenbr = @v_detaillinenbr + 100
              EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
              INSERT INTO gpodetail
                (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, lastuserid, lastmaintdate)
              VALUES
                (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, '', 1, @v_lastuserid, getdate())
            END

            SET @v_detaillinenbr = @v_detaillinenbr + 100
            EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT

            SET @v_detail = '**** ' + ltrim(rtrim(@v_categorydesc)) + ' ****'												
					
            INSERT INTO gpodetail
              (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
            VALUES
              (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, 3, @v_lastuserid, getdate())									
          END
        END

        -- Loop through all spec items for this component and write out detail
        -- For Summary Component, get all spec items specifically on the Summary component PLUS all with showinsummaryind=1
        -- For all other cases, get only spec items specifically on that component
        IF @v_report_detail_display_type = 2  --Summary Component Item Detail Only 
          DECLARE cur_compspecitems CURSOR FOR
            SELECT COALESCE(i.itemcode,0) itemcode, COALESCE(i.itemdesc,'') itemdesc, COALESCE(i.itemdetaildesc,'') itemdetaildesc,
              COALESCE(i.quantity,0) qty, COALESCE(i.description,'') desc1, COALESCE(i.description2,'') desc2,
              COALESCE(i.unitofmeasuredesc,'') uom, COALESCE(i.decimalvalue,0) decvalue,
              COALESCE(a.showqtyind,0) showqtyind, COALESCE(ltrim(rtrim(a.showqtylabel)),'') showqtylabel, 
              COALESCE(a.showdecimalind,0) showdecimalind, COALESCE(ltrim(rtrim(a.showdecimallabel)),'') showdecimallabel,
              COALESCE(a.showdescind,0) showdesc1ind, COALESCE(ltrim(rtrim(a.showdesclabel)),'') showdesc1label,
              COALESCE(a.showdesc2ind,0) showdesc2ind, COALESCE(ltrim(rtrim(a.showdesc2label)),'') showdesc2label,
              COALESCE(a.showunitofmeasureind,0) showuomind, COALESCE(a.defaultunitofmeasurecode,0) uomcode,
              COALESCE(ltrim(rtrim(a.itemlabel)),'') itemlabel
            FROM taqversionspecitems_view  i
              JOIN subgentables sg ON sg.tableid = 616 AND sg.datacode = i.itemcategorycode AND sg.datasubcode = i.itemcode
              JOIN taqspecadmin a ON a.itemcategorycode = i.itemcategorycode AND a.itemcode = i.itemcode AND a.culturecode = @v_culturecode
              JOIN gentablesitemtype gi ON gi.tableid = 616 AND gi.datacode = i.itemcategorycode AND gi.datasubcode = i.itemcode 
                AND gi.itemtypecode = @v_itemtype_PO AND COALESCE(gi.itemtypesubcode,0) IN (@v_usageclass_PO,0)            
            WHERE i.taqversionspecategorykey = @v_categorykey
              OR (i.taqprojectkey = @v_projectkey AND a.showinsummaryind = 1)
            ORDER BY COALESCE(summarysortorder, COALESCE(gi.sortorder, sg.sortorder))
        ELSE
          DECLARE cur_compspecitems CURSOR FOR
            SELECT COALESCE(i.itemcode,0) itemcode, COALESCE(i.itemdesc,'') itemdesc, COALESCE(i.itemdetaildesc,'') itemdetaildesc,
              COALESCE(i.quantity,0) qty, COALESCE(i.description,'') desc1, COALESCE(i.description2,'') desc2,
              COALESCE(i.unitofmeasuredesc,'') uom, COALESCE(i.decimalvalue,0) decvalue,
              COALESCE(a.showqtyind,0) showqtyind, COALESCE(ltrim(rtrim(a.showqtylabel)),'') showqtylabel, 
              COALESCE(a.showdecimalind,0) showdecimalind, COALESCE(ltrim(rtrim(a.showdecimallabel)),'') showdecimallabel,
              COALESCE(a.showdescind,0) showdesc1ind, COALESCE(ltrim(rtrim(a.showdesclabel)),'') showdesc1label,
              COALESCE(a.showdesc2ind,0) showdesc2ind, COALESCE(ltrim(rtrim(a.showdesc2label)),'') showdesc2label,
              COALESCE(a.showunitofmeasureind,0) showuomind, COALESCE(a.defaultunitofmeasurecode,0) uomcode,
              COALESCE(ltrim(rtrim(a.itemlabel)),'') itemlabel
            FROM taqversionspecitems_view  i
              JOIN subgentables sg ON sg.tableid = 616 AND sg.datacode = i.itemcategorycode AND sg.datasubcode = i.itemcode
              JOIN taqspecadmin a ON a.itemcategorycode = i.itemcategorycode AND a.itemcode = i.itemcode AND a.culturecode = @v_culturecode
              JOIN gentablesitemtype gi ON gi.tableid = 616 AND gi.datacode = i.itemcategorycode AND gi.datasubcode = i.itemcode 
                AND gi.itemtypecode = @v_itemtype_PO AND COALESCE(gi.itemtypesubcode,0) IN (@v_usageclass_PO,0)            
            WHERE i.taqversionspecategorykey = @v_categorykey
            ORDER BY COALESCE(summarysortorder, COALESCE(gi.sortorder, sg.sortorder))

        OPEN cur_compspecitems

        FETCH cur_compspecitems
        INTO @v_itemcode, @v_itemdesc, @v_itemdetaildesc, @v_itemqty, @v_desc1, @v_desc2, @v_uomdesc, @v_decimalvalue,
          @v_showqtyind, @v_showqtylabel, @v_showdecimalind, @v_showdecimallabel, @v_showdescind, @v_showdesclabel,
          @v_showdesc2ind, @v_showdesc2label, @v_showunitofmeasureind, @v_defaultuomcode, @v_itemlabel
        
        WHILE @@fetch_status = 0
        BEGIN

          SET @v_detail = ''
		  SET @v_write_detail = 0
        					
          -- In order to write out spec detail, at least itemdetaildesc, qty, decimalvalue or description should exist
          IF @v_itemdetaildesc IS NOT NULL OR @v_itemqty IS NOT NULL OR @v_decimalvalue IS NOT NULL OR @v_desc1 IS NOT NULL
          BEGIN						
            -- Fill detail: drop-down value description (itemdetaildesc), Qty, Decimal value, Descriptions 1 and 2, and lastly UOM
            IF @v_itemdetaildesc IS NOT NULL AND LTRIM(RTRIM(@v_itemdetaildesc)) <> ''
			BEGIN
              SET @v_detail = @v_detail + @v_itemdetaildesc
			  SET @v_write_detail = 1
			END

            IF @v_showqtyind = 1 AND @v_itemqty IS NOT NULL AND @v_itemqty <> 0
            BEGIN
              IF @v_detail <> ''
                SET @v_detail = @v_detail + ', '
              IF @v_showqtylabel IS NOT NULL AND LTRIM(RTRIM(@v_showqtylabel)) <> ''
			  BEGIN
                SET @v_detail = @v_detail + @v_showqtylabel + CONVERT(VARCHAR, @v_itemqty)
				SET @v_write_detail = 1
			  END
              ELSE
			  BEGIN
                SET @v_detail = @v_detail + CONVERT(VARCHAR, @v_itemqty)
				SET @v_write_detail = 1
			  END
            END

            IF @v_showdecimalind = 1 AND @v_decimalvalue IS NOT NULL
            BEGIN
              IF @v_detail <> ''
                SET @v_detail = @v_detail + ', '
              IF @v_showdecimallabel IS NOT NULL AND LTRIM(RTRIM(@v_showdecimallabel)) <> ''
			  BEGIN
                SET @v_detail = @v_detail + @v_showdecimallabel + CONVERT(VARCHAR, @v_decimalvalue)
				SET @v_write_detail = 1
			  END
              ELSE
			  BEGIN
                SET @v_detail = @v_detail + CONVERT(VARCHAR, @v_decimalvalue)
				SET @v_write_detail = 1
			  END
            END

            IF @v_showdescind > 0 AND (@v_desc1 IS NOT NULL AND @v_desc1 <> '') AND (@v_desc1 <> @v_itemdetaildesc)
            BEGIN
              IF @v_detail <> ''
                SET @v_detail = @v_detail + ', '
              IF @v_showdesclabel IS NOT NULL AND LTRIM(RTRIM(@v_showdesclabel)) <> ''
			  BEGIN
                SET @v_detail = @v_detail + @v_showdesclabel + ' ' + @v_desc1
				SET @v_write_detail = 1
			  END
              ELSE
			  BEGIN
                SET @v_detail = @v_detail + @v_desc1
				SET @v_write_detail = 1
			  END
            END

            IF @v_showdesc2ind > 0 AND (@v_desc2 IS NOT NULL AND @v_desc2 <> '')
			BEGIN
              IF @v_showdesc2label IS NOT NULL AND LTRIM(RTRIM(@v_showdesc2label)) <> ''
                IF @v_desc1 IS NULL OR LTRIM(RTRIM(@v_desc1)) = ''
                  SET @v_detail = @v_detail + ', ' + @v_showdesc2label + ' ' + @v_desc2
                ELSE
                  SET @v_detail = @v_detail + ' ' + @v_showdesc2label + ' ' + @v_desc2
              ELSE
                SET @v_detail = @v_detail + ' ' + @v_desc2

			  SET @v_write_detail = 1
			END

            IF @v_showunitofmeasureind = 1 AND @v_defaultuomcode > 0
              SET @v_detail = @v_detail + ' ' + @v_uomdesc

			IF COALESCE(@v_itemlabel, '') LIKE '%*%'
			BEGIN
				SET @v_write_detail = 1 
			END
            -- Detail should start with spec item description.
            -- Use itemlabel if filled in, otherwise use item description.
			IF @v_itemlabel IS NOT NULL AND LTRIM(RTRIM(@v_itemlabel)) <> ''
				SET @v_detail = @v_itemlabel + ': ' + @v_detail
			ELSE
				SET @v_detail = @v_itemdesc + ': ' + @v_detail
          END --minimum spec item value present          

          IF @v_detail IS NOT NULL AND LTRIM(RTRIM(@v_detail)) <> '' AND @v_write_detail = 1
          BEGIN
            --PRINT '  ' + @v_detail

            SET @v_detaillinenbr = @v_detaillinenbr + 100
            EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
            INSERT INTO gpodetail
              (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, lastuserid, lastmaintdate)
            VALUES
              (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, @v_lastuserid, getdate())
          END

          FETCH cur_compspecitems
          INTO @v_itemcode, @v_itemdesc, @v_itemdetaildesc, @v_itemqty, @v_desc1, @v_desc2, @v_uomdesc, @v_decimalvalue,
            @v_showqtyind, @v_showqtylabel, @v_showdecimalind, @v_showdecimallabel, @v_showdescind, @v_showdesclabel,
            @v_showdesc2ind, @v_showdesc2label, @v_showunitofmeasureind, @v_defaultuomcode, @v_itemlabel
        END

        CLOSE cur_compspecitems
        DEALLOCATE cur_compspecitems

        -- Add Due Dates to Bind PO detail
        SELECT @v_externalcode_str = externalcode
        FROM gentables 
        WHERE tableid = 616 AND datacode = @v_itemcategorycode
        
        IF ISNUMERIC(@v_externalcode_str)  = 1 SET @v_externalcode_int = @v_externalcode_str
        ELSE SET @v_externalcode_int = 0
				
        IF @v_externalcode_int = 2   --Bind PO
        BEGIN                  
          SELECT @v_duedate = COALESCE(t.activedate, NULL), @v_taqtasknote = COALESCE(t.taqtasknote,NULL), @v_taskdesc = d.description
          FROM taqprojecttask t, datetype d
          WHERE t.datetypecode = d.datetypecode AND d.qsicode = 25  --Cover Due
            AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
					  
          IF @v_duedate IS NOT NULL OR @v_taqtasknote IS NOT NULL
          BEGIN
            SET @v_detail = '* ' + @v_taskdesc + ': ' --'* Cover Due Date: '   
						    
            IF @v_duedate IS NOT NULL BEGIN
              SELECT @v_date_string = CONVERT(VARCHAR, @v_duedate, 101)
              SET @v_detail = @v_detail + @v_date_string
            END
            IF @v_taqtasknote IS NOT NULL
              SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)
								
            IF @v_detail IS NOT NULL AND LTRIM(RTRIM(@v_detail)) <> ''
            BEGIN
              SET @v_detaillinenbr = @v_detaillinenbr + 100
              EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
              INSERT INTO gpodetail
                (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
              VALUES
                (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, 5, @v_lastuserid, getdate())
            END
          END  -- Cover Due is not null
					
          SET @v_duedate = NULL
          SET @v_taqtasknote = NULL

          SELECT @v_duedate = COALESCE(t.activedate, NULL), @v_taqtasknote = COALESCE(t.taqtasknote,NULL), @v_taskdesc = d.description
          FROM taqprojecttask t, datetype d
          WHERE t.datetypecode = d.datetypecode AND d.qsicode = 26  --Jacket Due
            AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						  
          IF @v_duedate IS NOT NULL OR @v_taqtasknote IS NOT NULL
          BEGIN
            SET @v_detail = '* ' + @v_taskdesc + ': ' --'* Jacket Due Date: '

            IF @v_duedate IS NOT NULL BEGIN 
              SELECT @v_date_string = CONVERT(VARCHAR, @v_duedate, 101)
              SET @v_detail = @v_detail + @v_date_string
            END
            IF @v_taqtasknote IS NOT NULL
              SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)

            IF @v_detail IS NOT NULL AND LTRIM(RTRIM(@v_detail)) <> ''
            BEGIN
              SET @v_detaillinenbr = @v_detaillinenbr + 100
              EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
              INSERT INTO gpodetail
                (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
              VALUES
                (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, 5, @v_lastuserid, getdate())
            END
          END  -- Jacket Due is not null

          SET @v_duedate = NULL
          SET @v_taqtasknote = NULL

          SELECT @v_duedate = COALESCE(t.activedate, NULL), @v_taqtasknote = COALESCE(t.taqtasknote,NULL), @v_taskdesc = d.description
          FROM taqprojecttask t, datetype d
          WHERE t.datetypecode = d.datetypecode AND d.qsicode = 27  --Misc Due
            AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						  
          IF @v_duedate IS NOT NULL OR @v_taqtasknote IS NOT NULL
          BEGIN
            SET @v_detail = '* ' + @v_taskdesc + ': ' --'* Miscellaneous Due Date: '

            IF @v_duedate IS NOT NULL BEGIN 
              SELECT @v_date_string = CONVERT(VARCHAR, @v_duedate, 101)
              SET @v_detail = @v_detail + @v_date_string
            END
            IF @v_taqtasknote IS NOT NULL
              SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)

            IF @v_detail IS NOT NULL AND LTRIM(RTRIM(@v_detail)) <> ''
            BEGIN
              SET @v_detaillinenbr = @v_detaillinenbr + 100
              EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
              INSERT INTO gpodetail
                (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
              VALUES
                (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, 5, @v_lastuserid, getdate())
            END
          END  -- Miscellaneous Due is not null 
					
          SET @v_duedate = NULL
          SET @v_taqtasknote = NULL

          SELECT @v_duedate = COALESCE(t.activedate, NULL), @v_taqtasknote = COALESCE(t.taqtasknote,NULL), @v_taskdesc = d.description
          FROM taqprojecttask t, datetype d
          WHERE t.datetypecode = d.datetypecode AND d.qsicode = 34  --Film/Repro Due
            AND taqprojectkey IS NULL AND bookkey = @v_bookkey AND printingkey = @v_printingkey
						  
          IF @v_duedate IS NOT NULL OR @v_taqtasknote IS NOT NULL
          BEGIN
            SET @v_detail = '* ' + @v_taskdesc + ': ' --'* Film/Repro Due Date: '

            IF @v_duedate IS NOT NULL BEGIN 
              SELECT @v_date_string = CONVERT(VARCHAR, @v_duedate, 101)
              SET @v_detail = @v_detail + @v_date_string
            END
            IF @v_taqtasknote IS NOT NULL
              SET @v_detail = @v_detail + ' ' + SUBSTRING(@v_taqtasknote,1,200)

            IF @v_detail IS NOT NULL AND LTRIM(RTRIM(@v_detail)) <> ''
            BEGIN
              SET @v_detaillinenbr = @v_detaillinenbr + 100
              EXEC get_next_key @v_lastuserid, @v_new_detailkey OUTPUT
								
              INSERT INTO gpodetail
                (gpokey, detailkey, sectionkey, subsectionkey, detaillinenbr, detail, detailtype, reportformatcode, lastuserid, lastmaintdate)
              VALUES
                (@i_gpokey, @v_new_detailkey, @v_new_sectionkey, @v_new_subsectionkey, @v_detaillinenbr, @v_detail, 1, 5, @v_lastuserid, getdate())
            END
          END  -- Film/Repro Due is not null  
        END -- Bind PO

        -- Add component notes to detail
        IF @v_categorykey > 0 OR @v_relatedcategorykey > 0
        BEGIN									  
          IF @v_relatedcategorykey > 0 
            DECLARE notes_cur CURSOR FOR
            SELECT [text]
            FROM taqversionspecnotes 
            WHERE taqversionspecategorykey = @v_relatedcategorykey AND showonpoind = 1 
            ORDER BY sortorder ASC			  
          ELSE
            DECLARE notes_cur CURSOR FOR
            SELECT [text]
            FROM taqversionspecnotes 
            WHERE taqversionspecategorykey = @v_categorykey AND showonpoind = 1 
            ORDER BY sortorder ASC
								 
          OPEN notes_cur 

          FETCH notes_cur INTO @v_commenttext
	  					
          WHILE @@fetch_status = 0
          BEGIN

            EXEC qpo_write_comment_details @i_po_projectkey, @i_gpokey, @v_new_sectionkey, @v_new_subsectionkey, @v_commenttext, 4, @v_detaillinenbr, @v_lastuserid
							 
            FETCH notes_cur INTO @v_commenttext	 
          END -- cursor
					    
          CLOSE notes_cur 
          DEALLOCATE notes_cur 
				    
        END --IF @v_categorykey > 0 OR @v_relatedcategorykey > 0

        SET @v_is_first_component = 0

        FETCH cur_relatedcomponents
        INTO @v_categorykey, @v_relatedcategorykey, @v_itemcategorycode, @v_categorydesc, @v_quantity
      END

      CLOSE cur_relatedcomponents
      DEALLOCATE cur_relatedcomponents

    END --IF @v_report_detail_display_type <> 1

    FETCH cur_relatedprojects
    INTO @v_po_formatkey, @v_projectkey, @v_projectdesc, @v_itemtype, @v_usageclass, @v_sortorder_projects
  END

  CLOSE cur_relatedprojects
  DEALLOCATE cur_relatedprojects

END
GO

GRANT EXEC ON [dbo].[qpo_generate_po_details] to PUBLIC
GO