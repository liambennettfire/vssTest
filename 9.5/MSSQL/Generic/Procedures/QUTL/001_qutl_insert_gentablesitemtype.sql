
/****** Object:  StoredProcedure [dbo].[qutl_insert_gentablesitemtype]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_gentablesitemtype' ) 
drop procedure qutl_insert_gentablesitemtype
go

CREATE PROCEDURE [dbo].[qutl_insert_gentablesitemtype]
 (@i_tableid              integer,
  @i_datacode             integer,
  @i_datasubcode          integer,
  @i_datasub2code         integer,
  @i_itemtype             integer,
  @i_class				        integer,	       
  @o_error_code           integer output,
  @o_error_desc			      varchar(2000) output,
  @o_gentablesitemtypekey integer = 0 output)  -- optional output parameter - must be last	       

AS

/******************************************************************************
**  Name: qutl_insert_gentablesitemtype
**  Desc: This stored procedure searches to see if a the gentablesitemtype value sent  
**        matches an existing value based on tableid, datacodes (including sub codes),  
**        item and class.  If no existing value is found, it is inserted     
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
    @v_gentablesitemtypekey INT,
    @v_count  INT,
    @v_error  INT
     
  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
    SELECT @v_count = COUNT (*) FROM gentablesitemtype
		  WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @i_datasub2code 
		  AND itemtypecode = @i_itemtype AND itemtypesubcode = @i_class)
		  
  	IF @v_count = 0 BEGIN
	  	EXEC dbo.get_next_key 'QSIDBA', @v_gentablesitemtypekey OUT

		  INSERT INTO gentablesitemtype (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
           VALUES ( @v_gentablesitemtypekey, @i_tableid, @i_datacode, @i_datasubcode, @i_datasub2code,  @i_itemtype, @i_class, 'QSIDBA', getdate())
 
 		  -- Save the @@ERROR in local variable before it is cleared.
		  SELECT @v_error = @@ERROR
	      IF @v_error <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'insert to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)
		  END 
		  
		  SET @o_gentablesitemtypekey = @v_gentablesitemtypekey
	  END
    ELSE BEGIN
      SELECT @o_gentablesitemtypekey = gentablesitemtypekey FROM gentablesitemtype
		    WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @i_datasub2code 
		    AND itemtypecode = @i_itemtype AND itemtypesubcode = @i_class)
    END    
    
END

GO


