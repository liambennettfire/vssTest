if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_create_title_addtl_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_create_title_addtl_info 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_title_addtl_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_copy_title_addtl_info 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_title_addtl_info
 (@i_bookkey                integer,
  @i_printingkey            integer,
  @i_templatebookkey        integer,
  @i_templateprintingkey    integer,
  @i_copydatagroups_list	  varchar(2000),
  @i_cleardatagroups_list	  varchar(2000),  
  @i_userid                 varchar(30),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qtitle_copy_title_addtl_info
**  Desc: This stored procedure will copy information that does not track titlehistory
**        from a title/template to a new title during the creation process.
**	      Most information is copied in qtitle_copy_title stored procedure.
**        Only element-related inserts remain here - no history.
**
**  Auth: Kate Wiewiora
**  Date: 29 July 2009
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:		Author:	Description:
*   --------	-------	------------------------------------------------------------------------
**	12/10/2014	Uday	Case 30701 - Copy Specification Templates
*   03/20/2016	Kate	Case 35197 - Change apply spec template option from "Overwrite - All But Summary Component"
*						to "Leave Existing Data, Add New Values"
**	12/15/2016	Uday	Case 42240
**  05/23/2017  Colman Case 45158 - Changes for the Shared PO Sections and Components 
*****************************************************************************************************/

DECLARE 
  @v_assotype INT,
  @v_assosubtype  INT,
  @v_commentkey1  INT,
  @v_commentkey2  INT,
  @v_error  INT,
  @v_elementkey	INT,
  @v_lastuserid	VARCHAR(30),
  @v_lastmaintdate	DATETIME,
  @v_qsiobjectkey INT,
  @v_history_order  INT,
  @v_sortorder	INT,
  @v_count INT,
  @v_commenttypecode INT,
  @v_commenttypesubcode INT,
  @v_questioncommentkey  INT, 
  @v_newquestioncommentkey  INT, 
  @v_answercommentkey  INT,   
  @v_newanswercommentkey  INT,
  @v_discoverykey INT,
  @v_associatetitlebookkey INT,
  @v_projectkey INT,
  @v_taqprojectformatkey INT,
  @v_itemtype_qsicode INT,
  @v_itemtypecode INT,
  @v_usageclass_qsicode INT,
  @v_usageclasscode	INT,
  @v_templateprojectkey INT,
  @v_errordesc	VARCHAR(2000)   
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  /**** Reinsert bookcomments and citation comments to fix HTML tags (original copy must stay for titlehistory) ****/
  /* bookcomments */    
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 13) = 'Y'  --Comments
	BEGIN
    DECLARE comments_cur CURSOR FOR
      SELECT commenttypecode, commenttypesubcode
      FROM bookcomments WHERE bookkey = @i_templatebookkey AND printingkey = @i_templateprintingkey
      
    OPEN comments_cur

    FETCH NEXT FROM comments_cur INTO @v_commenttypecode, @v_commenttypesubcode

    WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
    BEGIN 
      SELECT @v_count = count(*)
      FROM bookcomments
      WHERE bookkey = @i_bookkey 
        AND printingkey = @i_printingkey
        AND commenttypecode = @v_commenttypecode 
        AND commenttypesubcode = @v_commenttypesubcode 
        AND (datalength(commenthtml) > 0 OR datalength(commenthtmllite) > 0 OR datalength(commenttext) > 0)

      -- only delete and insert if comment is not filled in already
      IF @v_count = 0 BEGIN
        SELECT @v_lastuserid = lastuserid, @v_lastmaintdate = lastmaintdate
        FROM bookcomments
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
        AND commenttypecode = @v_commenttypecode 
        AND commenttypesubcode = @v_commenttypesubcode 
   
        DELETE FROM bookcomments
        WHERE bookkey = @i_bookkey 
        AND printingkey = @i_printingkey
        AND commenttypecode = @v_commenttypecode 
        AND commenttypesubcode = @v_commenttypesubcode 
               
        INSERT INTO bookcomments
	      (bookkey, printingkey, commenttypecode, commenttypesubcode, commentstring, 
	      commenttext, commenthtml, commenthtmllite, invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
        SELECT @i_bookkey, @i_printingkey, commenttypecode, commenttypesubcode, commentstring, 
	      commenttext, commenthtml, commenthtmllite, invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
        FROM bookcomments
        WHERE bookkey = @i_templatebookkey 
        AND printingkey = @i_templateprintingkey
        AND commenttypecode = @v_commenttypecode 
        AND commenttypesubcode = @v_commenttypesubcode 
           
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
	        SET @o_error_code = 1
	        SET @o_error_desc = 'Unable to copy from template (Bookcomments): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR) + 
	          ' templateprintingkey = ' + cast(@i_templateprintingkey AS VARCHAR)
	        RETURN
        END
      END
      
      FETCH NEXT FROM comments_cur INTO @v_commenttypecode, @v_commenttypesubcode
    END
    
    CLOSE comments_cur
    DEALLOCATE comments_cur
	END
  
  /* qsicomments - citations */  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 18) = 'Y'  --Citations
  BEGIN
    DECLARE citations_cur CURSOR FOR
      SELECT qsiobjectkey, COALESCE(history_order, sortorder)
      FROM citation WHERE bookkey = @i_bookkey
      ORDER BY COALESCE(history_order, sortorder)
      
    OPEN citations_cur

    FETCH NEXT FROM citations_cur INTO @v_qsiobjectkey, @v_history_order

    WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
    BEGIN 
      
      DELETE FROM qsicomments 
      WHERE commentkey = @v_qsiobjectkey
    
      INSERT INTO qsicomments
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
      SELECT @v_qsiobjectkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
      FROM qsicomments
      WHERE commentkey IN (SELECT qsiobjectkey FROM citation WHERE bookkey = @i_templatebookkey AND history_order = @v_history_order)
           
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from template (Citation comments): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR)
        RETURN
      END  
    
      FETCH NEXT FROM citations_cur INTO @v_qsiobjectkey, @v_history_order
    END
    
    CLOSE citations_cur
    DEALLOCATE citations_cur
  END

  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 19) = 'Y'  --Discovery Questions
	BEGIN
    DECLARE crDiscoveryQuestions CURSOR FOR
		SELECT D.questioncommentkey, D.answercommentkey, D.discoverykey, D.sortorder
		FROM discoveryquestions D
		WHERE bookkey = @i_templatebookkey

    OPEN crDiscoveryQuestions 

    FETCH NEXT FROM crDiscoveryQuestions INTO @v_questioncommentkey, @v_answercommentkey, @v_discoverykey, @v_sortorder

    WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
    BEGIN 
	  IF (@v_sortorder <> 0) AND (@v_sortorder IS NOT NULL) AND (@v_questioncommentkey IS NOT NULL) AND (@v_answercommentkey IS NOT NULL)
		  BEGIN
		  SELECT @v_count = count(*)
		  FROM qsicomments
		  WHERE commentkey IN (SELECT questioncommentkey FROM discoveryquestions WHERE bookkey = @i_bookkey AND sortorder = @v_sortorder) 
			AND (datalength(commenthtml) > 0 OR datalength(commenthtmllite) > 0 OR datalength(commenttext) > 0)

		  -- only delete and insert if comment is not filled in already
		  IF @v_count = 0 BEGIN
			SELECT @v_newquestioncommentkey =  questioncommentkey FROM discoveryquestions WHERE bookkey = @i_bookkey AND sortorder = @v_sortorder
			  IF @v_newquestioncommentkey IS NOT NULL BEGIN
				SELECT @v_lastuserid = lastuserid, @v_lastmaintdate = lastmaintdate,  @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
				FROM qsicomments
				WHERE commentkey = @v_newquestioncommentkey
		   
				DELETE FROM qsicomments
				WHERE commentkey = @v_newquestioncommentkey
				AND commenttypecode = @v_commenttypecode 
				AND commenttypesubcode = @v_commenttypesubcode 
		               
				INSERT INTO qsicomments
				  (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
				invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
				SELECT @v_newquestioncommentkey, commenttypecode, commenttypesubcode, parenttable, 
				  commenttext, commenthtml, commenthtmllite, invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
				FROM qsicomments
				WHERE commentkey = @v_questioncommentkey

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_code = 1
					SET @o_error_desc = 'Unable to copy from template (qsicomments): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR) + 
					  ' templateprintingkey = ' + cast(@i_templateprintingkey AS VARCHAR)
					RETURN
				END
			  END
		  END

		  SELECT @v_count = count(*)
		  FROM qsicomments
		  WHERE commentkey IN (SELECT answercommentkey FROM discoveryquestions WHERE bookkey = @i_bookkey AND sortorder = @v_sortorder) 
			AND (datalength(commenthtml) > 0 OR datalength(commenthtmllite) > 0 OR datalength(commenttext) > 0)

		  -- only delete and insert if comment is not filled in already
		  IF @v_count = 0 BEGIN
			SELECT @v_newanswercommentkey =  answercommentkey FROM discoveryquestions WHERE bookkey = @i_bookkey AND sortorder = @v_sortorder
			  IF @v_newanswercommentkey IS NOT NULL BEGIN
				SELECT @v_lastuserid = lastuserid, @v_lastmaintdate = lastmaintdate,  @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
				FROM qsicomments
				WHERE commentkey = @v_newanswercommentkey
		   
				DELETE FROM qsicomments
				WHERE commentkey = @v_newanswercommentkey
				AND commenttypecode = @v_commenttypecode 
				AND commenttypesubcode = @v_commenttypesubcode 
		               
				INSERT INTO qsicomments
				  (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
				invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
				SELECT @v_newanswercommentkey, commenttypecode, commenttypesubcode, parenttable, 
				  commenttext, commenthtml, commenthtmllite, invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
				FROM qsicomments
				WHERE commentkey = @v_answercommentkey

				SELECT @v_error = @@ERROR
				IF @v_error <> 0 BEGIN
					SET @o_error_code = 1
					SET @o_error_desc = 'Unable to copy from template (qsicomments): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR) + 
					  ' templateprintingkey = ' + cast(@i_templateprintingkey AS VARCHAR)
					RETURN
				END
			  END
		  END
	  END
      FETCH NEXT FROM crDiscoveryQuestions INTO @v_questioncommentkey, @v_answercommentkey, @v_discoverykey, @v_sortorder
    END
    
    CLOSE crDiscoveryQuestions
    DEALLOCATE crDiscoveryQuestions
	END
  
  /* Copy qsicomments - associatedtitles Comment1 and Comment2 */  
  DECLARE assocomments_cur CURSOR FOR
    SELECT associationtypecode, associationtypesubcode, commentkey1, commentkey2, sortorder, associatetitlebookkey
    FROM associatedtitles
    WHERE bookkey = @i_bookkey
    ORDER BY associationtypecode, associationtypesubcode, sortorder
    
  OPEN assocomments_cur

  FETCH NEXT FROM assocomments_cur 
  INTO @v_assotype, @v_assosubtype, @v_commentkey1, @v_commentkey2, @v_sortorder, @v_associatetitlebookkey

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN 
    
    IF @v_commentkey1 > 0
    BEGIN
      DELETE FROM qsicomments 
      WHERE commentkey = @v_commentkey1
    
      INSERT INTO qsicomments
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
      SELECT @v_commentkey1, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
      FROM qsicomments
      WHERE commentkey IN 
        (SELECT commentkey1 FROM associatedtitles
        WHERE bookkey = @i_templatebookkey AND associationtypecode = @v_assotype AND 
              associationtypesubcode = @v_assosubtype AND sortorder = @v_sortorder AND associatetitlebookkey = @v_associatetitlebookkey)
           
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from template (associatedtitles Comment1): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR)
        RETURN
      END
    END
    
    IF @v_commentkey2 > 0
    BEGIN
      DELETE FROM qsicomments 
      WHERE commentkey = @v_commentkey2
    
      INSERT INTO qsicomments
        (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, releasetoeloquenceind, lastuserid, lastmaintdate)
      SELECT @v_commentkey2, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, 
        invalidhtmlind, 0, @v_lastuserid, @v_lastmaintdate
      FROM qsicomments
      WHERE commentkey IN 
        (SELECT commentkey2 FROM associatedtitles
        WHERE bookkey = @i_templatebookkey AND associationtypecode = @v_assotype AND 
              associationtypesubcode = @v_assosubtype AND sortorder = @v_sortorder AND associatetitlebookkey = @v_associatetitlebookkey)
           
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Unable to copy from template (associatedtitles Comment2): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR)
        RETURN
      END
    END
  
    FETCH NEXT FROM assocomments_cur 
    INTO @v_assotype, @v_assosubtype, @v_commentkey1, @v_commentkey2, @v_sortorder, @v_associatetitlebookkey
  END
  
  CLOSE assocomments_cur
  DEALLOCATE assocomments_cur  


  /* ELEMENTS */
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 17) = 'Y' --Elements
  BEGIN
  
    EXEC qproject_copy_project_element 
      NULL, --copy_projectkey
	  NULL,  --@i_copy2_projectkey
      @i_templatebookkey, @i_templateprintingkey, 
      NULL, --copy_elementkey
      NULL, --new_projectkey
      @i_bookkey, @i_printingkey,
      @i_userid,
      @i_copydatagroups_list,
      @i_cleardatagroups_list,
      @v_elementkey OUTPUT,
      @o_error_code OUTPUT,
      @o_error_desc OUTPUT

    IF @o_error_code <> 0 BEGIN
      RETURN
    END 
  
  END --Elements

  /* BOOKKEYWORDS */  
  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 22) = 'Y'  --Bookkeywords
  BEGIN
	EXEC qtitle_update_Keywords_ONIX @i_bookkey, @i_userid, 0, @v_error, @v_errordesc
	SELECT @v_error = @@ERROR
	IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'error adding bookkeywords: bookkey = ' + cast(COALESCE(@i_bookkey, 0) AS VARCHAR)
		RETURN
	END	
  END
  
  --PRINT '** inside qtitle_copy_title_addtl_info:'
  --PRINT '@i_bookkey=' + convert(varchar, @i_bookkey)
  --PRINT '@i_printingkey=' + convert(varchar, @i_printingkey)
  --PRINT '@i_templatebookkey=' + convert(varchar, @i_templatebookkey)
  
  SELECT @v_count = COUNT(*)
  FROM taqprojectprinting_view
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
  
  --PRINT '@v_count=' + convert(varchar, @v_count)
  
  IF @v_count = 0 BEGIN -- Printing project doesn't exist yet - create   
    EXEC qprinting_prtgproj_from_prtgtbl @i_bookkey, @i_printingkey, @i_userid, @v_error OUT, @v_errordesc OUT
  END
  
  SELECT @v_projectkey = taqprojectkey
  FROM taqprojectprinting_view
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  
  SELECT @v_itemtype_qsicode = g.qsicode, @v_usageclass_qsicode = sg.qsicode,
    @v_itemtypecode = sg.datacode, @v_usageclasscode = sg.datasubcode 
  FROM taqproject p
  JOIN gentables g
	ON p.searchitemcode = g.datacode
	AND g.tableid = 550
  JOIN subgentables sg
	ON p.searchitemcode = sg.datacode
	AND p.usageclasscode = sg.datasubcode
	AND sg.tableid = 550
  WHERE taqprojectkey = @v_projectkey  
          
  --PRINT '@v_projectkey=' + convert(varchar, @v_projectkey)
  --PRINT '@v_itemtype_qsicode=' + convert(varchar, @v_itemtype_qsicode)
  --PRINT '@v_usageclass_qsicode=' + convert(varchar, @v_usageclass_qsicode)

  SELECT TOP(1) @v_templateprojectkey = taqprojectkey -- Copy from 1st Printing
  FROM taqprojectprinting_view
  WHERE bookkey = @i_templatebookkey
  ORDER BY printingkey asc 	
  
  --PRINT '@v_templateprojectkey=' + convert(varchar, @v_templateprojectkey)
  
  IF @v_templateprojectkey > 0 BEGIN
	  /* Copy Production Specifications */
	  IF dbo.find_integer_in_comma_delim_list(@i_copydatagroups_list, 8) = 'Y' --Copy Production Specifications
	  BEGIN
	  
	  SET @o_error_desc = ''	
	  DECLARE taqversionformat_cursor CURSOR FOR
		SELECT taqprojectformatkey
		FROM taqversionformat
		WHERE taqprojectkey = @v_projectkey

		OPEN taqversionformat_cursor

		FETCH taqversionformat_cursor
		INTO @v_TaqProjectFormatKey

		WHILE (@@FETCH_STATUS = 0)
		BEGIN  			
				
		  EXEC qspec_apply_specificationtemplate @v_projectkey, @v_templateprojectkey,
			@v_TaqProjectFormatKey, @v_itemtypecode, @v_usageclasscode, @i_userid, 4, 0, 0, @o_error_code OUTPUT, @o_error_desc OUTPUT		

			SELECT @v_error = @@ERROR
			IF @v_error <> 0 BEGIN
				SET @o_error_code = 1
				SET @o_error_desc = 'Unable to copy from template (Production Specifications): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR) + 
				  ' templateprintingkey = ' + cast(@i_templateprintingkey AS VARCHAR)
				RETURN
			END
			
			FETCH taqversionformat_cursor
			INTO @v_TaqProjectFormatKey
		END

		CLOSE taqversionformat_cursor
		DEALLOCATE taqversionformat_cursor 	
	  
	  END --Copy Production Specifications  
  END
  
  --Add a Summary component with specification items if it not present for the Title's first Printings
  EXEC dbo.qprinting_insert_first_printings_summarycomponent @v_projectkey, 0, 0, @i_userid, @o_error_code OUTPUT,@o_error_desc OUTPUT
	SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
	 SET @o_error_code = 1
	 SET @o_error_desc = 'Unable to copy from template (Production Specifications): templatebookkey = ' + cast(@i_templatebookkey AS VARCHAR) + 
		' templateprintingkey = ' + cast(@i_templateprintingkey AS VARCHAR)
	 RETURN
  END  

END
GO

GRANT EXEC ON qtitle_copy_title_addtl_info TO PUBLIC
GO
