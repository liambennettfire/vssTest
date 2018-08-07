if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_update_bookcomments_for_generatedauthorbio') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_update_bookcomments_for_generatedauthorbio
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_update_bookcomments_for_generatedauthorbio
AS

/***************************************************************************************************************************************************
**  Name: qtitle_update_bookcomments_for_generatedauthorbio
**  Desc: This Procedure generates the  generated Author Bio Comment for a title based on the Titles Primary Authors Biography Comment Information.
**
**  Auth: Uday A. Khisty
**  Date: 05/26/2015
****************************************************************************************************************************************************
**    Change History
*******************************************************************************
**    Date:      Author:     Description:
**    --------   --------    -------------------------------------------
**   01/21/2016  UK			 Case 32274 - Task 007
*******************************************************************************/

BEGIN

  DECLARE @v_commenttypecode_qsicomments_authorbio	INT,
		  @v_commenttypesubcode_qsicomments_authorbio INT,		  
		  @v_commenttypecode_bookcomments	INT,
		  @v_commenttypesubcode_bookcomments INT,		  
		  @v_commenthtml		NVARCHAR(MAX),		
		  @v_commenthtml_Final	NVARCHAR(MAX),	  
		  @v_authorkey			INT,
		  @v_displayname		VARCHAR(255),
		  @v_error			    INT,
		  @v_rowcount			INT,
		  @v_bookkey			INT,
		  @v_printingkey		INT,
		  @o_error_code			INT,
		  @o_error_desc			varchar(2000),
		  @v_lastuserid			varchar(30),
		  @v_datadesc			varchar(120),
		  @v_ActionType		VARCHAR(20),
		  @v_HistoryColumn	VARCHAR(120),
		  @v_tablename      varchar(100),
	      @v_columnname     varchar(100),
	      @v_count	INT,
	      @datacode_TitleAuthorBio INT,
	      @datasubcode_TitleAuthorBio INT,
	      @v_releasetoeloquence_TitleAuthorBio INT,
	      @v_sendtitletooutbox INT,
	      @v_elo_in_cloud INT
		  
	CREATE TABLE #regenerateauthorbio 
	 (
	   id UNIQUEIDENTIFIER NULL,
	   bookkey int NULL,
	   printingkey int NULL,
	   lastuserid  VARCHAR(30) NULL
	 )		  
	 
  CREATE TABLE #propagatetitle (
	bookkey int not null,
	tablename varchar(100) null,
	columnname varchar(100) null)	 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_releasetoeloquence_TitleAuthorBio = 0
  SET @v_sendtitletooutbox = 0
  -- check to see if client is using elo in cloud
  SET @v_elo_in_cloud = 0
  
  SELECT @v_elo_in_cloud = coalesce(optionvalue,0)
    FROM clientoptions
   WHERE optionid = 111
  
  SET @v_commenttypesubcode_qsicomments_authorbio = 0
  SELECT @v_commenttypecode_bookcomments = datacode, @v_commenttypesubcode_bookcomments  = datasubcode FROM subgentables WHERE tableid = 284 AND qsicode = 7         
  SELECT @v_commenttypecode_qsicomments_authorbio = datacode FROM gentables WHERE tableid = 528 AND qsicode = 2  
  SELECT @v_datadesc = datadesc FROM subgentables WHERE tableid = 284 AND qsicode = 7
  SELECT @datacode_TitleAuthorBio = datacode, @datasubcode_TitleAuthorBio = datasubcode FROM subgentables WHERE tableid = 284 AND qsicode = 1 
  
  SET @v_datadesc = '(G) ' + @v_datadesc
    
 -- IF @v_commenttypecode <> @v_commenttypecode_qsicomments_authorbio
	--GOTO ExitHandler   
	
  WHILE(EXISTS(SELECT * FROM regenerateauthorbio)) BEGIN
    DELETE FROM #regenerateauthorbio
    
	INSERT INTO #regenerateauthorbio (id, bookkey, printingkey, lastuserid)
	SELECT TOP(1000) id,bookkey, printingkey, lastuserid FROM regenerateauthorbio
	
	DECLARE crRegenerateAuthorBio CURSOR FOR
	SELECT distinct bookkey, printingkey, lastuserid
	FROM #regenerateauthorbio
	OPEN crRegenerateAuthorBio 

	FETCH NEXT FROM crRegenerateAuthorBio INTO @v_bookkey, @v_printingkey, @v_lastuserid

	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	
	  IF COALESCE(@v_bookkey, 0) <= 0 OR  COALESCE(@v_printingkey, 0) <= 0 BEGIN
		PRINT 'Invalid bookkey and printingkey: bookkey = ' + CONVERT(INT, @v_bookkey) + ' printingkey = ' + CONVERT(INT, @v_printingkey)		
		FETCH NEXT FROM crRegenerateAuthorBio INTO @v_bookkey, @v_printingkey  
	  END	
	
	  SET @v_commenthtml_Final = NULL

	  DECLARE crPrimaryTitleAuthors CURSOR FOR
	  SELECT ba.authorkey, ltrim(rtrim([dbo].[rpt_get_contact_name](gc.globalcontactkey,'c'))), CONVERT(NVARCHAR(MAX), qc.commenthtml)
	  FROM coretitleinfo c INNER JOIN bookdetail bd
  		  ON bd.bookkey = c.bookkey
		 INNER JOIN bookauthor ba
		  ON c.bookkey = ba.bookkey 
		 INNER JOIN globalcontact gc
		  ON  gc.globalcontactkey = ba.authorkey
		 INNER JOIN qsicomments qc
		  ON  qc.commentkey = gc.globalcontactkey
	  WHERE ba.primaryind  = 1 AND
			ba.authorkey = gc.globalcontactkey AND 
			qc.commenttypecode = @v_commenttypecode_qsicomments_authorbio AND 
			qc.commenttypesubcode = @v_commenttypesubcode_qsicomments_authorbio AND
			c.bookkey = @v_bookkey AND 
			c.printingkey = @v_printingkey AND
			qc.commenthtml IS NOT NULL AND
			qc.releasetoeloquenceind = 1
	  ORDER BY COALESCE(ba.sortorder, 99999) ASC	
		   
	  OPEN crPrimaryTitleAuthors 

	  FETCH NEXT FROM crPrimaryTitleAuthors INTO @v_authorkey, @v_displayname, @v_commenthtml

	  WHILE (@@FETCH_STATUS <> -1)
	  BEGIN		
		  IF @v_displayname IS NOT NULL BEGIN
			 SET @v_displayname = '<B>' + @v_displayname + '</B>'				 
		  END
		
		  IF @v_commenthtml_Final IS NULL BEGIN
			 IF @v_displayname IS NULL BEGIN
				SET @v_commenthtml_Final = @v_commenthtml
			 END 
			 ELSE BEGIN
   				SET @v_commenthtml_Final = @v_displayname + '<BR />' + @v_commenthtml
			 END
		  END
		  ELSE BEGIN
			 IF @v_displayname IS NULL BEGIN
				SET @v_commenthtml_Final = @v_commenthtml_Final + '<BR />' + @v_commenthtml				   
			 END 
			 ELSE BEGIN
				SET @v_commenthtml_Final = @v_commenthtml_Final + '<BR />' + @v_displayname + '<BR />' + @v_commenthtml		   
			 END			   		   			
		  END										

		FETCH NEXT FROM crPrimaryTitleAuthors INTO @v_authorkey, @v_displayname, @v_commenthtml
	  END /* WHILE FECTHING */

	  CLOSE crPrimaryTitleAuthors 
	  DEALLOCATE crPrimaryTitleAuthors		

	  IF @v_commenthtml_Final IS NOT NULL BEGIN
		  IF EXISTS(SELECT * FROM bookcomments WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode_bookcomments AND commenttypesubcode = @v_commenttypesubcode_bookcomments)
		  BEGIN   	
			  SET @v_ActionType = 'update'							
		  END
		  ELSE BEGIN
			  SET @v_ActionType = 'insert'
		  END							      	  				
	  END		
	  ELSE BEGIN
	      SET @v_ActionType = 'delete'		 
	      
		  IF NOT EXISTS(SELECT * FROM bookcomments WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode_bookcomments AND commenttypesubcode = @v_commenttypesubcode_bookcomments)
		  BEGIN  
			 FETCH NEXT FROM crRegenerateAuthorBio INTO @v_bookkey, @v_printingkey, @v_lastuserid
			 CONTINUE
		  END	      
	  END	  	  
	  
	  
	  IF @v_ActionType = 'delete' BEGIN
		  DECLARE column_cursor CURSOR FOR
			SELECT DISTINCT columnname
			FROM titlehistorycolumns
			WHERE tablename = 'bookcomments'
      END
      ELSE BEGIN        
        DECLARE column_cursor CURSOR FOR
          SELECT 'commenthtml'
          UNION
          SELECT 'commentstring'
          UNION
      	  SELECT DISTINCT columnname
		  FROM titlehistorycolumns
		  WHERE tablename = 'bookcomments'	
      END
		   
	  OPEN column_cursor 

	  FETCH NEXT FROM column_cursor INTO @v_HistoryColumn

	  WHILE (@@FETCH_STATUS <> -1)
	  BEGIN	
	   EXEC qtitle_update_titlehistory 'bookcomments', @v_HistoryColumn, @v_bookkey, 
		@v_printingkey, 0, 1, @v_ActionType, @v_lastuserid, 
		0, @v_datadesc, @o_error_code OUTPUT, @o_error_desc OUTPUT

		IF @o_error_code <> 0 BEGIN
		  GOTO ExitHandler
		END

        INSERT INTO #propagatetitle (bookkey,tablename,columnname)
        VALUES (@v_bookkey,@v_ActionType,@v_HistoryColumn)

        IF @@ERROR <> 0 BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Error occurred while inserting to #propagatetitle'
          GOTO ExitHandler
        END
            	  
		FETCH NEXT FROM column_cursor INTO @v_HistoryColumn
	  END /* WHILE FECTHING */

	  CLOSE column_cursor 
	  DEALLOCATE column_cursor		  
		  		  
	IF @v_commenthtml_Final IS NOT NULL BEGIN		  
	  IF @v_ActionType = 'update' BEGIN
		  UPDATE bookcomments SET commenthtml = CONVERT(NTEXT, @v_commenthtml_Final), lastuserid = @v_lastuserid, lastmaintdate = GETDATE()
		  WHERE bookkey = @v_bookkey AND 
		  printingkey = @v_printingkey AND 
		  commenttypecode = @v_commenttypecode_bookcomments AND 
		  commenttypesubcode = @v_commenttypesubcode_bookcomments AND
		  releasetoeloquenceind = 1				  	  		  
	  END
	  ELSE IF @v_ActionType = 'insert' BEGIN
		  INSERT INTO bookcomments(bookkey, printingkey, commenttypecode, commenttypesubcode, commenthtml, releasetoeloquenceind, lastuserid, lastmaintdate)
		  VALUES(@v_bookkey, @v_printingkey, @v_commenttypecode_bookcomments,@v_commenttypesubcode_bookcomments, CONVERT(NTEXT, @v_commenthtml_Final), 1, @v_lastuserid, GETDATE())  		  		  
  	  END
  	  
	  SET @o_error_code = 0
	  SET @o_error_desc = ''					
	   -- update htmllite column		  
	  EXECUTE html_to_lite_from_row_new @v_bookkey,@v_printingkey,@v_commenttypecode_bookcomments,@v_commenttypesubcode_bookcomments,'BOOKCOMMENTS',0,
								  @o_error_code output,@o_error_desc output
								  
      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error occurred while doing html_to_lite_from_row_new for bookkey: ' + @v_bookkey + ' printingkey: ' + @v_printingkey
        GOTO ExitHandler
      END								  
								  
	  SET @o_error_code = 0
	  SET @o_error_desc = ''					
	   -- update htmllite column									  
	  -- update text column
	  EXECUTE html_to_text_from_row_new @v_bookkey,@v_printingkey,@v_commenttypecode_bookcomments,@v_commenttypesubcode_bookcomments,'BOOKCOMMENTS',
								  @o_error_code output,@o_error_desc output		  
								  
      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error occurred while doing html_to_text_from_row_new for bookkey: ' + @v_bookkey + ' printingkey: ' + @v_printingkey
        GOTO ExitHandler
      END								  	  
  	END  
    ELSE IF @v_ActionType = 'delete' BEGIN
	    DELETE FROM bookcomments
	    WHERE bookkey = @v_bookkey AND 
			printingkey = @v_printingkey AND 
			commenttypecode = @v_commenttypecode_bookcomments AND 
			commenttypesubcode = @v_commenttypesubcode_bookcomments	  	  
    END
      	  	  
      	  	
	  -- may need to propagate data for a title
	DECLARE propagatetitle_cur CURSOR FOR
	 SELECT bookkey,tablename,columnname
	 FROM #propagatetitle 
	  
	 OPEN propagatetitle_cur
	 FETCH NEXT FROM propagatetitle_cur INTO @v_bookkey,@v_tablename,@v_columnname
	 WHILE (@@FETCH_STATUS <> -1) BEGIN
	    IF @v_tablename = 'bookcomments' AND @v_columnname = 'releasetoeloquenceind' BEGIN
			  SELECT @v_count = 0

		  SELECT @v_count = count(*)
				FROM #propagatetitle
		   WHERE @v_tablename = 'bookcomments' 
			 AND @v_columnname = 'commentstring'
			 AND bookkey = @v_bookkey 
	       
		  SET @o_error_code = 0
		  SET @o_error_desc = ''	  
		       
		  IF @v_count = 0 BEGIN	
			 EXECUTE qtitle_copy_work_info @v_bookkey, @v_tablename, @v_columnname, @o_error_code OUTPUT, @o_error_desc OUTPUT			 
		  END
		END 
		ELSE
		BEGIN
		   EXECUTE qtitle_copy_work_info @v_bookkey, @v_tablename, @v_columnname, @o_error_code OUTPUT, @o_error_desc OUTPUT	   
		END
	    
		IF @o_error_code < 0 BEGIN
		  SET @o_error_desc = 'Error occurred while doing qtitle_copy_work_info for bookkey: ' + @v_bookkey + ' printingkey: ' + @v_printingkey		
		  -- Error
		  SET @o_error_code = -1
		  CLOSE propagatetitle_cur
		  DEALLOCATE propagatetitle_cur
		  goto ExitHandler
		END
		FETCH NEXT FROM propagatetitle_cur INTO @v_bookkey,@v_tablename,@v_columnname
	 END

	  CLOSE propagatetitle_cur
	  DEALLOCATE propagatetitle_cur	        	  	  
	      	  	  
	  -- if Author Bio has No Comment OR it has the releasetoeloquenceind 0 or NULL, send the title to Outbox	 
	  
	  IF NOT EXISTS(SELECT * FROM bookcomments WHERE bookkey = @v_bookkey  AND commenttypecode = @datacode_TitleAuthorBio AND commenttypesubcode = @datasubcode_TitleAuthorBio) BEGIN
		SET @v_sendtitletooutbox = 1
	  END  
	  ELSE BEGIN
		SELECT @v_releasetoeloquence_TitleAuthorBio =  COALESCE(releasetoeloquenceind, 0) FROM bookcomments WHERE bookkey = @v_bookkey  AND commenttypecode = @datacode_TitleAuthorBio AND commenttypesubcode = @datasubcode_TitleAuthorBio  		
		
		IF @v_releasetoeloquence_TitleAuthorBio = 0 BEGIN
			SET @v_sendtitletooutbox = 1
		END
	  END
	  
	  IF @v_sendtitletooutbox = 1 BEGIN	  
		-- ELO in the cloud - update bookdetail
		EXECUTE qtitle_update_bookdetail_csmetadatastatuscode @v_bookkey, @v_lastuserid, @o_error_code OUTPUT, @o_error_desc OUTPUT
		IF @o_error_code < 0 BEGIN
		  -- Error
		  SET @o_error_code = -1
		  --SET @o_error_desc = 'Unable to update bookdetail.'
		  CLOSE crRegenerateAuthorBio
		  DEALLOCATE crRegenerateAuthorBio
		  goto ExitHandler			  
		END 
		    	  
		IF @v_elo_in_cloud <> 1 BEGIN  -- update bookedistatus
			EXECUTE qtitle_update_bookedistatus @v_bookkey, @v_printingkey, @v_lastuserid, @o_error_code OUTPUT, @o_error_desc OUTPUT
			IF @o_error_code < 0 BEGIN
			  -- Error
			  SET @o_error_code = -1
			  --SET @o_error_desc = 'Unable to update bookedistatus.'
			  CLOSE crRegenerateAuthorBio
			  DEALLOCATE crRegenerateAuthorBio
			  goto ExitHandler
			END			 
		END	  
	  END
	  
	  FETCH NEXT FROM crRegenerateAuthorBio INTO @v_bookkey, @v_printingkey, @v_lastuserid
	END /* WHILE FECTHING */

	CLOSE crRegenerateAuthorBio 
	DEALLOCATE crRegenerateAuthorBio		
	
	-- DELETE rows in regenerateauthorbio from #regenerateauthorbio	
	DELETE FROM regenerateauthorbio WHERE id IN (SELECT id FROM #regenerateauthorbio) 
	DELETE FROM #regenerateauthorbio	
  END	 	  
  
------------
ExitHandler:
------------
  DROP TABLE #regenerateauthorbio
  DROP TABLE #propagatetitle
END
GO

GRANT EXEC ON qtitle_update_bookcomments_for_generatedauthorbio TO PUBLIC
GO
