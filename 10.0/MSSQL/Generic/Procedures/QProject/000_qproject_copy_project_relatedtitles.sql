if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_relatedtitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_relatedtitles
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE qproject_copy_project_relatedtitles (  
  @i_copy_projectkey  integer,
  @i_copy2_projectkey integer,
  @i_new_projectkey   integer,
  @i_projectrole  integer,
  @i_titlerole    integer,
  @i_userid   varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: qproject_copy_project_relatedtitles
**  Desc: This stored procedure copies related titles on a project.
**        If projectrole/titlerole is filled in, the procedure will only copy
**        those taqprojecttitle that match projectrole/titlerole.
**        If projectrole/titlerole are zero, procedure will copy all records.
**
**        If you call this procedure from anyplace other than qproject_copy_project,
**        you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate
**  Date: February 6 2009
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/11/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
**    06/22/2016   Colman			 Do not copy if title role or project role are item type filtered out 
*****************************************************************************************************************************/

DECLARE
  @v_assotype INT,
  @v_assosubtype  INT,
  @v_counter  INT,
  @v_error  INT,
  @v_newkey INT,
  @v_num_rows INT,
  @v_tobecopiedkey  INT,
  @v_seasoncode INT, 
  @v_seasonfirmind  TINYINT, 
  @v_mediatypecode  INT, 
  @v_mediatypesubcode INT,
  @v_discountcode SMALLINT,
  @v_price  NUMERIC(9,2),
  @v_initialrun INT,
  @v_projectdollars NUMERIC(15,2), 
  @v_marketingplancode  INT, 
  @v_primaryformatind TINYINT,
  @v_isbn VARCHAR(13), 
  @v_isbn10 VARCHAR(10),
  @v_ean  VARCHAR(17), 
  @v_ean13  VARCHAR(13), 
  @v_gtin VARCHAR(19), 
  @v_gtin14 VARCHAR(14), 
  @v_bookkey  INT, 
  @v_taqprojectformatdesc VARCHAR(120), 
  @v_isbnprefixcode INT, 
  @v_lccn VARCHAR(50), 
  @v_dsmarc VARCHAR(50), 
  @v_itemnumber VARCHAR(20), 
  @v_upc  VARCHAR(50),
  @v_eanprefixcode  INT, 
  @v_printingkey  INT,
  @v_projectrolecode  INT, 
  @v_titlerolecode  INT,
  @v_keyind TINYINT,
  @v_sortorder  INT, 
  @v_indicator1 TINYINT, 
  @v_indicator2 TINYINT,
  @v_quantity1  INT,
  @v_quantity2  INT, 
  @v_relateditem2name VARCHAR(100), 
  @v_relateditem2status VARCHAR(100), 
  @v_relateditem2participants VARCHAR(100), 
  @v_productidtype  INT, 
  @v_title  VARCHAR(255),
  @v_authorname VARCHAR(255), 
  @v_editiondescription VARCHAR(150),
  @v_bisacstatus  INT, 
  @v_pubdate  DATETIME,
  @v_illustrations  VARCHAR(255),
  @v_origpubhousecode INT,
  @v_pagecount  INT,
  @v_salesunitgross INT,
  @v_salesunitnet INT,
  @v_bookpos  INT,
  @v_lifetodatepointofsale  INT,
  @v_yeartodatepointofsale  INT,
  @v_previousyearpointofsale  INT,
  @v_commentkey1  INT, 
  @v_commentkey2  INT,
  @v_new_commentkey1  INT, 
  @v_new_commentkey2  INT,
  @v_decimal1 DECIMAL(14, 4),
  @v_decimal2 DECIMAL(14, 4),
  @v_newprojectitemtype			INT,
  @v_newprojectusageclass		INT,
  @v_commenttypecode			INT,
  @v_commenttypesubcode			INT    
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  if @i_copy_projectkey is null or @i_copy_projectkey = 0
  begin
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Copy projectkey not passed to copy related titles.'
	  RETURN
  end

  if @i_new_projectkey is null or @i_new_projectkey = 0
  begin
	  SET @o_error_code = -1
	  SET @o_error_desc = 'New projectkey not passed to copy related titles.'
	  RETURN
  end
  
  IF @i_projectrole IS NULL
    SET @i_projectrole = 0
  IF @i_titlerole IS NULL
    SET @i_titlerole = 0
    
-- only want to copy items types that are defined for the new project
  IF (@i_new_projectkey > 0)
  BEGIN
    SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
    FROM taqproject
    WHERE taqprojectkey = @i_new_projectkey

    IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
    BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Unable to copy relatedtitles because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	  RETURN
    END
  
    IF @v_newprojectusageclass is null 
      SET @v_newprojectusageclass = 0
  END     

  IF @i_projectrole = 0 AND @i_titlerole = 0  --copy all
    SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(taqprojectformatkey)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey AND
      titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
  ELSE IF @i_projectrole = 0 AND @i_titlerole > 0
    SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(taqprojectformatkey)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey AND
      titlerolecode = @i_titlerole AND
      titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
  ELSE IF @i_projectrole > 0 AND @i_titlerole = 0
    SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(taqprojectformatkey)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey AND
      projectrolecode = @i_projectrole AND
      titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
  ELSE
    SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(taqprojectformatkey)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_copy_projectkey AND
      projectrolecode = @i_projectrole AND 
      titlerolecode = @i_titlerole AND
      titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)

  SET @v_counter = 1
  WHILE @v_counter <= @v_num_rows
  BEGIN
    EXEC get_next_key @i_userid, @v_newkey OUTPUT

    DECLARE taqprojecttitle_cur CURSOR FOR
      SELECT seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
        isbn, isbn10, ean, ean13, gtin, gtin14, lccn, dsmarc, itemnumber, upc, 
        eanprefixcode, isbnprefixcode, bookkey, printingkey, taqprojectformatdesc, 			  
        projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
        quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, 
        productidtype, title, authorname, editiondescription, bisacstatus, pubdate, illustrations, 
        origpubhousecode, pagecount, salesunitgross, salesunitnet, bookpos, 
        lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale, commentkey1, commentkey2,
        associationtypecode, associationtypesubcode, decimal1, decimal2  
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy_projectkey AND 
        taqprojectformatkey = @v_tobecopiedkey AND 
        titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)

    OPEN taqprojecttitle_cur 	

    FETCH NEXT FROM taqprojecttitle_cur 
    INTO @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
      @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
      @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, 
      @v_eanprefixcode, @v_isbnprefixcode, @v_bookkey, @v_printingkey, @v_taqprojectformatdesc, 			  
      @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
      @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, 
      @v_productidtype, @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, 
      @v_origpubhousecode, @v_pagecount, @v_salesunitgross, @v_salesunitnet, @v_bookpos, 
      @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, @v_commentkey1, @v_commentkey2,
      @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2

    WHILE (@@FETCH_STATUS = 0)
    BEGIN

      SET @v_new_commentkey1 = NULL
      SET @v_new_commentkey2 = NULL
      
      
      -- Both project role and title role must be item type filtered in to do the copy
      IF    @v_projectrolecode IS NOT NULL AND @v_projectrolecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(604, @v_newprojectitemtype, @v_newprojectusageclass))
        AND @v_titlerolecode IS NOT NULL AND @v_titlerolecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(605, @v_newprojectitemtype, @v_newprojectusageclass))
      BEGIN
        SELECT @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
        FROM qsicomments WHERE commentkey = @v_commentkey1
        
        IF (@v_commentkey1 IS NOT NULL AND @v_commenttypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_commentkey1 = NULL	
        END
        ELSE IF (@v_commentkey1 IS NOT NULL AND @v_commenttypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_commenttypecode)) BEGIN
          SET @v_commentkey1 = NULL	
        END     

        IF (COALESCE(@v_commentkey1, 0) > 0)
        BEGIN	
          EXEC qproject_copy_project_qsicomments @v_commentkey1, @i_userid, @v_new_commentkey1 OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

          IF @v_error <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Copy/insert into qsicomments failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
            BREAK
          END						
        END
        
        SELECT @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
        FROM qsicomments WHERE commentkey = @v_commentkey2      
        
        IF (@v_commentkey2 IS NOT NULL AND @v_commenttypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_commentkey2 = NULL	
        END
        ELSE IF (@v_commentkey2 IS NOT NULL AND @v_commenttypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_commenttypecode)) BEGIN
          SET @v_commentkey2 = NULL	
        END       

        IF (COALESCE(@v_commentkey2, 0) > 0)
        BEGIN	
          EXEC qproject_copy_project_qsicomments @v_commentkey2, @i_userid, @v_new_commentkey2 OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

          IF @v_error <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Copy/insert into qsicomments failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
            BREAK
          END
        END
        
        IF (@v_seasoncode IS NOT NULL AND @v_seasoncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(329, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_seasoncode = NULL	
        END
          
        IF (@v_mediatypecode IS NOT NULL AND @v_mediatypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_mediatypecode = NULL	
          SET @v_mediatypesubcode = NULL
        END
        ELSE IF (@v_mediatypesubcode IS NOT NULL AND @v_mediatypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_mediatypecode)) BEGIN	
          SET @v_mediatypesubcode = NULL
        END     
          
        IF (@v_discountcode IS NOT NULL AND @v_discountcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(459, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_discountcode = NULL	
        END    
          
        IF (@v_marketingplancode IS NOT NULL AND @v_marketingplancode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(524, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_marketingplancode = NULL	
        END    
          
        IF (@v_eanprefixcode IS NOT NULL AND @v_eanprefixcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(138, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_eanprefixcode = NULL	
        END
        
        IF (@v_isbnprefixcode IS NOT NULL AND @v_isbnprefixcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(138, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_eanprefixcode)) BEGIN
          SET @v_isbnprefixcode = NULL	
        END		  	  
          
        IF (@v_productidtype IS NOT NULL AND @v_productidtype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_productidtype = NULL	
        END 	
        
        IF (@v_bisacstatus IS NOT NULL AND @v_bisacstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(314, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_bisacstatus = NULL	
        END	   
        
        IF (@v_origpubhousecode IS NOT NULL AND @v_origpubhousecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(126, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_origpubhousecode = NULL	
        END	  
        
        IF (@v_assotype IS NOT NULL AND @v_assotype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(440, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
          SET @v_assotype = NULL	
        END
        
        IF (@v_assosubtype IS NOT NULL AND @v_assosubtype NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(440, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_assotype)) BEGIN
          SET @v_assosubtype = NULL	
        END	  	   	 	  

        INSERT INTO taqprojecttitle
          (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
          discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
          isbn, isbn10, ean, ean13, gtin, gtin14, bookkey, taqprojectformatdesc, isbnprefixcode,
          lastuserid, lastmaintdate, lccn, dsmarc, itemnumber, upc, eanprefixcode, printingkey,
          projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
          quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, productidtype, 
          title, authorname, editiondescription, bisacstatus, pubdate, illustrations, origpubhousecode, pagecount, 
          salesunitgross, salesunitnet, bookpos, lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale, 
          commentkey1, commentkey2, associationtypecode, associationtypesubcode, decimal1, decimal2)
        VALUES(@v_newkey, @i_new_projectkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
          @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
          @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_bookkey, @v_taqprojectformatdesc, @v_isbnprefixcode,
          @i_userid, getdate(), @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, @v_eanprefixcode, @v_printingkey,
          @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
          @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, @v_productidtype,
          @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, @v_origpubhousecode, @v_pagecount, 
          @v_salesunitgross, @v_salesunitnet, @v_bookpos, @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, 
          @v_new_commentkey1, @v_new_commentkey2, @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2)

        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Copy/insert into taqprojecttitle failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
          RETURN
        END 
      END
      
      FETCH NEXT FROM taqprojecttitle_cur 
      INTO @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
        @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
        @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, 
        @v_eanprefixcode, @v_isbnprefixcode, @v_bookkey, @v_printingkey, @v_taqprojectformatdesc, 			  
        @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
        @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, 
        @v_productidtype, @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, 
        @v_origpubhousecode, @v_pagecount, @v_salesunitgross, @v_salesunitnet, @v_bookpos, 
        @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, @v_commentkey1, @v_commentkey2,
        @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2
    END  /*LOOP taqprojecttitle_cur */

    CLOSE taqprojecttitle_cur 
    DEALLOCATE taqprojecttitle_cur 

    SET @v_counter = @v_counter + 1

    IF @i_projectrole = 0 AND @i_titlerole = 0  --copy all
      SELECT @v_tobecopiedkey = MIN(taqprojectformatkey)
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqprojectformatkey > @v_tobecopiedkey AND
        titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
    ELSE IF @i_projectrole = 0 AND @i_titlerole > 0
      SELECT @v_tobecopiedkey = MIN(taqprojectformatkey)
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqprojectformatkey > @v_tobecopiedkey AND
        titlerolecode = @i_titlerole AND
        titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) 
    ELSE IF @i_projectrole > 0 AND @i_titlerole = 0
      SELECT @v_tobecopiedkey = MIN(taqprojectformatkey)
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqprojectformatkey > @v_tobecopiedkey AND
        projectrolecode = @i_projectrole AND
        titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
    ELSE
      SELECT @v_tobecopiedkey = MIN(taqprojectformatkey)
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_copy_projectkey AND
        taqprojectformatkey > @v_tobecopiedkey AND
        projectrolecode = @i_projectrole AND 
        titlerolecode = @i_titlerole AND
        titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)
  END --WHILE LOOP

  /* 5/4/12 - KW - From case 17842:
  Related Titles (15):  copy from i_copy_projectkey; add project/title roles from i_copy2_projectkey */  
  IF @i_copy2_projectkey > 0
  BEGIN
    IF @i_projectrole = 0 AND @i_titlerole = 0  --copy all
      SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND
        t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
        NOT EXISTS (SELECT * FROM taqprojecttitle t2
                    WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                      t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                      t2.taqprojectkey = @i_copy_projectkey)
    ELSE IF @i_projectrole = 0 AND @i_titlerole > 0
      SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND
        t1.titlerolecode = @i_titlerole AND
        t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
        NOT EXISTS (SELECT * FROM taqprojecttitle t2
                    WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                      t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                      t2.taqprojectkey = @i_copy_projectkey)
    ELSE IF @i_projectrole > 0 AND @i_titlerole = 0
      SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND
        t1.projectrolecode = @i_projectrole AND
        t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
        NOT EXISTS (SELECT * FROM taqprojecttitle t2
                    WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                      t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                      t2.taqprojectkey = @i_copy_projectkey)
    ELSE
      SELECT @v_num_rows = COUNT(*), @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
      FROM taqprojecttitle t1
      WHERE t1.taqprojectkey = @i_copy2_projectkey AND
        t1.projectrolecode = @i_projectrole AND 
        t1.titlerolecode = @i_titlerole AND
        t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
        NOT EXISTS (SELECT * FROM taqprojecttitle t2
                    WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                      t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                      t2.taqprojectkey = @i_copy_projectkey) 

    -- try to keep the same order as on original projects (copy_projectkey and copy2_projectkey):
    -- put copy2_projectkey titles after copied copy_projectkey titles
    SET @v_sortorder = 10000
    SET @v_counter = 1    
    
    WHILE @v_counter <= @v_num_rows
    BEGIN
      EXEC get_next_key @i_userid, @v_newkey OUTPUT

      DECLARE taqprojecttitle_cur CURSOR FOR
        SELECT seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
          discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
          isbn, isbn10, ean, ean13, gtin, gtin14, lccn, dsmarc, itemnumber, upc, 
          eanprefixcode, isbnprefixcode, bookkey, printingkey, taqprojectformatdesc, 			  
          projectrolecode, titlerolecode, keyind, indicator1, indicator2,
          quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, 
          productidtype, title, authorname, editiondescription, bisacstatus, pubdate, illustrations, 
          origpubhousecode, pagecount, salesunitgross, salesunitnet, bookpos, 
          lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale, commentkey1, commentkey2,
          associationtypecode, associationtypesubcode, decimal1, decimal2
        FROM taqprojecttitle
        WHERE taqprojectkey = @i_copy2_projectkey AND 
          taqprojectformatkey = @v_tobecopiedkey AND 
          titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)

      OPEN taqprojecttitle_cur 	

      FETCH NEXT FROM taqprojecttitle_cur 
      INTO @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
        @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
        @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, 
        @v_eanprefixcode, @v_isbnprefixcode, @v_bookkey, @v_printingkey, @v_taqprojectformatdesc, 			  
        @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_indicator1, @v_indicator2,
        @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, 
        @v_productidtype, @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, 
        @v_origpubhousecode, @v_pagecount, @v_salesunitgross, @v_salesunitnet, @v_bookpos, 
        @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, @v_commentkey1, @v_commentkey2,
        @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2

      WHILE (@@FETCH_STATUS = 0)
      BEGIN

        SET @v_new_commentkey1 = NULL
        SET @v_new_commentkey2 = NULL
        
        SELECT @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
        FROM qsicomments WHERE commentkey = @v_commentkey1
      
	    IF (@v_commentkey1 IS NOT NULL AND @v_commenttypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_commentkey1 = NULL	
	    END
	    ELSE IF (@v_commentkey1 IS NOT NULL AND @v_commenttypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_commenttypecode)) BEGIN
	      SET @v_commentkey1 = NULL	
	    END        

        IF (COALESCE(@v_commentkey1, 0) > 0)
        BEGIN	
          EXEC qproject_copy_project_qsicomments @v_commentkey1, @i_userid, @v_new_commentkey1 OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

          IF @v_error <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Copy/insert into qsicomments failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
            BREAK
          END						
        END
        
        SELECT @v_commenttypecode = commenttypecode, @v_commenttypesubcode = commenttypesubcode 
        FROM qsicomments WHERE commentkey = @v_commentkey2      
      
	    IF (@v_commentkey2 IS NOT NULL AND @v_commenttypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_commentkey2 = NULL	
	    END
	    ELSE IF (@v_commentkey2 IS NOT NULL AND @v_commenttypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(534, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_commenttypecode)) BEGIN
	      SET @v_commentkey2 = NULL	
	    END         

        IF (COALESCE(@v_commentkey2, 0) > 0)
        BEGIN	
          EXEC qproject_copy_project_qsicomments @v_commentkey2, @i_userid, @v_new_commentkey2 OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

          IF @v_error <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Copy/insert into qsicomments failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
            BREAK
          END
        END
        
	    IF (@v_seasoncode IS NOT NULL AND @v_seasoncode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(329, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_seasoncode = NULL	
	    END
	    
	    IF (@v_mediatypecode IS NOT NULL AND @v_mediatypecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_mediatypecode = NULL	
	      SET @v_mediatypesubcode = NULL
	    END
	    ELSE IF (@v_mediatypesubcode IS NOT NULL AND @v_mediatypesubcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(312, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_mediatypecode)) BEGIN	
	      SET @v_mediatypesubcode = NULL
	    END     
	    
	    IF (@v_discountcode IS NOT NULL AND @v_discountcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(459, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_discountcode = NULL	
	    END    
	    
	    IF (@v_marketingplancode IS NOT NULL AND @v_marketingplancode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(524, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_marketingplancode = NULL	
	    END    
	  
	    IF (@v_isbnprefixcode IS NOT NULL AND @v_isbnprefixcode NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(138, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_marketingplancode)) BEGIN
	      SET @v_isbnprefixcode = NULL	
	    END	  

	    IF (@v_eanprefixcode IS NOT NULL AND @v_eanprefixcode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(138, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_eanprefixcode = NULL	
	    END	  
	    
	    IF (@v_projectrolecode IS NOT NULL AND @v_projectrolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(604, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_projectrolecode = NULL	
	    END     
	    
	    IF (@v_titlerolecode IS NOT NULL AND @v_titlerolecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(605, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_titlerolecode = NULL	
	    END      
	  
	    IF (@v_productidtype IS NOT NULL AND @v_productidtype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(551, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_productidtype = NULL	
	    END 	
	  
	    IF (@v_bisacstatus IS NOT NULL AND @v_bisacstatus NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(314, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_bisacstatus = NULL	
	    END	   
	  
	    IF (@v_origpubhousecode IS NOT NULL AND @v_origpubhousecode NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(126, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_origpubhousecode = NULL	
	    END	  
	  
	    IF (@v_assotype IS NOT NULL AND @v_assotype NOT IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(440, @v_newprojectitemtype, @v_newprojectusageclass))) BEGIN
	      SET @v_assotype = NULL	
	    END
	  
	    IF (@v_assosubtype IS NOT NULL AND @v_assosubtype NOT IN (SELECT datasubcode FROM qutl_get_gentable_itemtype_filtering(440, @v_newprojectitemtype, @v_newprojectusageclass) WHERE datacode = @v_assotype)) BEGIN
	      SET @v_assosubtype = NULL	
	    END        

        INSERT INTO taqprojecttitle
          (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
          discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
          isbn, isbn10, ean, ean13, gtin, gtin14, bookkey, taqprojectformatdesc, isbnprefixcode,
          lastuserid, lastmaintdate, lccn, dsmarc, itemnumber, upc, eanprefixcode, printingkey,
          projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
          quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, productidtype, 
          title, authorname, editiondescription, bisacstatus, pubdate, illustrations, origpubhousecode, pagecount, 
          salesunitgross, salesunitnet, bookpos, lifetodatepointofsale, yeartodatepointofsale, previousyearpointofsale, 
          commentkey1, commentkey2, associationtypecode, associationtypesubcode, decimal1, decimal2)
        VALUES(@v_newkey, @i_new_projectkey, @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
          @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
          @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_bookkey, @v_taqprojectformatdesc, @v_isbnprefixcode,
          @i_userid, getdate(), @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, @v_eanprefixcode, @v_printingkey,
          @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_sortorder, @v_indicator1, @v_indicator2,
          @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, @v_productidtype,
          @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, @v_origpubhousecode, @v_pagecount, 
          @v_salesunitgross, @v_salesunitnet, @v_bookpos, @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, 
          @v_new_commentkey1, @v_new_commentkey2, @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2)

        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Copy/insert into taqprojecttitle failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
          RETURN
        END 

        FETCH NEXT FROM taqprojecttitle_cur 
        INTO @v_seasoncode, @v_seasonfirmind, @v_mediatypecode, @v_mediatypesubcode,
          @v_discountcode, @v_price, @v_initialrun, @v_projectdollars, @v_marketingplancode, @v_primaryformatind,
          @v_isbn, @v_isbn10, @v_ean, @v_ean13, @v_gtin, @v_gtin14, @v_lccn, @v_dsmarc, @v_itemnumber, @v_upc, 
          @v_eanprefixcode, @v_isbnprefixcode, @v_bookkey, @v_printingkey, @v_taqprojectformatdesc, 			  
          @v_projectrolecode, @v_titlerolecode, @v_keyind, @v_indicator1, @v_indicator2,
          @v_quantity1, @v_quantity2, @v_relateditem2name, @v_relateditem2status, @v_relateditem2participants, 
          @v_productidtype, @v_title, @v_authorname, @v_editiondescription, @v_bisacstatus, @v_pubdate, @v_illustrations, 
          @v_origpubhousecode, @v_pagecount, @v_salesunitgross, @v_salesunitnet, @v_bookpos, 
          @v_lifetodatepointofsale, @v_yeartodatepointofsale, @v_previousyearpointofsale, @v_commentkey1, @v_commentkey2,
          @v_assotype, @v_assosubtype, @v_decimal1, @v_decimal2
      END  /*LOOP taqprojecttitle_cur */

      CLOSE taqprojecttitle_cur 
      DEALLOCATE taqprojecttitle_cur 

      SET @v_counter = @v_counter + 1
      SET @v_sortorder = @v_sortorder + 1

      IF @i_projectrole = 0 AND @i_titlerole = 0  --copy all
        SELECT @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
        FROM taqprojecttitle t1
        WHERE t1.taqprojectkey = @i_copy2_projectkey AND
          t1.taqprojectformatkey > @v_tobecopiedkey AND
          t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
          NOT EXISTS (SELECT * FROM taqprojecttitle t2
                      WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                        t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                        t2.taqprojectkey = @i_copy_projectkey)
      ELSE IF @i_projectrole = 0 AND @i_titlerole > 0
        SELECT @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
        FROM taqprojecttitle t1
        WHERE t1.taqprojectkey = @i_copy2_projectkey AND
          t1.taqprojectformatkey > @v_tobecopiedkey AND
          t1.titlerolecode = @i_titlerole AND
          t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
          NOT EXISTS (SELECT * FROM taqprojecttitle t2
                      WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                        t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                        t2.taqprojectkey = @i_copy_projectkey)
      ELSE IF @i_projectrole > 0 AND @i_titlerole = 0
        SELECT @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
        FROM taqprojecttitle t1
        WHERE t1.taqprojectkey = @i_copy2_projectkey AND
          t1.taqprojectformatkey > @v_tobecopiedkey AND
          t1.projectrolecode = @i_projectrole AND
          t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
          NOT EXISTS (SELECT * FROM taqprojecttitle t2
                      WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                        t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                        t2.taqprojectkey = @i_copy_projectkey)
      ELSE
        SELECT @v_tobecopiedkey = MIN(t1.taqprojectformatkey)
        FROM taqprojecttitle t1
        WHERE t1.taqprojectkey = @i_copy2_projectkey AND
          t1.taqprojectformatkey > @v_tobecopiedkey AND
          t1.projectrolecode = @i_projectrole AND 
          t1.titlerolecode = @i_titlerole AND
          t1.titlerolecode NOT IN (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
          NOT EXISTS (SELECT * FROM taqprojecttitle t2
                      WHERE t1.bookkey = t2.bookkey AND t1.printingkey = t2.printingkey AND
                        t1.titlerolecode = t2.titlerolecode AND t1.projectrolecode = t2.projectrolecode AND
                        t2.taqprojectkey = @i_copy_projectkey)		  
    END --WHILE LOOP
  END --IF @i_copy2_projectkey > 0

END
GO

GRANT EXEC ON qproject_copy_project_relatedtitles TO PUBLIC
GO
