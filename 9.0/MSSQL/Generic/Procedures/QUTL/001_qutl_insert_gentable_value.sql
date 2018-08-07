
/****** Object:  StoredProcedure [dbo].[qutl_insert_gentable_value]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_gentable_value' ) 
drop procedure qutl_insert_gentable_value
go

CREATE PROCEDURE [dbo].[qutl_insert_gentable_value]
 (@i_tableid              integer,
  @i_tablemnemonic        varchar (40),
  @i_qsicode              integer,
  @i_datadesc             varchar (100),
  @i_sortorder  		  integer,
  @i_lockbyqsiind		  integer,
  @o_datacode             integer output,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_gentable_value
**  Desc: This stored procedure searches to see if the gentable value sent matches 
**        an existing value on either qsicode or datadesc.  If a match is found, 
**        it is updated and the existing data code is returned.  If it is not found
**        it is inserted and the new datacode is returned    
**    Auth: SLB
**    Date: 9 Jan 2015
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  DECLARE 
    @v_max_code INT,
    @v_max_key  INT,
    @v_error  INT,
    @v_windowid INT,
    @v_windowtitle VARCHAR (80),
    @v_prevdatadesc VARCHAR (40),
    @v_securitygroupkey INT,
    @v_windowcategoryid INT,
    @v_datelabelshort VARCHAR(10),
    @v_datelabel	VARCHAR(30)
     
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_windowid = 0
  SET @v_prevdatadesc = ' '
  SET @v_max_code = 0
  SET @v_max_key = 0
  SET @v_securitygroupkey = 0
    
BEGIN

  SET @o_datacode = 0 
  
  IF @i_tableid = 323 BEGIN  --fake gentable
	 IF @i_qsicode IS NOT NULL
	  SELECT TOP 1 @o_datacode = datetypecode, @v_prevdatadesc = description FROM datetype
			  WHERE qsicode = @i_qsicode 	
			  
	 IF  @o_datacode = 0 OR @o_datacode is NULL
   	  SELECT TOP 1 @o_datacode = datetypecode, @v_prevdatadesc = description FROM datetype
		   WHERE (LOWER(description) = @i_datadesc) 
		   
	 IF @o_datacode = 0 OR @o_datacode is NULL  BEGIN  --Value does not exist already and must be inserted 
	  SELECT @v_max_code = COALESCE(MAX(datetypecode),0) FROM datetype 	
	  
	  SET @o_datacode = @v_max_code +1
	  
	  SET @v_datelabel = SUBSTRING(@i_datadesc,1,30)
	  
	  SET @v_datelabelshort = SUBSTRING(@i_datadesc,1,10)
	  
	  INSERT INTO datetype(datetypecode,description,printkeydependent,changetitlestatusind,datelabel,datelabelshort,
	    tableid,lastuserid,lastmaintdate,lockbyqsiind,lockbyeloquenceind,activeind,qsicode,showintaqind,milestoneind)
		VALUES(@o_datacode,@i_datadesc,0,0,@v_datelabel,@v_datelabelshort,
		  323,'QSIDBA', getdate(),@i_lockbyqsiind,0,1,@i_qsicode,1,1)
		
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'insert to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datetypecode=' + cast(@o_datacode AS VARCHAR) 
		  + ', desc= ' + @i_datadesc
	  END  
  
	 END  --insert into datetype
	 ELSE BEGIN -- Date Type Value exists already based on description or qsicode so no insert is necessary; update the existing values 
		  --Only want to update the qsicode if it does not already exist on the database and it is not null or zero
		If @i_qsicode IS NOT NULL AND @i_qsicode <> 0 BEGIN 
			UPDATE datetype
			SET qsicode= @i_qsicode
			WHERE (datetypecode = @o_datacode ) 
			
	    	SELECT @v_error = @@ERROR
			IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'qsicode update to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datetypecode=' 
			  + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
			  RETURN 
			END 
		  END  --Update with qsicode
	      
		--Only want to update the sortorder if it is a valid sortorder; always update datadesc and lockbyqsiind
		  SET @v_datelabel = SUBSTRING(@i_datadesc,1,30)
	  
		  SET @v_datelabelshort = SUBSTRING(@i_datadesc,1,10)
		  
		  If @i_sortorder IS NULL BEGIN
			UPDATE datetype
			SET description = @i_datadesc, datelabel = @v_datelabel, datelabelshort = @v_datelabelshort,lockbyqsiind = @i_lockbyqsiind
			WHERE (datetypecode = @o_datacode ) 
		  END
		  ELSE  BEGIN
			UPDATE datetype
			SET description = @i_datadesc, lockbyqsiind = @i_lockbyqsiind, sortorder = @i_sortorder
			WHERE (datetypecode = @o_datacode)
		  END  	  

		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'update to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datetypecode=' 
		  + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
		END 
	 
	 END  --update datetype
  END  --@tableid = 323
  ELSE BEGIN
	  IF @i_qsicode IS NOT NULL
		  SELECT TOP 1 @o_datacode = datacode, @v_prevdatadesc = datadesc FROM gentables
			  WHERE (tableid = @i_tableid AND qsicode = @i_qsicode)
			  
	  IF  @o_datacode = 0 OR @o_datacode is NULL
   		  SELECT TOP 1 @o_datacode = datacode, @v_prevdatadesc = datadesc  FROM gentables
		   WHERE (tableid = @i_tableid AND LOWER(datadesc) = @i_datadesc) 
	       
	  IF @o_datacode = 0 OR @o_datacode is NULL  BEGIN  --Value does not exist already and must be inserted  
		SELECT @v_max_code = MAX(datacode)
		  FROM gentables
		  WHERE tableid = @i_tableid
	  
		IF @v_max_code IS NULL
		   SET @v_max_code = 0
		
		SET @o_datacode = @v_max_code +1
	    
		INSERT INTO gentables
		  (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, qsicode,
		  lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
		VALUES
		  (@i_tableid, @o_datacode , @i_datadesc, 'N', @i_sortorder, @i_tablemnemonic,  @i_qsicode, 'QSIDBA', getdate(), @i_lockbyqsiind, 0)
	  
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'insert to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@o_datacode AS VARCHAR) 
		  + ', desc= ' + @i_datadesc
		END    
	  END  --Insert Gentables Value
	  ELSE BEGIN  -- Gentable Value exists already based on datadesc or qsicode so no insert is necessary; update the existing values 
		  --Only want to update the qsicode if it does not already exist on the database and it is not null or zero 
		  If @i_qsicode IS NOT NULL AND @i_qsicode <> 0 BEGIN 
			UPDATE gentables
			SET qsicode= @i_qsicode
			WHERE (tableid = @i_tableid AND datacode = @o_datacode ) 
	    			SELECT @v_error = @@ERROR
			IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'qsicode update to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
			  + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
			  RETURN 
			END 
		  END  --Update with qsicode
	      
		--Only want to update the sortorder if it is a valid sortorder; always update datadesc and lockbyqsi
		  If @i_sortorder IS NULL BEGIN
			UPDATE gentables
			SET datadesc = @i_datadesc, lockbyqsiind = @i_lockbyqsiind
			WHERE (tableid = @i_tableid AND datacode = @o_datacode ) 
		  END
		  ELSE  BEGIN
			UPDATE gentables
			SET datadesc = @i_datadesc, lockbyqsiind = @i_lockbyqsiind, sortorder = @i_sortorder
			WHERE (tableid = @i_tableid AND datacode = @o_datacode )
		  END  	  

		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'update to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
		  + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
		END 
	  END  --Update Gentables Value 
  END --@i_tableid <> 323
  
  IF @i_tableid = 583 OR @i_tableid = 440 BEGIN
    -- Web Relationship Tabs and Association Tabs need qsiwindows and security record for Projects Window Category
    -- windowname, windowtitle = @i_datadesc for the table; this will need to be updated when table is updated
	-- Check to see if qsiwindows exists already
    SET @v_windowcategoryid = 130
	SELECT @v_windowid = windowid FROM qsiwindows 
		  WHERE windowcategoryid = @v_windowcategoryid AND applicationind = 14 AND windowname = @v_prevdatadesc
		  
	IF @v_windowid = 0 OR @v_windowid IS NULL  BEGIN  --Insert qsiwindows and security windows rows 
	  
	  SELECT @v_windowid = max(windowid) from qsiwindows
      SET @v_windowid = @v_windowid + 1
	  INSERT INTO qsiwindows (windowid, windowcategoryid, windowname, windowtitle,  sortorder, applicationind, windowind, 
	        orglevelsecurityind, lastuserid, lastmaintdate, itemtypecode, allowviewsind, allowmiscsectionind)
	  VALUES  (@v_windowid, @v_windowcategoryid, @i_datadesc, @i_datadesc, NULL,14, 'Y',
			'N', 'QSIDBA', getdate(), NULL, 0, 0)
	  
	  SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'insert to qsiwindows had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
        + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
      END --Error processing        
	END  --Insert qsiwindows
	
	ELSE  BEGIN  --update qsiwindow
	
	  UPDATE qsiwindows SET windowname = @i_datadesc, windowtitle= @i_datadesc  
	  WHERE windowid = @v_windowid
      SELECT @v_error = @@ERROR
      
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1    
        SET @o_error_desc = 'insert to qsiwindows had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
        + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
      END --Error processing    
	END  --Update qsiwindows
	
  	/*** Make sure security rows exist.  No Action will be taken if they are there; otherwise, they will be inserted  ***/
	Exec qutl_insert_security_windows @v_windowid, @o_error_code OUTPUT, @o_error_desc OUTPUT
	IF @o_error_code <> 0 RETURN
	
  END  --Tableid 440 and 583 (Title and Web Relationship Tabs) 	
  
  IF @i_tableid = 440 BEGIN --Also add to Titles Category to Association Tabs
   	  -- Check to see if qsiwindows for Titles category exists already
    SET @v_windowcategoryid = 118
    SET @v_windowid = 0
    SELECT @v_windowid = windowid FROM qsiwindows 
 	    WHERE windowcategoryid = @v_windowcategoryid AND applicationind = 14 AND windowname = @v_prevdatadesc

	IF @v_windowid = 0 OR @v_windowid IS NULL  BEGIN  --Insert qsiwindows and security windows rows 
	  SELECT @v_windowid = max(windowid) from qsiwindows
      SET @v_windowid = @v_windowid + 1
      SET @v_windowtitle = 'Title Relationships - ' + @i_datadesc
	  INSERT INTO qsiwindows (windowid, windowcategoryid, windowname, windowtitle,  sortorder, applicationind, windowind, 
	        orglevelsecurityind, lastuserid, lastmaintdate, itemtypecode, allowviewsind, allowmiscsectionind)
	  VALUES  (@v_windowid, @v_windowcategoryid, @i_datadesc, @v_windowtitle, NULL,14, 'Y',
			'N', 'QSIDBA', getdate(), NULL, 0, 0)
	  SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'update to qsiwindows had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
        + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
      END --Error processing  

	END  --Insert qsiwindows for Title Category
	ELSE  BEGIN  --update qsiwindow  for Title Category
      SET @v_windowtitle = 'Title Relationships - ' + @i_datadesc
	  UPDATE qsiwindows SET windowname = @i_datadesc, windowtitle= @v_windowtitle  
	      WHERE windowid = @v_windowid
	  SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'update to qsiwindows had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
        + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
      END --Error processing 
	END  --Update qsiwindows for Title Category
	
   /*** Make sure security rows exist.  No Action will be taken if they are there; otherwise, they will be inserted  ***/
   Exec qutl_insert_security_windows @v_windowid, @o_error_code OUTPUT, @o_error_desc OUTPUT
   IF @o_error_code <> 0 RETURN
 END  --Tableid 440 (Title Category for Association Tabs) 
END  --End Stored Procedure
GO


