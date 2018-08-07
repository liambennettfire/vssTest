SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_clientdefaults_value') 
drop procedure qutl_insert_clientdefaults_value
go

CREATE PROCEDURE [dbo].[qutl_insert_clientdefaults_value]
 (@i_cliendefaultid       integer,
  @i_clientdefaultname    varchar (40),
  @i_defaultvaluecomment  varchar(400),
  @i_clientdefaultvalue   float,
  @i_clientdefaultsubvalue int,
  @i_stringvalue          varchar(255),
  @i_tableid			  int,
  @i_valuetypecode 	      int,
  @i_defaultdescripiton	  varchar(2000),
  @i_systemfunctioncode   integer,
  @i_activeind			  tinyint,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_clientdefaults_value
**  Desc: This stored procedure searches to see if the clientdefaults value sent 
**        matches to an existing value based on ID
**     .  If a match is found based on optionid,it is updated.
**        If information sent is NULL for a particular column, the column
**        WILL NOT be updated.
**        If optionid is not found it is inserted. 
**
**         
**  
**    Auth: Kusum
**    Date: 1 Feb 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------        -------------------------------------------
**    04/21/16    Kusum			 Changes made     
*******************************************************************************/

DECLARE 
    @v_error  INT,
    @v_windowid INT,
    @v_count INT,
    @v_activeind INT,
    @v_existing_clientdefaultname VARCHAR(40),
    @v_existing_defaultvaluecomment VARCHAR(400),
    @v_existing_defaultdescripiton VARCHAR(2000),
    @v_existing_clientdefaultvalue	float,
    @v_existing_clientdefaultsubvalue INT,
    @v_existing_tableid INT,
    @v_existing_valuetypecode INT,
    @v_existing_systemfunctioncode INT
    
    
  SET @v_count = 0    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
    
BEGIN
	IF @i_cliendefaultid IS NULL OR @i_cliendefaultid = 0 BEGIN
	 SET @o_error_code = -1
	 SET @o_error_desc = 'Unable to insert/update clientoptions' + cast(@i_cliendefaultid AS VARCHAR)+ ' IS NULL OR 0.'
	 RETURN
	END
	
	SELECT @v_count = COUNT(*) FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid

	IF @v_count = 0 BEGIN
		IF @i_valuetypecode IS NULL OR @i_valuetypecode = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert to clientdefaults table for: clientdefaultid = ' + cast(@i_cliendefaultid AS VARCHAR) + ' Valuetypecode
			 is required.'
			RETURN
		END
		
	    IF @i_activeind IS NULL 
			SET @v_activeind = 1
	    ELSE
	        SET @v_activeind = @i_activeind
	        
	        
		INSERT INTO clientdefaults (clientdefaultid,clientdefaultname,defaultvaluecomment,tableid,clientdefaultvalue, clientdefaultsubvalue,
		       valuetypecode, activeind,systemfunctioncode,stringvalue,lastuserid,lastmaintdate)
			VALUES(@i_cliendefaultid,@i_clientdefaultname, @i_defaultvaluecomment,@i_tableid,@i_clientdefaultvalue, @i_clientdefaultsubvalue,
			   @i_valuetypecode,  @v_activeind,@i_systemfunctioncode,@i_stringvalue,'QSIDBA',GETDATE())
	
		 SELECT @v_error = @@ERROR
	     IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'insert to clientdefaults table had an error: clientdefaultid = ' + cast(@i_cliendefaultid AS VARCHAR)
		 END
	END --@v_count = 0
	
	IF @v_count = 1 BEGIN
		IF @i_clientdefaultname IS NOT NULL AND @i_clientdefaultname <> '' BEGIN
		    SELECT @v_existing_clientdefaultname = COALESCE(clientdefaultname,'') FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		    IF @i_clientdefaultname <> @v_existing_clientdefaultname
				UPDATE clientdefaults 
				   SET clientdefaultname = @i_clientdefaultname,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
			 
		END
		
		IF @i_defaultvaluecomment IS NOT NULL AND @i_defaultvaluecomment <> '' BEGIN
		    SELECT @v_existing_defaultvaluecomment = COALESCE(defaultvaluecomment,'') FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		    IF @i_defaultvaluecomment <> @v_existing_defaultvaluecomment
				UPDATE clientdefaults 
				   SET defaultvaluecomment = @i_defaultvaluecomment,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
			 
		END
		
		IF @i_defaultdescripiton IS NOT NULL AND @i_defaultdescripiton <> '' BEGIN
		    SELECT @v_existing_defaultdescripiton = COALESCE(defaultdescription,'') FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		    IF @i_defaultdescripiton <> @v_existing_defaultdescripiton
				UPDATE clientdefaults 
				   SET defaultdescription = @i_defaultdescripiton,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
			 
		END
		
		IF @i_valuetypecode IS NOT NULL AND @i_valuetypecode > 0 BEGIN
			SELECT @v_existing_valuetypecode = COALESCE(valuetypecode,0) FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		    IF @i_valuetypecode <> @v_existing_valuetypecode
				UPDATE clientdefaults 
				   SET valuetypecode = @i_valuetypecode,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
		END
		
		--@i_tableid
		IF @i_tableid IS NOT NULL AND @i_tableid > 0 BEGIN
		    SELECT @v_existing_tableid = COALESCE(tableid,0) FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		    IF @i_tableid <> @v_existing_tableid
				UPDATE clientdefaults 
				   SET tableid = @i_tableid,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
			 
		END
		
		IF @i_activeind IS NULL 
			SET @v_activeind = 0
	    ELSE
	        SET @v_activeind = @i_activeind 
	        
	    UPDATE clientdefaults 
		   SET activeind = @v_activeind,
			   lastuserid = 'QSIDBA',
			   lastmaintdate = GETDATE()
		 WHERE clientdefaultid = @i_cliendefaultid
		 
		 
		 IF @i_systemfunctioncode IS NOT NULL AND @i_systemfunctioncode > 0  BEGIN
			SELECT @v_existing_systemfunctioncode = COALESCE(systemfunctioncode,0) FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
			
			IF @i_systemfunctioncode <> @v_existing_systemfunctioncode
				UPDATE clientdefaults 
				   SET systemfunctioncode = @i_systemfunctioncode,
					   lastuserid = 'QSIDBA',
					   lastmaintdate = GETDATE()
				 WHERE clientdefaultid = @i_cliendefaultid
		END
		
		
	        
	    --slb: In addition to what is noted in that section 9 (please refer to case 36041), we should do is prevent the update of the value columns through the 
	    --procedures on an update but allow it on an insert. If we need to update them, then we can do that in a separate sql call. 
	    --This will prevent us from overwriting a client determined value by mistake. If we add a sql call specifically to do so, 
	    --then it is more likely intentional. But on the insert, we can set the value to the default intially
	     
	  	            
	    --  IF @i_clientdefaultvalue IS NOT NULL AND @i_clientdefaultvalue > 0 BEGIN
		--    SELECT @v_existing_clientdefaultvalue = clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		--    IF @i_defaultdescripiton <> @v_existing_defaultdescripiton
		--		UPDATE clientdefaults 
		--		   SET clientdefaultvalue = @i_clientdefaultvalue,
		--			   lastuserid = 'QSIDBA',
		--			   lastmaintdate = GETDATE()
		--		 WHERE clientdefaultid = @i_cliendefaultid
			 
		--END
		
		----@i_clientdefaultsubvalue
		--IF @i_clientdefaultsubvalue IS NOT NULL AND @i_clientdefaultsubvalue > 0 BEGIN
		--    SELECT @v_existing_clientdefaultsubvalue = clientdefaultsubvalue FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		--    IF @i_clientdefaultsubvalue <> @v_existing_defaultdescripiton
		--		UPDATE clientdefaults 
		--		   SET clientdefaultsubvalue = @i_clientdefaultsubvalue,
		--			   lastuserid = 'QSIDBA',
		--			   lastmaintdate = GETDATE()
		--		 WHERE clientdefaultid = @i_cliendefaultid
			 
		--END
		
				
		----@i_valuetypecode
		--IF @i_valuetypecode IS NOT NULL AND @i_valuetypecode > 0 BEGIN
		--    SELECT @v_existing_valuetypecode = valuetypecode FROM clientdefaults WHERE clientdefaultid = @i_cliendefaultid
		    
		--    IF @i_valuetypecode <> @v_existing_valuetypecode
		--		UPDATE clientdefaults 
		--		   SET valuetypecode = @i_valuetypecode,
		--			   lastuserid = 'QSIDBA',
		--			   lastmaintdate = GETDATE()
		--		 WHERE clientdefaultid = @i_cliendefaultid
			 
		--END
	END  --@v_count = 1
END 
GO