-- Drop this procedure if it already exists
PRINT 'deletetitle_delete_printing'
GO
IF object_id('deletetitle_delete_printing ') IS NOT NULL
BEGIN
    DROP PROCEDURE deletetitle_delete_printing
END 
GO

/********************************************************************************************/ 
/*This procedure deletes from printing and printingkey related tables based on bookkey      */ 
/********************************************************************************************/ 

CREATE PROCEDURE deletetitle_delete_printing
	@delete_title_bookkey	INT,
	@delete_title_printingkey INT,
	@illus_chgcode1 INT,
	@illus_chgcode2 INT,
	@text_chgcode1 INT,
	@text_chgcode2 INT,
	@mms_option CHAR(1),
    @delete_title_userid varchar(30),
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS
print 'in procedure'
DECLARE	@res INT,
	@err_msg varchar(255),
    @v_count INT,
	@v_count2	INT,
    @v_taqprojectkey  INT,
    @v_otherdefaultrelationshipcode INT,
    @v_count_pos	INT

BEGIN
    SELECT @v_count = 0
    SELECT @error_code = 0
    SELECT @error_desc = ''
    
	
	SELECT @v_count = COUNT(*)
	  FROM booklock
	 WHERE bookkey = @delete_title_bookkey
	   AND printingkey in (0,@delete_title_printingkey)
	   AND LOWER(userid) <> @delete_title_userid
	   
	IF @v_count > 0 BEGIN
		SELECT @err_msg = 'This title can not be deleted because it is locked by another user.'  
        PRINT @err_msg
        SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END
	
	
	SELECT @v_count = 0
    SELECT @error_code = 0
    SELECT @error_desc = ''
	    
    SELECT @v_count = count(*) 
	  FROM contract
	 WHERE primarybookkey = @delete_title_bookkey
			
			
	IF @v_count > 0 BEGIN 
		SELECT @err_msg = 'This title can not be deleted because it is associated with a contract.'
		PRINT @err_msg
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 

    SELECT  @v_count = 0

    SELECT @v_count = count(*) 
	  FROM taqprojectelement, coretitleinfo,gentables  
	 WHERE ( taqprojectelement.bookkey = coretitleinfo.bookkey )   
	   AND ( taqprojectelement.elementstatus = gentables.datacode )  
	   AND ( taqprojectelement.printingkey = coretitleinfo.printingkey )  
	   AND ( taqprojectelement.bookkey = @delete_title_bookkey )   
	   AND ( taqprojectelement.printingkey = 1 )   
	   AND ( gentables.tableid = 593 ) AND (gentables.qsicode > 0 AND gentables.qsicode <> 4)  
	   AND ( coretitleinfo.csapprovalcode = 1 ) 

     IF @v_count > 0 BEGIN
	  	 SELECT @err_msg = 'This title can not be deleted because assets have been uploaded for title.'
		 PRINT @err_msg
		 --GOTO finished
		 SELECT @error_code = -1
		 SELECT @error_desc = @err_msg 
		 RETURN
	 END 

	SELECT @v_count = 0
	SELECT @v_count2 = 0

	SELECT @v_count =count(*)
	  FROM taqproject
	 WHERE workkey = @delete_title_bookkey
	--print '@delete_title_bookkey'
	--print @delete_title_bookkey			
	IF @v_count > 0 BEGIN
		SELECT @v_count2 = count(*)
		  FROM book
		 WHERE workkey = @delete_title_bookkey
           AND bookkey <> @delete_title_bookkey
		--print '@v_count2'
		--print @v_count2		   				
		IF @v_count2 > 0 BEGIN
			SELECT @err_msg = 'This title cannot be deleted because it has subordinate titles for an existing work.'
			PRINT @err_msg
			--GOTO finished
			SELECT @error_code = -1
			SELECT @error_desc = @err_msg 
			RETURN
	 	END 
	END
	
	--KB 4/23/2015 Do not delete title/printings with associated Purchase orders
	SELECT @v_count = 0
	
	SELECT @v_count = count(*)
	  FROM taqproject tp, taqprojecttitle tl
	 WHERE tp.taqprojectkey = tl.taqprojectkey
	   AND tp.searchitemcode = 14 
	   AND tp.usageclasscode = 1
	   AND tl.bookkey = @delete_title_bookkey
	   AND tl.printingkey = @delete_title_printingkey
	   
	IF @v_count = 1 BEGIN
		SELECT @v_taqprojectkey = tl.taqprojectkey
		  FROM taqproject tp, taqprojecttitle tl
		 WHERE tp.taqprojectkey = tl.taqprojectkey
		   AND tp.searchitemcode = 14 
		   AND tp.usageclasscode = 1
		   AND tl.bookkey = @delete_title_bookkey
		   AND tl.printingkey = @delete_title_printingkey
		   
		SELECT @v_otherdefaultrelationshipcode = datacode FROM gentables WHERE tableid = 582 and qsicode = 26
	
		SELECT @v_count_pos= 0
		
		SELECT @v_count_pos = count(*)  
		  FROM projectrelationshipview v, taqproject p  
		 WHERE v.relatedprojectkey = p.taqprojectkey 
		   AND v.taqprojectkey =  @v_taqprojectkey 
		   AND v.relationshipcode =  @v_otherdefaultrelationshipcode
		   
		IF @v_count_pos > 0 BEGIN
			SELECT @err_msg = 'Unable to Delete Printing Project: Purchase Orders exist for project.'
			PRINT @err_msg
			--GOTO finished
			SELECT @error_code = -1
			SELECT @error_desc = @err_msg 
			RETURN
		END
	END
	
	
	/* delete from printing-level tables   */
	/* delete from bisaccategory  */
	DELETE FROM bookbisaccategory WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookbisaccategory for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 

	/* delete from bookcomments */
	DELETE FROM bookcomments WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey  
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookcomments for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from bookcommentrtf  */
	DELETE FROM bookcommentrtf WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookcommentrtf for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

    /* delete from bookedipartner  */
    DELETE FROM bookedipartner WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookedipartner for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 

    /* delete from bookedistatus  */
    DELETE FROM bookedistatus WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookedistatus for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END
		
	/* delete from bookdates  */
	DELETE FROM bookdates WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookdates for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from bookfile  */
	DELETE FROM bookfile WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookfile for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from datehistory  */
	DELETE FROM datehistory WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from datehistory for bookkey ' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	
	/* delete any associated printings (taqprojects on web) for the title being deleted */
	EXEC delete_title_associatedprintings @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	 IF @error_code != 0 BEGIN
		--SELECT @err_msg = @err_msg + ' Error executing delete_title_associatedprintings proc for bookkey ' + convert(char(10),@delete_title_bookkey) 
        PRINT @err_msg
        --GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	 END

	/*delete or update rows(by nulling out bookkey/printingkey) on taqprojecttask and related tables*/
	 EXEC delete_title_taqprojecttask @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	 IF @error_code != 0 BEGIN 
	 	SELECT @err_msg = 'Error executing delete_title_taqprojecttask proc for bookkey ' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	 END

     /*delete or update rows(by nulling out bookkey/printingkey) on taqprojecttitle table*/
	 EXEC delete_title_taqprojecttitle @delete_title_bookkey,@delete_title_printingkey,@delete_title_userid,@error_code OUTPUT,@err_msg OUTPUT
	 IF @error_code != 0 BEGIN
		SELECT @err_msg = 'Error executing delete_title_taqprojecttitle proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	 END

	 /* #17692  - Deleting titles creates orphaned rows on the taqprojectelement table*/
     SELECT @v_count = 0

	 SELECT @v_count = count(*)
	   FROM taqprojectelement 
	  WHERE bookkey = @delete_title_bookkey
        AND printingkey = @delete_title_printingkey;

     IF @v_count > 0
     BEGIN
         SELECT @v_taqprojectkey = taqprojectkey
           FROM taqprojectelement 
	      WHERE bookkey = @delete_title_bookkey
            AND printingkey = @delete_title_printingkey;

         IF @v_taqprojectkey IS NULL BEGIN

		/* Delete taqproejctelement row  */
			DELETE FROM taqprojectelement WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey  
				AND (taqprojectkey = 0 OR taqprojectkey IS NULL);
			
			IF @@error != 0 BEGIN
				SELECT @err_msg = 'Error deleting from taqprojectelement for bookkey' + convert(char(10),@delete_title_bookkey) 
				  + ' and for printingkey 0' 
				PRINT @err_msg
				--GOTO finished
				SELECT @error_code = -1
				SELECT @error_desc = @err_msg 
				RETURN 
			END 
         END
         ELSE BEGIN
			UPDATE taqprojectelement
               SET bookkey = NULL,
                   printingkey = NULL
             WHERE taqprojectkey = @v_taqprojectkey 
               AND bookkey = @delete_title_bookkey
               AND printingkey = @delete_title_printingkey;
         END
      END
	
	/* delete from titlehistory  */
	DELETE FROM titlehistory WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from titlehistory for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* delete from printing  */
	DELETE FROM printing WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey  
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from printing for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from booklock  */
	DELETE FROM booklock WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from booklock for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	
	/*delete all rows on bookelement and element related table*/
	 EXEC deletetitle_bookelement @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	 IF @error_code != 0  BEGIN
		SELECT @err_msg = 'Error executing deletetitle_bookelement proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	 END 	


    /* delete from bookcontact/bookcontactrole tables */ 
    EXEC deletetitle_bookcontact @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	IF @error_code != 0  BEGIN
	 SELECT @err_msg = 'Error executing deletetitle_bookcontact proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
	 PRINT @err_msg
	 --GOTO finished
	 SELECT @error_code = -1
	 SELECT @error_desc = @err_msg 
	 RETURN 
	END
	
	
	/* delete from catalog-related tables   */
	/* delete from bookcatalog */
	DELETE FROM bookcatalog WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookcatalog for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from catalogbookexp  */
	DELETE FROM catalogbookexp WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from catalogbookexp for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from catalogexpformtext  */
	DELETE FROM catalogexpformtext WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey  
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from catalogexpformtext for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/* delete from catalogexpunformtext  */
	DELETE FROM catalogexpunformtext WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from catalogexpunformtext for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
		
	/* delete from production spec tables  */
	DELETE FROM bindingspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bindingspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END

	DELETE FROM bindcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bindcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END   
	
	DELETE FROM bookillus WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bookillus for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM coverspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from coverspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM jacketspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from jacketspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 


   DELETE FROM jackcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey  
   IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from jackcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 

	DELETE FROM jacketfoilcolors WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from jacketfoilcolors for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM textspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from textspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM textcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from textcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM illus WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from illus for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	/*delete all rows on materialspecs and materialkey-related table*/
	CREATE TABLE #matpo(pokey INT,rawmaterialkey INT)
	
	EXEC deletetitle_materialspecs @delete_title_bookkey,@delete_title_printingkey,
			@illus_chgcode1,@illus_chgcode2,@text_chgcode1,@text_chgcode2,@mms_option,@error_code OUTPUT,@err_msg OUTPUT

	IF @error_code != 0 BEGIN
		SELECT @err_msg = 'Error executing deletetitle_materialspecs proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		DROP TABLE #matpo
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	 END 	

	/* DROP TABLE #matpo	 */
	
	DELETE FROM note WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from note for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM casespecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from casespecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 
	
	DELETE FROM assemblyspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from assemblyspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM audiocassettespecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from audiocassettespecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM audiotapes WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from audiotapes for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM bundlespecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from bundlespecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM cameraspec WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from cameraspec for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM cardspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from cardspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM cdromspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from cdromspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM cdromcds WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from cdromcds for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 
	
	DELETE FROM diskettespecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from diskettespecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	
	DELETE FROM documentationspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from documentationspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM electpackagingspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from electpackagingspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	
	DELETE FROM errataspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from errataspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM kitspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from kitspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
		
	DELETE FROM labelspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from labelspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM laserdiscspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from laserdiscspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM mediainsertspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from mediainsertspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM packageoptions WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from packageoptions for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 
	
	DELETE FROM posterspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from posterspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM printpackagingspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from printpackagingspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM transparencyspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from trnsparencyspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM videocassettespecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from videocassettespecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END  
	
	DELETE FROM secondcoverspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from secondcoverspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM coverinsertspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from coverinsertspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM covinsertcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from coverinsertcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END

	DELETE FROM covercolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from covercolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END  
	
	DELETE FROM secondcovcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from secondcovcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	
	DELETE FROM misccompspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from misccompspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM endpapers WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from endpapers for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM endpcolor WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from endpcolor for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	
	/*delete all rows on estbook and estkey-related table*/
	EXEC deletetitle_estbook @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT 
	IF @error_code != 0 BEGIN
		SELECT @err_msg = 'Error executing deletetitle_estbook proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	 END 	
	
	
	/*delete all rows on gpo and gpokey-related table*/
	EXEC deletetitle_gposection @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	IF @error_code != 0 BEGIN
		SELECT @err_msg = 'Error executing deletetitle_gposection proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	 END 	

	EXEC deletetitle_gposubsection @delete_title_bookkey,@delete_title_printingkey,@error_code OUTPUT,@err_msg OUTPUT
	IF @error_code != 0 BEGIN
		SELECT @err_msg = 'Error executing deletetitle_gposubsection proc for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	 END 	

	/* delete from cover combo tables */

	DELETE FROM combobatchtitles WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from combobatchtitles for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 
	

	DELETE FROM combotitle 	WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from combotitle for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* delete from commonforms tables */

	DELETE FROM combobatchtitles WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from combobatchtitles for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM commonformsgrouptitles WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from commonformsgrouptitles for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 
	
	/* delete from commonformstitles  */
	DELETE FROM commonformstitles WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from commonformstitles for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 


	/* delete from compspec  */
	DELETE FROM compspec WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from compspec for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 


	/* delete from component  */
	DELETE FROM component WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from component for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	DELETE FROM sidestamp WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from sidestamp for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 


	DELETE FROM spinestamp WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from spinestamp for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* Delete from booksets */
	DELETE FROM booksets WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from booksets for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* Delete from nonbookspecs */
	DELETE FROM nonbookspecs WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from nonbookspecs for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* Delete from coretitleinfo */
	DELETE FROM coretitleinfo WHERE bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from coretitleinfo for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* delete from Title Lists  */
	DELETE FROM qse_searchresults
	 WHERE key1 = @delete_title_bookkey
	   AND key2 = @delete_title_printingkey 
	   AND listkey in(select listkey from qse_searchlist where searchitemcode = 1)

	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error deleting from qse_searchresults for bookkey' + convert(char(10),@delete_title_bookkey) 
        + ' and for printingkey ' + convert(char(10),@delete_title_printingkey)
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	END 


	/* set null to propagatefrombookkey to all titles that are propagated*/         
	update book set propagatefrombookkey = null where propagatefrombookkey = @delete_title_bookkey  
	IF @@error != 0 BEGIN
		SELECT @err_msg = 'Error removing propagatefrombookkey for bookkey ' + convert(char(10),@delete_title_bookkey) 
		PRINT @err_msg
		--GOTO finished
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN 
	END 

	/* Delete any row of printingkey= 0 that might have been created during the delete process - CRM# 5139 */
    SELECT @v_count = 0

	SELECT @v_count = count(*)
	FROM coretitleinfo
	WHERE bookkey = @delete_title_bookkey
     AND printingkey = 0;

    IF @v_count > 0 BEGIN
		/* Delete coretitleinfo row with 0 printingkey */
		DELETE FROM coretitleinfo WHERE bookkey = @delete_title_bookkey AND printingkey = 0 ;
		IF @@error != 0 BEGIN
			SELECT @err_msg = 'Error deleting from coretitleinfo for bookkey' + convert(char(10),@delete_title_bookkey) 
			  + ' and for printingkey 0' 
			PRINT @err_msg
			--GOTO finished
			SELECT @error_code = -1
			SELECT @error_desc = @err_msg 
			RETURN 
		END 
    END

finished:
/* ROLLBACK TRANSACTION */
return
	
	/*COMMIT*/
	/* commit is done in the w_ua_delete_title_printing ue_delete event after all deletes are done  */
END