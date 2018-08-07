SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_fb_locked_subgentable_value' ) 
drop procedure qutl_insert_fb_locked_subgentable_value
go

CREATE PROCEDURE [dbo].[qutl_insert_fb_locked_subgentable_value]
 (@i_tableid              integer,
  @i_datacode             integer,
  @i_datasubcode          integer,
  @i_datadesc             varchar (120),
  @i_datadescshort        varchar (40),
  @i_sortorder   		  integer,
  @i_subgen_gentext1       varchar(255),
  @i_subgen_gentext2       varchar(255),
  @i_subgen_gentext3       varchar(255),
  @o_datasubcode          integer output,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_fb_locked_subgentable_value
**  Desc: This procedure inserts for Firebrand Controlled gentables only
**        This stored procedure searches to see if the subgentable value sent matches 
**        an existing value on either datacode and datasubcode or datadesc.  
**        If a match is found, it is updated and the existing datasubcode is returned. 
**        If it is not found it is inserted and the new datasubcode is returned    
**    Auth: Kusum
**    Date: 28 Jan 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  DECLARE 
  
   @error_var  INT,
    @v_max_code INT,
    @v_count  INT,
    @v_error  INT,
    @v_lockind INT,
    @v_tablemnemonic VARCHAR(10)
     
  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
   SET @o_datasubcode = 0
	
	SELECT @v_lockind = lockind FROM gentablesdesc WHERE tableid = @i_tableid 
	
	IF @v_lockind = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Cannot update table: tableid = ' + cast(@i_tableid AS VARCHAR)+ '. This is not a FireBrand Controlled Table.' 
		RETURN 
	END
	
	SELECT @v_tablemnemonic = tablemnemonic FROM gentablesdesc WHERE tableid = @i_tableid

	SELECT @v_count = COUNT(*) FROM gentables WHERE (tableid = @i_tableid AND datacode = @i_datacode)
	
    IF @v_count = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Cannot insert to subgentables.  Invalid datacode: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR)+ ', desc= ' + @i_datadesc
      RETURN
    END
    
    IF  @o_datasubcode = 0 OR @o_datasubcode is NULL
   	  SELECT TOP 1 @o_datasubcode = datasubcode FROM subgentables
       WHERE (tableid = @i_tableid AND datacode = @i_datacode AND LOWER(datadesc) = @i_datadesc) 
       
	IF @o_datasubcode = 0 OR @o_datasubcode is NULL  BEGIN        
		--Value does not exist already on subgentables and must be inserted 
		SELECT @v_max_code = MAX(datasubcode)
		  FROM subgentables
		  WHERE tableid = @i_tableid AND datacode = @i_datacode
	  
		IF @v_max_code IS NULL
		   SET @v_max_code = 0
		
		SET @o_datasubcode = @v_max_code +1
	    
		INSERT INTO subgentables
		  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
		VALUES
		  (@i_tableid, @i_datacode, @o_datasubcode, @i_datadesc, 'N', @i_sortorder, @v_tablemnemonic, @i_datadescshort, 'QSIDBA', getdate(), 1, 0)
	  
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Insert to subgentables had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
		END 
	  END
	  ELSE BEGIN
	  --Subgentable value exists already based on datadesc or qsicode, update current value
	  
	  	--Only want to update the sortorder if it is a valid sortorder; always update datadesc and lockbyqsi    
		If @i_sortorder IS NULL BEGIN
		  UPDATE subgentables
			SET datadesc = @i_datadesc
			WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @o_datasubcode) 
			END
		ELSE  BEGIN 
		  UPDATE subgentables
		  SET datadesc = @i_datadesc, sortorder = @i_sortorder, datadescshort = @i_datadescshort
		  WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @o_datasubcode) 
		  END
	    
		SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Update to subgentables had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR) + ', desc= ' + @i_datadesc
		END 
	 END 
	 
	 IF @i_subgen_gentext1 IS NOT NULL AND @i_subgen_gentext1 <> '' BEGIN
		UPDATE subgentables_ext  
		   SET gentext1 = @i_subgen_gentext1
		 WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @o_datasubcode)   
	 END
	 
	 IF @i_subgen_gentext2 IS NOT NULL AND @i_subgen_gentext2 <> '' BEGIN
		UPDATE subgentables_ext  
		   SET gentext2 = @i_subgen_gentext2
		 WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @o_datasubcode)   
	 END
	 
	 IF @i_subgen_gentext3 IS NOT NULL AND @i_subgen_gentext3 <> '' BEGIN
		UPDATE subgentables_ext  
		   SET gentext3 = @i_subgen_gentext3
		 WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @o_datasubcode)   
	 END
	 
  END
  GO   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
