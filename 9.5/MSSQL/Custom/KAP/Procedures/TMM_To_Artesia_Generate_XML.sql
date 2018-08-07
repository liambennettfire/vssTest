IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMM_To_Artesia_Generate_XML]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TMM_To_Artesia_Generate_XML]
go

CREATE procedure [dbo].[TMM_To_Artesia_Generate_XML] 
 (@i_batchkey      integer,
  @i_jobkey         integer,
  @i_jobtypecode    integer,
  @i_jobtypesubcode integer,  
  @o_error_code    integer output,
  @o_error_desc    varchar(2000) output)
AS

DECLARE
  @v_error int, 
  @v_error_desc varchar(2000),
  @v_rowcount int,
  @v_count int,
  @v_bookkey int,
  @v_lastrundate datetime, 
	@v_titlefetchstatus int,
	@v_seqnum int,
	@v_latest_printingnum int, 
	@v_latest_printingkey int,
	@v_workkey int,
	@v_title_xml xml,
	@v_category_xml xml,
	@v_dates_xml xml,
	@v_authors_xml xml,
	@v_contributor_xml xml,
	@v_prices_xml xml,
	@v_vendor_xml xml,
	@v_related_formats_xml xml,
	@v_other_relationships_xml xml,
	@v_related_titles xml,
	@v_messagetypecode int,
  @v_msg varchar(4000),
  @v_msgshort varchar(255),
  @v_num_titles int,
  @v_titleverifystatuscode int,
  @v_qsicode  int,
  @v_ean varchar(50),
  @v_last_sent_to_artesia_datetype int
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_last_sent_to_artesia_datetype = 703
  
  IF (@i_batchkey > 0) BEGIN
    SELECT @v_seqnum = 0
    
	  DECLARE c_titles CURSOR fast_forward FOR
     SELECT bookkey	FROM TMMToArtesia_bookkeys
  			
	  OPEN c_titles 

	  FETCH NEXT FROM c_titles INTO @v_bookkey
	  SELECT @v_titlefetchstatus  = @@FETCH_STATUS
    
    WHILE (@v_titlefetchstatus = 0) BEGIN       
      -- find latest printing
      SELECT @v_latest_printingnum = max(printingnum)
        FROM printing
       WHERE bookkey = @v_bookkey

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error looking for latest printing number'
        SET @v_msgshort = 'Error looking for latest printing number'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      IF @v_latest_printingnum > 1 BEGIN
        SELECT @v_latest_printingkey = printingkey
          FROM printing
         WHERE bookkey = @v_bookkey
           AND printingnum = @v_latest_printingnum
           
        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_error <> 0 BEGIN
          /*  Error */
          SET @v_messagetypecode = 2
          SET @v_msg = 'Error looking for latest printing number'
          SET @v_msgshort = 'Error looking for latest printing number'
          EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
          goto get_next_row 
        END           
      END
      ELSE BEGIN
        SET @v_latest_printingkey = 1
        SET @v_latest_printingnum = 1
      END

      -- verify title has necessary fields filled in (verificationtypecode = 5)
      execute TMM_to_Artesia_Verify_Title @v_bookkey, @v_latest_printingkey, 5, 'TMMArtesia'
      
      SELECT @v_titleverifystatuscode = COALESCE(titleverifystatuscode,0)
        FROM bookverification
       WHERE bookkey = @v_bookkey
         AND verificationtypecode = 5

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error accessing titleverification'
        SET @v_msgshort = 'Error accessing titleverification'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
         
      -- find qsicode for @v_titleverifystatuscode
      SELECT @v_qsicode = COALESCE(qsicode,0)
        FROM gentables 
       WHERE tableid = 513
         AND datacode = @v_titleverifystatuscode

      -- only allow titles that pass verification to be exported
      IF @v_qsicode NOT in (3,4) BEGIN
        DELETE FROM TMMToArtesia_bookkeys
        WHERE bookkey = @v_bookkey

        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_error <> 0 BEGIN
          /*  Error */
          SET @v_messagetypecode = 2
          SET @v_msg = 'Error removing title from TMMToArtesia_bookkeys' 
          SET @v_msgshort = 'Error removing title from TMMToArtesia_bookkeys'
          EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
          goto get_next_row 
        END           
       
        /*  Error - Title failed verification */
        SELECT @v_ean = COALESCE(ean, ' ')
          FROM coretitleinfo
         WHERE bookkey = @v_bookkey
           AND printingkey = @v_latest_printingkey
           
        SET @v_messagetypecode = 2
        SET @v_msg = 'Title Verification failed (' + @v_ean + ')'
        SET @v_msgshort = 'Title Verification failed (' + @v_ean + ')'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, @v_latest_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        
        goto get_next_row 
      END
                  
      -- generate authors XML
      SET @v_authors_xml = 
     (SELECT COALESCE(ltrim(rtrim(dbo.rpt_get_author(bookkey,sortorder,0,'D'))),'') as "AuthorName",
             COALESCE(ltrim(rtrim(dbo.rpt_get_author_type(bookkey,sortorder,'D'))),'') as "AuthorType",
             COALESCE(ltrim(rtrim(dbo.rpt_get_contact_best_method(authorkey,3))),'') as "AuthorEmail",  -- tableid 517 / datacode 3 is email
             COALESCE(sortorder,0) as "AuthorOrder"
        FROM bookauthor 
       WHERE bookauthor.bookkey = @v_bookkey
    ORDER BY bookauthor.sortorder
      FOR XML PATH('Author')) 

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating authors xml'
        SET @v_msgshort = 'Error generating authors xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- generate BISAC Category XML
      SET @v_category_xml = 
     (SELECT COALESCE(ltrim(rtrim(dbo.rpt_get_gentables_desc(339,bisaccategorycode,'long'))),'') as "BISACCategoryName",
             COALESCE(ltrim(rtrim(dbo.rpt_get_subgentables_desc(339,bisaccategorycode,bisaccategorysubcode,'long'))),'') as "BISACSubCategoryName"
        FROM bookbisaccategory 
       WHERE bookbisaccategory.bookkey = @v_bookkey
         AND bookbisaccategory.printingkey = 1
      FOR XML PATH('BISACCategory'))

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating category xml'
        SET @v_msgshort = 'Error generating category xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- generate Dates XML
      SET @v_dates_xml = 
      (SELECT 
        (SELECT 'Publication' as "DateType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_best_key_date(@v_bookkey,1,8))),'') as "DateValue"
         FOR XML PATH('Date'), TYPE),
        (SELECT 'Release' as "DateType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_best_key_date(@v_bookkey,1,32))),'') as "DateValue"
         FOR XML PATH('Date'), TYPE),
        (SELECT 'Warehouse' as "DateType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_best_key_date(@v_bookkey,1,47))),'') as "DateValue"
         FOR XML PATH('Date'), TYPE) 
       FOR XML PATH(''))
       
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating dates xml'
        SET @v_msgshort = 'Error generating dates xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 1, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
       
      -- generate Contributor XML for the following specific contributors:
      -- Acquisition Editor (rolecode 41) / Development Editor (rolecode 49)
      -- Production Editor (rolecode 5) / Typesetter (rolecode 43)
      -- Cover Manager (rolecode 3) / Manufracturing Manager (rolecode 1)
      SET @v_contributor_xml =
      (SELECT 
       COALESCE(g.datadesc,'') as "ContributorType", 
       COALESCE(ltrim(rtrim(dbo.qtitle_get_participant_name_by_role(@v_bookkey,@v_latest_printingkey,g.datacode))),'') as "ContributorName"
			  FROM gentables g
		   WHERE g.tableid = 285
			   AND g.datacode in (1,3,5,41,43,49) 
     FOR XML PATH('Contributor'))

  --    (SELECT 
  --      COALESCE(dbo.rpt_get_gentables_desc(285,br.rolecode,'long'),'') as "ContributorType", 
  --      COALESCE(ltrim(rtrim(dbo.rpt_get_contact_name(bc.globalcontactkey,'D'))),'') as "ContributorName"
  -- 			 FROM bookcontactrole br, bookcontact bc
  --		  WHERE br.bookcontactkey = bc.bookcontactkey
  --			  AND bc.bookkey = @v_bookkey
  --			  AND bc.printingkey = @v_latest_printingkey
  --			  AND br.rolecode in (1,3,5,41,43,49) 
  --	 ORDER BY bc.sortorder
  --    FOR XML PATH('Contributor')) 

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating contributor xml'
        SET @v_msgshort = 'Error generating contributor xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, @v_latest_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- Prices XML
      SET @v_prices_xml = 
      (SELECT 
        (SELECT 'US Retail' as "PriceType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_price(@v_bookkey,8,6,'B'))),'') as "PriceValue"
         FOR XML PATH('Price'), TYPE),
        (SELECT 'Canadian Retail' as "PriceType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_price(@v_bookkey,8,11,'B'))),'') as "PriceValue"
         FOR XML PATH('Price'), TYPE),
        (SELECT 'UK Retail' as "PriceType", 
         COALESCE(ltrim(rtrim(dbo.rpt_get_price(@v_bookkey,8,37,'B'))),'') as "PriceValue"
         FOR XML PATH('Price'), TYPE) 
       FOR XML PATH(''))

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating prices xml'
        SET @v_msgshort = 'Error generating prices xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- Vendors from Finalized POs XML
      SET @v_vendor_xml = 
      (SELECT distinct COALESCE(ltrim(rtrim(dbo.rpt_get_vendor_name(g.vendorkey))),'') as "VendorName" 
        FROM gpo g, gposection s
       WHERE g.gpokey = s.gpokey
         AND upper(ltrim(rtrim(g.gpostatus))) = 'F'
         AND s.key1 = @v_bookkey
         AND s.key2 = @v_latest_printingkey
       FOR XML PATH('Vendor')) 

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating vendor xml'
        SET @v_msgshort = 'Error generating vendor xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, @v_latest_printingkey, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- related titles
      -- Related Formats
      SELECT @v_workkey = COALESCE(workkey,0)
        FROM book
       WHERE bookkey = @v_bookkey
      
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating related titles xml'
        SET @v_msgshort = 'Error generating related titles xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
      
      IF @v_workkey = @v_bookkey BEGIN
        -- this title is a parent so get the children
        SET @v_related_formats_xml = 
        (SELECT bookkey as "RelatedBookKey",
                COALESCE(dbo.rpt_get_isbn(bookkey,16),'') as "RelatedIsbn13",
                'Child' as "RelationshipType"
           FROM book 
          WHERE book.workkey = @v_workkey
            AND book.workkey <> book.bookkey
          FOR XML PATH('Relationship'))     
      END
      ELSE BEGIN
        -- this title is a child so get the parent
        SET @v_related_formats_xml = 
        (SELECT bookkey as "RelatedBookKey",
                COALESCE(dbo.rpt_get_isbn(bookkey,16),'') as "RelatedIsbn13",
                'Parent' as "RelationshipType"
           FROM book 
          WHERE book.bookkey = @v_workkey
          FOR XML PATH('Relationship')) 
      END

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating related titles xml'
        SET @v_msgshort = 'Error generating related titles xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- Other Relationships
      SET @v_other_relationships_xml = 
      (SELECT childbookkey as "RelatedBookKey",
              COALESCE(dbo.rpt_get_isbn(childbookkey,16),'') as "RelatedIsbn13",
              COALESCE(dbo.rpt_get_gentables_desc(145,relationcode,'long'),'Related Title') as "RelationshipType"           
         FROM bookfamily
        WHERE parentbookkey = @v_bookkey
        FOR XML PATH('Relationship'))     

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating other relationships xml'
        SET @v_msgshort = 'Error generating other relationships xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      SET @v_related_titles =  
      (SELECT COALESCE(@v_related_formats_xml,'') as "*",
              COALESCE(@v_other_relationships_xml,'') as "*"
        FOR XML PATH(''))     

      SELECT @v_seqnum = @v_seqnum + 1

      -- final title XML
      SET @v_title_xml = 
      (SELECT @v_seqnum as "@SequenceNumber", 
             c.bookkey as "BookKey",
             COALESCE(ean,'') as "Isbn13",
             COALESCE(dbo.rpt_get_title(c.bookkey,'F'),'') as "ProductTitle",
             COALESCE(subtitle,'') as "SubTitle",
             COALESCE(seriesdesc,'') as "Series",
             COALESCE(bd.editiondescription,'') as "Edition",
             COALESCE(@v_authors_xml,'') as "Authors",
             COALESCE(dbo.rpt_get_gentables_desc(132,titletypecode,'long'),'') as "ProductType",
             COALESCE(dbo.rpt_get_misc_value(c.bookkey,48,''),'') as "DigitalShortRun",
             COALESCE(dbo.rpt_get_gentables_desc(312,c.mediatypecode,'long'),'') as "Media",
             COALESCE(formatname,'') as "Format", 
             COALESCE(imprintname,'') as "Imprint",
             COALESCE(bisacstatusdesc,'') as "BISACStatus",
             COALESCE(dbo.rpt_get_misc_value(c.bookkey,7,'long'),'') as "RevisionLevel",
             COALESCE(seasondesc,'') as "Season",
             @v_latest_printingnum as "LatestPrintingNumber",
             COALESCE(dbo.rpt_get_best_trim_size(c.bookkey,@v_latest_printingkey),'') as "TrimSize",
             COALESCE(@v_category_xml,'') as "BISACCategories",
             COALESCE(@v_dates_xml,'') as "Dates",
             COALESCE(@v_contributor_xml,'') as "Contributors",
             COALESCE(@v_prices_xml,'') as "Prices",
             COALESCE(@v_vendor_xml,'') as "Vendors",
             COALESCE(@v_related_titles,'') as "Relationships"
        FROM coretitleinfo c, bookdetail bd
       WHERE c.bookkey = bd.bookkey 
         AND c.bookkey = @v_bookkey 
         AND c.printingkey = 1 
      FOR XML PATH('Title'), TYPE)

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error generating title xml'
        SET @v_msgshort = 'Error generating title xml'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 

      -- save Final Title XML to table
      UPDATE TMMToArtesia_bookkeys
         SET title_xml = @v_title_xml
       WHERE bookkey = @v_bookkey
       
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error updating TMMToArtesia_bookkeys'
        SET @v_msgshort = 'Error updating TMMToArtesia_bookkeys'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
       
      -- set Last Sent to Artesia Date Type
      SELECT @v_count = count(*)
        FROM bookdates
       WHERE bookkey = @v_bookkey
         AND printingkey = 1
         AND datetypecode = @v_last_sent_to_artesia_datetype
         
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error accessing bookdates (Last Sent to Artesia)'
        SET @v_msgshort = 'Error accessing bookdates'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
      
      IF @v_count > 0 BEGIN
        -- update
        UPDATE bookdates
           SET activedate = getdate(),
               lastuserid = 'TMMArtesia',
               lastmaintdate = getdate()
         WHERE bookkey = @v_bookkey
           AND printingkey = 1
           AND datetypecode = @v_last_sent_to_artesia_datetype
      END 
      ELSE BEGIN
        -- insert 
        INSERT INTO bookdates (bookkey,printingkey,datetypecode,activedate,lastuserid,lastmaintdate)
        VALUES (@v_bookkey,1,@v_last_sent_to_artesia_datetype,getdate(),'TMMArtesia',getdate())
      END

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error updating Last Sent to Artesia on bookdates'
        SET @v_msgshort = 'Error updating bookdates'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', @v_bookkey, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_error OUTPUT, @v_error_desc OUTPUT         
        goto get_next_row 
      END 
      
      get_next_row:
  	  FETCH NEXT FROM c_titles INTO @v_bookkey
	    SELECT @v_titlefetchstatus  = @@FETCH_STATUS
	  END

    CLOSE c_titles
    DEALLOCATE c_titles 
    
    finished:    
    IF @o_error_code >= 0 BEGIN
      -- return the number of titles
      SELECT @v_num_titles = count(*)
        FROM TMMToArtesia_bookkeys
       WHERE title_xml is not null

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        SET @v_num_titles = 0
        /*  Error */
        SET @v_messagetypecode = 2
        SET @v_msg = 'Error accessing TMMToArtesia_bookkeys'
        SET @v_msgshort = 'Error accessing TMMToArtesia_bookkeys'
        EXEC dbo.WRITE_QSIJOBMESSAGE @i_batchkey OUTPUT, @i_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', 'TMMArtesia', 0, 0, 0, @v_messagetypecode, @v_msg, @v_msg, @v_error OUTPUT, @v_error_desc OUTPUT          
      END 
      
      SET @o_error_code = @v_num_titles
    END
  END
  ELSE BEGIN
    -- no batchkey 
    SET @o_error_code = -1
    SET @o_error_desc = 'Batchkey is empty'
    return
  END
END

grant execute on TMM_To_Artesia_Generate_XML  to public
go






