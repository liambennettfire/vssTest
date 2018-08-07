SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_fb_locked_gentable_value' ) 
drop procedure qutl_insert_fb_locked_gentable_value
go

CREATE PROCEDURE [dbo].[qutl_insert_fb_locked_gentable_value]
 (@i_tableid              integer,
  @i_datacode             integer,
  @i_datadesc             varchar (100),
  @i_sortorder  		  integer,
  @o_datacode             integer output,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_fb_locked_gentable_value
**  Desc: This procedure inserts for Firebrand Controlled gentables only
**        This stored procedure searches to see if the gentable value sent matches 
**        an existing value on either datacode or datadesc.  If a match is found, 
**        it is updated.  If it is not found it is inserted.
**        Procedure will return value of @o_error_code. 
**    Auth: Kusum
**    Date: 28 Jan 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    6/23/16     Kusum          Case 38696     
*******************************************************************************/

	DECLARE 
		@v_max_code INT,
		@v_max_key  INT,
		@v_error  INT,
		@v_lockind INT,
		@v_prevdatadesc VARCHAR (40),
		@v_datacode INT,
		@v_tablemnemonic VARCHAR(40)


	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_max_code = 0
	SET @v_max_key = 0
	SET @v_lockind = 0
	SET @v_prevdatadesc = ' '
	SET @o_datacode = 0



BEGIN
	SET @o_datacode = 0  
	
	SELECT @v_lockind = lockind FROM gentablesdesc WHERE tableid = @i_tableid 
	
	IF @v_lockind = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'update to table: tableid = ' + cast(@i_tableid AS VARCHAR)+ '. This is not a FireBrand Controlled Table.' 
		RETURN 
	END
	
	SELECT @v_tablemnemonic = tablemnemonic FROM gentablesdesc WHERE tableid = @i_tableid 

	SET @v_datacode = 0

	IF @i_datacode IS NOT NULL
	  SELECT TOP 1 @v_datacode = datacode, @v_prevdatadesc = datadesc FROM gentables
			  WHERE (tableid = @i_tableid AND datacode = @i_datacode)	
			  
	IF  @o_datacode = 0 OR @o_datacode is NULL
   		  SELECT TOP 1 @v_datacode = datacode, @v_prevdatadesc = datadesc  FROM gentables
		   WHERE (tableid = @i_tableid AND LOWER(datadesc) = @i_datadesc) 
		   
		   
    IF @v_datacode = 0 OR @v_datacode is NULL  BEGIN  --Value does not exist already and must be inserted  
		SELECT @v_max_code = MAX(datacode)
		  FROM gentables
		  WHERE tableid = @i_tableid
	  
		IF @v_max_code IS NULL
		   SET @v_max_code = 0
		
		SET @o_datacode = @v_max_code +1
	    
		INSERT INTO gentables
		  (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic,lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind)
		VALUES
		  (@i_tableid, @o_datacode , @i_datadesc, 'N', @i_sortorder, @v_tablemnemonic, 'QSIDBA', getdate(), 1, 0)
	  
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'insert to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@o_datacode AS VARCHAR) 
		  + ', desc= ' + @i_datadesc
		END    
	  END  --Insert Gentables Value
	  ELSE BEGIN  -- Gentable Value exists already based on datadesc or datacode so no insert is necessary; update the existing values 
		--Only want to update the sortorder if it is a valid sortorder; always update datadesc and lockbyqsi
		  If @i_sortorder IS NULL BEGIN
			UPDATE gentables
			SET datadesc = @i_datadesc
			WHERE (tableid = @i_tableid AND datacode = @o_datacode ) 
		  END
		  ELSE  BEGIN
			UPDATE gentables
			SET datadesc = @i_datadesc, sortorder = @i_sortorder
			WHERE (tableid = @i_tableid AND datacode = @o_datacode )
		  END  	  

		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'update to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' 
		  + cast(@o_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
		END 
	  END  --Update Gentables Value 
END  --End Stored Procedure
GO