SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_clientoptions_value' ) 
drop procedure qutl_insert_clientoptions_value
go

CREATE PROCEDURE [dbo].[qutl_insert_clientoptions_value]
 (@i_optionid             integer,
  @i_optionname           varchar (40),
  @i_optionvaluecomment   varchar(400),
  @i_optionvalue          smallint,
  @i_optiondescription 	  varchar(2000),
  @i_activeind 		      integer,
  @i_systemfunctioncode   integer,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_clientoptions_value
**  Desc: This stored procedure searches to see if the clientoption value sent 
**        matches to an existing value based on ID
**     .  If a match is found based on optionid,it is updated.  
**        If information sent is NULL for a particular column, the column
**        WILL NOT be updated.
**        If optionid is not found it is inserted.
**
**         
**    
**    Auth: Kusum
**    Date: 27 Jan 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    04/21/16    Kusum			 Changes made 
**    08/08/16    Uday			 Case 39693
*******************************************************************************/

  DECLARE 
    @v_error  INT,
    @v_windowid INT,
    @v_count INT,
    @v_existing_optionname VARCHAR(40),
    @v_existing_optionvaluecomment VARCHAR(400),
    @v_existing_optiondescription VARCHAR(2000),
    @v_activeind INT,
    @v_existing_systemfunctioncode INT
    
  SET @v_count = 0    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
    
BEGIN

	IF @i_optionid IS NULL OR @i_optionid = 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to insert/update clientoptions' + cast(@i_optionid AS VARCHAR)+ ' IS NULL OR 0.'
	 RETURN
	END
	
	SELECT @v_count = COUNT(*) FROM clientoptions WHERE optionid = @i_optionid
	
	IF @v_count = 0 BEGIN
		IF @i_activeind IS NULL 
			SET @v_activeind = 1
	    ELSE
	        SET @v_activeind = @i_activeind
	        
	    IF @i_optiondescription = '' 
			SET @i_optiondescription = NULL
	        
		INSERT INTO clientoptions (optionid,optionname, optionvaluecomment, optionvalue, lastuserid, lastmaintdate, 
		    optiondescription, activeind, systemfunctioncode)
			VALUES(@i_optionid, @i_optionname, @i_optionvaluecomment, @i_optionvalue, 'QSIADBA',GETDATE(), 
				@i_optiondescription, @v_activeind,@i_systemfunctioncode)
	
		 SELECT @v_error = @@ERROR
	     IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'insert to clientoptions table had an error: optionid = ' + cast(@i_optionid AS VARCHAR)
		 END
	END --@v_count = 0
	
	IF @v_count = 1 BEGIN
		IF @i_optionname IS NOT NULL AND @i_optionname <> '' BEGIN
		    SELECT @v_existing_optionname = COALESCE(optionname, '') FROM clientoptions WHERE optionid = @i_optionid
		    
		    IF @i_optionname <> @v_existing_optionname
				UPDATE clientoptions 
				   SET optionname = @i_optionname,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE optionid = @i_optionid
			 
		END
			 
		IF @i_optionvaluecomment IS NOT NULL AND @i_optionvaluecomment <> ''  BEGIN
			SELECT @v_existing_optionvaluecomment = optionvaluecomment FROM clientoptions WHERE optionid = @i_optionid
			
			IF @i_optionvaluecomment <> @v_existing_optionvaluecomment
				UPDATE clientoptions 
				   SET optionvaluecomment = @i_optionvaluecomment,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE optionid = @i_optionid
		END
	
	    --slb: In addition to what is noted in that section 9 (please refer to case 36041), we should do is prevent the update of the value columns through the 
	    --procedures on an update but allow it on an insert. If we need to update them, then we can do that in a separate sql call. 
	    --This will prevent us from overwriting a client determined value by mistake. If we add a sql call specifically to do so, 
	    --then it is more likely intentional. But on the insert, we can set the value to the default intially
	    
		--IF @i_optionvalue IS NOT NULL BEGIN
		--	UPDATE clientoptions 
		--	   SET optionvalue = @i_optionvalue,
		--	       lastuserid = 'QSIDBA',
		--		   lastmaintdate = GETDATE()
		--	 WHERE optionid = @i_optionid
		--END 
		
		IF @i_optiondescription IS NOT NULL AND @i_optiondescription <> '' BEGIN
		    SELECT @v_existing_optiondescription = COALESCE(optiondescription,'') FROM clientoptions WHERE optionid = @i_optionid

			IF @v_existing_optiondescription <> @i_optiondescription
				UPDATE clientoptions 
				   SET optiondescription = @i_optiondescription,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE optionid = @i_optionid
		
		END
		
		IF @i_systemfunctioncode IS NOT NULL AND @i_systemfunctioncode > 0  BEGIN
			SELECT @v_existing_systemfunctioncode = COALESCE(systemfunctioncode,0) FROM clientoptions WHERE optionid = @i_optionid
			
			IF @i_systemfunctioncode <> @v_existing_systemfunctioncode
				UPDATE clientoptions 
				   SET systemfunctioncode = @i_systemfunctioncode,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE optionid = @i_optionid
		END
		
		IF @i_activeind IS NULL 
			SET @v_activeind = 0
	    ELSE
	        SET @v_activeind = @i_activeind 
	        
	    UPDATE clientoptions 
		   SET activeind = @v_activeind,
			   lastuserid = 'QSIDBA',
			   lastmaintdate = GETDATE()
		 WHERE optionid = @i_optionid
	END --@v_count = 1 
END  --End Stored Procedure
GO


