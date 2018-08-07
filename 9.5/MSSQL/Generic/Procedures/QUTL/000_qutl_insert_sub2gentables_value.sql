SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*  Remove old differently named stored procedure if it exists */

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_sub2gentable_value' ) 
drop procedure qutl_insert_sub2gentable_value
go

/*  Remove current stored procedure if it exists */
IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_sub2gentables_value' ) 
drop procedure qutl_insert_sub2gentables_value
go


CREATE PROCEDURE [dbo].[qutl_insert_sub2gentables_value]
 (@i_tableid              integer,
  @i_datacode             integer,
  @i_tablemnemonic        varchar (40),
  @i_qsicode              integer,
  @i_datadesc             varchar (40),
  @i_sortorder   		  integer,
  @i_lockbyqsiind		  integer,
  @i_datasubcode          integer,
  @o_datasub2code         integer output,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/**************************************************************************************
**  Name: qutl_insert_sub2gentables_value
**  Desc: This stored procedure searches to see if the sub2gentable value sent matches 
**        an existing value on either qsicode or datadesc.  If a match is found, 
**        it is updated and the existing datasub2code is returned.  If it is not found
**        it is inserted and the new datasub2code is returned    
**    Auth: SLB
**    Date: 5 August 2015
***************************************************************************************
**    Change History
***************************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
**************************************************************************************/

  DECLARE 
    @error_var  INT,
    @v_max_code INT,
    @v_count  INT,
    @v_error  INT
     
  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
   SET @o_datasub2code = 0 
    
   SELECT @v_count = COUNT(*) FROM subgentables
		  WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode )
    IF @v_count = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Cannot insert to sub2gentables.  Invalid datacode: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR)+
       ', datasubcode=' + cast(@i_datacode AS VARCHAR)+ ', desc= ' + @i_datadesc
      RETURN
      END

  IF @i_qsicode IS NOT NULL
      SELECT TOP 1 @o_datasub2code = datasub2code FROM sub2gentables
		  WHERE (tableid = @i_tableid AND qsicode = @i_qsicode)
		  
  IF  @o_datasub2code = 0 OR @o_datasub2code is NULL
   	  SELECT TOP 1 @o_datasub2code = datasubcode FROM sub2gentables
       WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND LOWER(datadesc) = @i_datadesc) 
       
  IF @o_datasub2code = 0 OR @o_datasub2code is NULL  BEGIN        
    --Value does not exist already on sub2gentables and must be inserted 
    SELECT @v_max_code = MAX(datasub2code)
	  FROM sub2gentables
	  WHERE tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode
  
	IF @v_max_code IS NULL
	   SET @v_max_code = 0
	
	SET @o_datasub2code = @v_max_code +1
    
    INSERT INTO sub2gentables
      (tableid, datacode, datasubcode, datasub2code, datadesc, deletestatus, sortorder, tablemnemonic, qsicode,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (@i_tableid, @i_datacode,@i_datasubcode, @o_datasub2code, @i_datadesc, 'N', @i_sortorder, @i_tablemnemonic,  @i_qsicode, 'QSIDBA', getdate(), @i_lockbyqsiind, 0)
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'insert to sub2gentables had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR) 
      + ', datasubcode=' + cast(@i_datasubcode AS VARCHAR) + ', desc= ' + @i_datadesc
    END 
  END
  ELSE BEGIN
  --Sub2gentable value exists already based on datadesc or qsicode, update current value
  
  --Only update qsicode if it is valid 
    If @i_qsicode IS NOT NULL AND @i_qsicode <> 0 BEGIN
      UPDATE sub2gentables
	    SET datadesc = @i_datadesc, lockbyqsiind = @i_lockbyqsiind,qsicode= @i_qsicode
	    WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @o_datasub2code) 
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'update to sub2gentables had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR) 
		   + ', datasubcode=' + cast(@i_datasubcode AS VARCHAR)+ ', desc= ' + @i_datadesc
		  RETURN
	  END 
	END 
	
	--Only want to update the sortorder if it is a valid sortorder; always update datadesc and lockbyqsi    
	If @i_sortorder IS NULL OR @i_sortorder = 0 BEGIN
      UPDATE sub2gentables
	    SET datadesc = @i_datadesc, lockbyqsiind = @i_lockbyqsiind
	    WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @o_datasub2code) 
	    END
	ELSE  BEGIN 
	  UPDATE sub2gentables
	  SET datadesc = @i_datadesc, lockbyqsiind = @i_lockbyqsiind, sortorder = @i_sortorder
	  WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @o_datasub2code) 
	  END
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'update to sub2gentables had an error: tableid=' + cast(@i_tableid AS VARCHAR)+ ', datacode=' + cast(@i_datacode AS VARCHAR) 
		   + ', datasubcode=' + cast(@i_datasubcode AS VARCHAR)+ ', desc= ' + @i_datadesc
    END 
  
  END
  
END


GO

GRANT EXEC ON qutl_insert_sub2gentables_value TO PUBLIC
GO

