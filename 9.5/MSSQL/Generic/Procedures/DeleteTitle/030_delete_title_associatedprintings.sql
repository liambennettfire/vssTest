-- Drop this procedure if it already exists
PRINT 'delete_title_associatedprintings'
GO
IF object_id('delete_title_associatedprintings ') IS NOT NULL
BEGIN
    DROP PROCEDURE delete_title_associatedprintings
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes associated printings based on bookkey                               */
/*as well as the PL tables                                                                   */
/* Kusum Basra 10/27/14                                                                      */
/*********************************************************************************************/ 

CREATE PROCEDURE delete_title_associatedprintings 
	@delete_title_bookkey  INT,
	@delete_title_printingkey INT,
	@error_code INT OUTPUT,
	@error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	@v_taqprojectkey	INT,
        @v_taqprojectformatkey INT,
        @v_printingkey  INT,
        @v_bookkey  INT,
        @v_projecttitle VARCHAR(255),
        @v_plstagecode INT,
        @v_taqversionkey INT,
		@err_msg  varchar(255),
		@o_error_code INT,
        @o_error_desc varchar(2000) ,
        @v_otherdefaultrelationshipcode INT,
        @v_count_pos INT
        
SELECT @error_code = 0
SELECT @error_desc = ''


/*each taqprojecttitle row for all associated printings*/
DECLARE taqprojecttitle_cur CURSOR FOR 
  SELECT r.taqprojectformatkey,r.taqprojectkey,r.bookkey,r.printingkey,c.projecttitle
    FROM taqprojecttitle r LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey = c.projectkey   
   WHERE r.bookkey = @delete_title_bookkey  AND r.printingkey = @delete_title_printingkey
     AND projectrolecode =  
      (SELECT datacode FROM gentables
       WHERE tableid = 604
       AND (datacode in 
		(SELECT DISTINCT code1 
		   FROM gentablesrelationshipdetail
          WHERE gentablesrelationshipkey = 10  --Project Role to Web Relationship Tab Mapping
            AND code2 = 
             (SELECT datacode from gentables WHERE tableid = 583 AND qsicode = 31))) ) --Printings (on Titles)
                          
	
OPEN taqprojecttitle_cur

FETCH taqprojecttitle_cur INTO @v_taqprojectformatkey,@v_taqprojectkey, @v_bookkey, @v_printingkey,@v_projecttitle

WHILE @@FETCH_STATUS = 0 BEGIN
	SELECT @v_otherdefaultrelationshipcode = datacode FROM gentables WHERE tableid = 582 and qsicode = 26 --Purchase Orders (for Printings)
	SELECT @v_count_pos= 0
	
	SELECT @v_count_pos = count(*)  
      FROM projectrelationshipview v, taqproject p  
     WHERE v.relatedprojectkey = p.taqprojectkey AND 
           v.taqprojectkey =  @v_taqprojectkey AND 
           v.relationshipcode =  @v_otherdefaultrelationshipcode
           
    IF @v_count_pos > 0 BEGIN
		select @err_msg = 'Unable to Delete Printing Project: ' + @v_projecttitle  + '. Purchase Orders exist for project.'
		print @err_msg
		CLOSE taqprojecttitle_cur
        DEALLOCATE taqprojecttitle_cur
		RETURN
	END
	
	IF @v_taqprojectkey > 0 BEGIN
     DECLARE taqversion_cur CURSOR FOR
		SELECT plstagecode,taqversionkey
		  FROM taqversion
		 WHERE taqprojectkey = @v_taqprojectkey
		 
		 
	 OPEN taqversion_cur
	 
	 FETCH taqversion_cur INTO @v_plstagecode,@v_taqversionkey
	 
	 WHILE @@fetch_status = 0 BEGIN
	 
		exec qpl_delete_version @v_taqprojectkey,@v_plstagecode,@v_taqversionkey,@o_error_code output,@o_error_desc output
  
		IF @o_error_code < 0 BEGIN
		  select @err_msg = 'Unable to delete version (in delete title process): ' + @o_error_desc 
		  print @err_msg
		  CLOSE taqversion_cur
	      DEALLOCATE taqversion_cur
	      CLOSE taqprojecttitle_cur
          DEALLOCATE taqprojecttitle_cur
          SELECT @error_code = -1
		  SELECT @error_desc = @err_msg 
		  RETURN
		END
			 
		FETCH taqversion_cur INTO @v_plstagecode,@v_taqversionkey
	 END
	 
	 CLOSE taqversion_cur
	 DEALLOCATE taqversion_cur
	 
	 exec qproject_delete_project_desktop @v_taqprojectkey, -1, @o_error_code output,@o_error_desc output
	 
	 IF @o_error_code < 0 BEGIN
	  select @err_msg = 'Unable to delete project (in delete title process): ' + @o_error_desc 
	  print @err_msg
	  CLOSE taqprojecttitle_cur
      DEALLOCATE taqprojecttitle_cur
      SELECT @error_code = -1
	  SELECT @error_desc = @err_msg 
	  RETURN
	 END
 
	 
	 FETCH taqprojecttitle_cur INTO @v_taqprojectformatkey,@v_taqprojectkey, @v_bookkey, @v_printingkey,@v_projecttitle
   END
END

CLOSE taqprojecttitle_cur
DEALLOCATE taqprojecttitle_cur
return

