-- Drop this procedure if it already exists
PRINT 'delete_title_taqprojecttitle'
GO
IF object_id('delete_title_taqprojecttitle ') IS NOT NULL
BEGIN
    DROP PROCEDURE delete_title_taqprojecttitle
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes or updates taqprojecttitle based on bookkey/printingkey                                                                    */
/*as well as several other taq related tables                                                                                                                         */
/* Kusum Basra 08/23/2011                                                                                                                                                */
/*********************************************************************************************/ 

CREATE PROCEDURE delete_title_taqprojecttitle 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT,
    @delete_title_userid varchar(30),
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	
	@v_taqprojectkey	INT,
    @v_count INT,
    @v_count2 INT,
    @v_titleacq_datacode INT,
	@err_msg  varchar(255),
    @relationship_code	INT,
	@v_active_status	INT,
	@v_usageclasscode	INT,
    @v_searchitemcode	INT,  
    @v_work_can_be_deleted INT,
    @v_work_taqprojectkey	INT,
    @v_error_code           INT,
    @v_error_desc           VARCHAR(2000),
    @v_userkey	INT

SELECT @v_taqprojectkey = 0
SELECT @v_count = 0
SELECT @v_count2 = 0
SELECT @v_work_can_be_deleted = 1  --work project cannot be deleted
SELECT @error_code = 0
SELECT @error_desc = ''

-- check if work can be deleted - if it can then delete taqprojecttitle row as part of the Title Acquisition taqprojecttitle check to see if status of the Title Acquisition project can be set to Active.
-- this check already been put in deletetitle_delete_printing.......
SELECT @v_count = count(*) FROM taqproject WHERE workkey = @delete_title_bookkey
SELECT @v_count = 0

SELECT @v_count = count(*)
  FROM taqproject
 WHERE workkey = @delete_title_bookkey

IF @v_count = 1 BEGIN
	SELECT @v_work_taqprojectkey = taqprojectkey
	  FROM taqproject
	 WHERE workkey = @delete_title_bookkey
END 


--taqprojecttitles
SELECT @v_count2 = 0
/* select from SearchItem subgentable  - Datacode 3 = Projects qsicode = 1 (Title Acquisition)*/
SELECT @v_count2 = count(*)
  FROM subgentables
 WHERE tableid = 550 AND datacode = 3 AND  qsicode = 1

IF @v_count2 > 0 BEGIN
	SELECT @v_titleacq_datacode = datasubcode
	  FROM subgentables
     WHERE tableid = 550 AND datacode = 3 AND  qsicode = 1
END
---print '@v_titleacq_datacode'
---print @v_titleacq_datacode

DECLARE taqprojecttitle_cur INSENSITIVE CURSOR FOR 
	SELECT taqprojectkey
	  FROM taqprojecttitle  
     WHERE taqprojecttitle.bookkey = @delete_title_bookkey AND (printingkey = @delete_title_printingkey OR printingkey is null)
       
OPEN  taqprojecttitle_cur

FETCH NEXT FROM taqprojecttitle_cur INTO @v_taqprojectkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete taqprojecttitle cursor. Cannot continue.'
	print @err_msg*/
	CLOSE taqprojecttitle_cur 
	DEALLOCATE taqprojecttitle_cur 
	return 
end
--print '@delete_title_bookkey'
--print @delete_title_bookkey
--print '@delete_title_printingkey'
--print @delete_title_printingkey
--print '@v_taqprojectkey'
--print @v_taqprojectkey

	
WHILE (@@FETCH_STATUS = 0 ) BEGIN 
	SELECT @v_usageclasscode = usageclasscode, @v_searchitemcode = searchitemcode
      FROM taqproject
    WHERE taqprojectkey = @v_taqprojectkey
--print '@v_usageclasscode'
--print @v_usageclasscode
--print '@v_searchitemcode'
--print @v_searchitemcode
     IF @v_usageclasscode = @v_titleacq_datacode BEGIN
        -- remove the bookkey from the taqprojecttitle row
		UPDATE taqprojecttitle
  		   SET bookkey = NULL,printingkey = NULL, ean = NULL, ean13 = NULL, isbn = NULL, isbn10 = NULL, itemnumber = NULL, gtin = NULL, 
  		       gtin14 = NULL, lccn = NULL, dsmarc= NULL, upc = NULL, eanprefixcode = NULL, isbnprefixcode = NULL
		 WHERE taqprojectkey = @v_taqprojectkey
           AND bookkey = @delete_title_bookkey
           AND (printingkey = @delete_title_printingkey OR printingkey is null)

   
 		SELECT @v_count = 0
                   
		SELECT @v_count = count(*)
          FROM  taqprojecttitle
         WHERE taqprojectkey = @v_taqprojectkey
           AND (bookkey IS NOT NULL   AND bookkey <> @delete_title_bookkey)
         -- if no other taqprojecttitle records for this Title Acq have a bookkey AND no work project relationship exists for this acquisition (relationshipcode qsicode = 15) 
         --  change status of that Title Acq to Active (qsicode = 3)
         IF @v_count = 0 BEGIN
			SELECT @relationship_code = datacode FROM gentables WHERE tableid = 582 AND qsicode = 15
--print '@relationship_code'
--print @relationship_code
			SELECT @v_count2 = 0

			SELECT @v_count2 = count(*)  
			  FROM taqprojectrelationship 
			 WHERE (taqprojectkey1 = @v_taqprojectkey AND relationshipcode1 = @relationship_code)
                OR ( taqprojectkey2 = @v_taqprojectkey AND relationshipcode2 = @relationship_code)
  
--print '@v_count2'
--print @v_count2
			IF @v_count2 = 0 BEGIN
				SELECT @v_active_status = datacode FROM gentables WHERE tableid = 522 AND qsicode = 3
--print '@v_active_status'
--print @v_active_status
				UPDATE taqproject SET taqprojectstatuscode = @v_active_status WHERE taqprojectkey = @v_taqprojectkey
			 END    --@v_count2 = 0
		END            --@v_count = 0
   END  -- Title Acquisition Project
   ELSE BEGIN
	-- IF project is not a Title Acquisition delete taqprojecttitle
    IF @v_usageclasscode <> @v_titleacq_datacode BEGIN
		DELETE FROM taqprojecttitle WHERE taqprojectkey = @v_taqprojectkey AND bookkey = @delete_title_bookkey
			AND (printingkey = @delete_title_printingkey OR printingkey is null)
	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from taqprojecttitle for taqprojectkey: ' + convert(char(10),@v_taqprojectkey)  + ' for bookkey: '  + convert(char(10),@delete_title_bookkey)
			print @err_msg
			SELECT @error_code = -1
		    SELECT @error_desc = @err_msg
		end
	END
			
	END
	FETCH NEXT FROM taqprojecttitle_cur INTO @v_taqprojectkey
 END --taqprojecttitle_cur LOOP

 CLOSE taqprojecttitle_cur
 DEALLOCATE taqprojecttitle_cur

