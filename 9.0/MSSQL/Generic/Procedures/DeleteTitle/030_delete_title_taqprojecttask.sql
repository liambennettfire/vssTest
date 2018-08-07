-- Drop this procedure if it already exists
PRINT 'delete_title_taqprojecttask'
GO
IF object_id('delete_title_taqprojecttask ') IS NOT NULL
BEGIN
    DROP PROCEDURE delete_title_taqprojecttask
END 
GO

/*********************************************************************************************/ 
/*This procedure deletes or updates taqprojecttask based on bookkey/printingkey              */
/*as well as several other taq related tables                                                */
/* Kusum Basra 11/12/08                                                                      */
/*********************************************************************************************/ 

CREATE PROCEDURE delete_title_taqprojecttask 
	@delete_title_bookkey INT,
	@delete_title_printingkey INT,
    @error_code INT OUTPUT,
    @error_desc VARCHAR(2000) OUTPUT
AS

DECLARE	
	@v_taqprojectkey	INT,
    @v_taqelementkey  INT,
    @v_titlerolecode  INT,
    @v_count INT,
    @v_count2 INT,
    @v_count3 INT,
 	@v_titleacq_datacode INT,
    @v_taqtaskkey INT,
	@err_msg  varchar(255)

SELECT @v_taqprojectkey = 0
SELECT @v_taqelementkey = 0
SELECT @v_titlerolecode = 0
SELECT @v_count = 0
SELECT @v_count2 = 0
SELECT @v_count3 = 0
SELECT @error_code = 0
SELECT @error_desc = ''

/*each taqproject row*/
DECLARE  delete_taqprojecttask CURSOR FOR 
  SELECT distinct a.taqprojectkey, a.taqelementkey, a.taqtaskkey
		FROM taqprojecttask a
	 WHERE a.bookkey=@delete_title_bookkey
		AND  a.printingkey = @delete_title_printingkey
					
	
OPEN delete_taqprojecttask

FETCH delete_taqprojecttask INTO @v_taqprojectkey, @v_taqelementkey, @v_taqtaskkey

if @@fetch_status = -1 begin
	/*select @err_msg = 'ERROR: No rows selected into delete taqproject cursor. Cannot continue.'
	print @err_msg*/
	CLOSE delete_taqprojecttask 
	DEALLOCATE delete_taqprojecttask 
	return 
end

WHILE @@FETCH_STATUS = 0 BEGIN

	IF @v_taqprojectkey IS NULL BEGIN
     SET @v_taqprojectkey = 0
	END

	IF @v_taqelementkey IS NULL BEGIN
     SET @v_taqelementkey = 0
    END
--print '@delete_title_bookkey'
--print @delete_title_bookkey
--print '@delete_title_printingkey'
--print @delete_title_printingkey
--print '@v_taqprojectkey'
--print @v_taqprojectkey
--print '@v_taqelementkey'
--print @v_taqelementkey

	IF @v_taqprojectkey > 0 BEGIN
      UPDATE taqprojecttask
         SET bookkey = NULL,
             printingkey = NULL
       WHERE taqprojectkey = @v_taqprojectkey
         AND bookkey = @delete_title_bookkey
         AND printingkey = @delete_title_printingkey
--print 'update of taqproject for taqprojectkey' + convert(char(10),@v_taqprojectkey) 

    IF @v_taqelementkey > 0 BEGIN
        DELETE FROM taqprojectelementpartner
          WHERE bookkey = @delete_title_bookkey
            AND assetkey = @v_taqelementkey

        if @@error != 0 begin
			select @err_msg = 'Error deleting from taqprojectelementpartner for taqelementkey' + convert(char(10),@v_taqelementkey) 
			print @err_msg
			goto finished
		end

		UPDATE taqprojectelement
		   SET bookkey = NULL,
			   printingkey = NULL
		 WHERE taqelementkey = @v_taqelementkey
           AND taqprojectkey = @v_taqprojectkey
--print 'update of taqprojectelement for taqelementkey' + convert(char(10),@v_taqelementkey) 
    END
 END
 ELSE BEGIN  /* taqprojectkey = 0 */
   
---print 'deleteing from various tables taqprojectkey' + convert(char(10),@v_taqprojectkey)
---print 'deleteing from various tables taqelementkey' + convert(char(10),@v_taqelementkey)  
	IF @v_taqelementkey > 0 BEGIn
		DELETE FROM taqelementmisc
		    WHERE taqelementkey = @v_taqelementkey 
  	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from taqelementmisc for taqelementkey' + convert(char(10),@v_taqelementkey) 
			print @err_msg
			goto finished
		end
  	
		DELETE FROM taqproductnumbers WHERE elementkey = @v_taqelementkey AND (taqprojectkey = 0 OR taqprojectkey IS NULL) 
  	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from taqproductnumbers for taqelementkey' + convert(char(10),@v_taqelementkey) 
			print @err_msg
			goto finished
	    end
  	
		DELETE FROM filelocation WHERE taqelementkey = @v_taqelementkey AND (taqprojectkey = 0 OR taqprojectkey IS NULL)
            AND bookkey = @delete_title_bookkey AND printingkey = @delete_title_printingkey 
  	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from filelocation for taqelementkey' + convert(char(10),@v_taqelementkey) 
		    print @err_msg
		    goto finished
		end

		DELETE FROM qsicomments WHERE commentkey = @v_taqelementkey 
  	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from qsicomments for commentkey' + convert(char(10),@v_taqelementkey) 
		    print @err_msg
		    goto finished
		end

        DELETE FROM taqprojectelementpartner WHERE bookkey = @delete_title_bookkey AND assetkey = @v_taqelementkey

        if @@error != 0 begin
			select @err_msg = 'Error deleting from taqprojectelementpartner for taqelementkey' + convert(char(10),@v_taqelementkey) 
		    print @err_msg
			goto finished
		end
  	
		DELETE FROM taqprojectelement WHERE taqelementkey = @v_taqelementkey AND bookkey = @delete_title_bookkey
            AND printingkey = @delete_title_printingkey AND (taqprojectkey = 0 OR taqprojectkey IS NULL)
  	
		if @@error != 0 begin
			select @err_msg = 'Error deleting from taqprojectelement for taqelementkey' + convert(char(10),@v_taqelementkey) 
			print @err_msg
			goto finished
	    end

        DELETE FROM taqprojecttaskoverride WHERE taqelementkey = @v_taqelementkey 
            AND taqtaskkey in (SELECT taqtaskkey FROM taqprojecttask WHERE (taqprojectkey = 0 OR taqprojectkey IS NULL)
            AND bookkey = @delete_title_bookkey
            AND printingkey = @delete_title_printingkey
            AND taqelementkey = @v_taqelementkey )
       	
	    if @@error != 0 begin
			select @err_msg = 'Error deleting from taqprojecttaskoverride for taqelementkey' + convert(char(10),@v_taqelementkey) 
			print @err_msg
			goto finished
	    end
      END

	  DELETE FROM taqprojecttask WHERE (taqprojectkey = 0 OR taqprojectkey IS NULL)
          AND bookkey = @delete_title_bookkey
          AND printingkey = @delete_title_printingkey
	
	  if @@error != 0 begin
   		select @err_msg = 'Error deleting from taqprojecttask for taqprojectkey' + convert(char(10),@v_taqprojectkey) 
		print @err_msg
		goto finished
	  end
   END
  
   FETCH delete_taqprojecttask INTO @v_taqprojectkey, @v_taqelementkey, @v_taqtaskkey

END

CLOSE delete_taqprojecttask
DEALLOCATE delete_taqprojecttask
return

finished: 
CLOSE delete_taqprojecttask
DEALLOCATE delete_taqprojecttask
SELECT @error_code = -1
SELECT @error_desc = @err_msg 
return