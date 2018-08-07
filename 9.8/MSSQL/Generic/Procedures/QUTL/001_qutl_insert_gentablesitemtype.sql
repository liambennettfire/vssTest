
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
  @i_class				  integer,	       
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output,
  @o_gentablesitemtypekey integer = 0 output,  -- optional output parameter 	       
  @i_sortorder            integer = NULL,   -- optional input parameter
  @i_relateddatacode      integer = NULL)  -- optional input parameter	

AS

/******************************************************************************************************************************
**  Name: qutl_insert_gentablesitemtype
**  Desc: This stored procedure searches to see if a the gentablesitemtype value sent  
**        matches an existing value based on tableid, datacodes (including sub codes),  
**        item and class.  If no existing value is found, it is inserted     
**    Auth: SLB
**    Date: 9 Jan 2015
*******************************************************************************************************************************
**    Change History
********************************************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    11-9-16	Dustin			gentables 680 handling (run qutl_insert_section_config and qutl_update_qsiconfigdetailtabs)
**    11-10-16  Susan			gentables 583 handling, including sort order and related data code as optional input parameters
*********************************************************************************************************************************/

  DECLARE 
    @v_gentablesitemtypekey INT,
    @v_relatedtableid INT,
	@v_count  INT,
    @v_error  INT
     
  SET @v_count = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN

   --If Related Data Code is passed in, verify that the related data code exists on gentables for the related tableid
     IF @i_relateddatacode is not NULL BEGIN  
	 	 SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = @i_tableid
		 SELECT @v_count = COUNT (*) FROM gentables where tableid = @v_relatedtableid and datacode = @i_relateddatacode
		 IF @v_count <> 1 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'Related Data Code, ' + cast(@i_relateddatacode AS VARCHAR) + ', is not valid for related table ' + cast(@v_relatedtableid AS VARCHAR)
			 + ' for the value in table id =' + cast(@i_tableid AS VARCHAR)+ ' with datacode = ' +cast (@i_datacode AS VARCHAR) + '.  Item not inserted/updated in gentablesitemtype.'
			RETURN
		  END 
    END

    SELECT @v_count = COUNT (*) FROM gentablesitemtype
		  WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @i_datasub2code 
		  AND itemtypecode = @i_itemtype AND itemtypesubcode = @i_class)	
		  	  
  	IF @v_count = 0 BEGIN   --Insert gentablesitemtype row
	  	EXEC dbo.get_next_key 'QSIDBA', @v_gentablesitemtypekey OUT

		  INSERT INTO gentablesitemtype (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, relateddatacode)
           VALUES ( @v_gentablesitemtypekey, @i_tableid, @i_datacode, @i_datasubcode, @i_datasub2code,  @i_itemtype, @i_class, 'QSIDBA', getdate(), @i_sortorder, @i_relateddatacode)
 
 		  -- If there is an error, return
		  SELECT @v_error = @@ERROR
	      IF @v_error <> 0 BEGIN
		    SET @o_error_code = -1
		    SET @o_error_desc = 'insert to table had an error: tableid=' + cast(@i_tableid AS VARCHAR)
			RETURN
		  END 
		  
		  SET @o_gentablesitemtypekey = @v_gentablesitemtypekey

		  IF @i_tableid = 680 BEGIN -- run qutl_insert_section_config to set qsiconfigdetail rows for the tab group
			DECLARE @v_datadesc VARCHAR(100),
					@v_configobjectkey INT,
					@v_relationshiptabcode INT,
					@v_itemtypeqsicode INT,
					@v_classqsicode INT

			SELECT @v_datadesc = datadesc
			FROM gentables
			WHERE tableid = @i_tableid
			  AND datacode = @i_datacode

			SELECT @v_itemtypeqsicode = COALESCE(qsicode, @i_itemtype)
			FROM gentables
			WHERE tableid = 550
			  AND datacode = @i_itemtype

			SELECT @v_classqsicode = COALESCE(qsicode, @i_class, 0)
			FROM subgentables
			WHERE tableid = 550
			  AND datacode = @i_itemtype
			  AND datasubcode = @i_class

			If @i_sortorder is NULL
			   SET @i_sortorder = 0

			EXEC qutl_insert_section_config @v_datadesc, @v_itemtypeqsicode, @v_classqsicode, @i_sortorder, @v_configobjectkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

		 END
		 ELSE IF @i_tableid = 583 AND @i_relateddatacode IS NOT NULL AND @i_relateddatacode <>0
		 BEGIN
		  --Insert rows for tab detail for the web relation tab and the related tab group code
			EXEC qutl_insert_qsiconfigdetailtabs @i_relateddatacode, @i_itemtype,  @i_class, @i_datacode, @i_sortorder,  @o_error_code OUTPUT, @o_error_desc OUTPUT 
		 END
	  END
    ELSE BEGIN  --Update existing gentablesitemtype
      SELECT @v_gentablesitemtypekey = gentablesitemtypekey FROM gentablesitemtype
		    WHERE (tableid = @i_tableid AND datacode = @i_datacode AND datasubcode = @i_datasubcode AND datasub2code = @i_datasub2code 
		    AND itemtypecode = @i_itemtype AND itemtypesubcode = @i_class)
	  SET @o_gentablesitemtypekey = @v_gentablesitemtypekey
	  If @i_sortorder is not NULL BEGIN
	     UPDATE gentablesitemtype SET lastuserid ='QSIDBA', lastmaintdate = getdate(), sortorder = @i_sortorder
            WHERE gentablesitemtypekey = @v_gentablesitemtypekey
		 END
	  If @i_relateddatacode is not NULL BEGIN
		 UPDATE gentablesitemtype SET lastuserid ='QSIDBA', lastmaintdate = getdate(), relateddatacode = @i_relateddatacode
            WHERE gentablesitemtypekey = @v_gentablesitemtypekey
		 IF @i_tableid = 583 BEGIN
		    --First, remove all existing rows for this relationship tab from qsiconfigdetailtabs
		    DELETE from qsiconfigdetailtabs WHERE relationshiptabcode = @i_datacode
			         AND configdetailkey IN (SELECT configdetailkey FROM qsiconfigdetail WHERE usageclasscode = @i_class AND 
					                         configobjectkey IN (SELECT configobjectkey FROM qsiconfigobjects WHERE 
											 itemtypecode = @i_itemtype))
					  --Insert rows for tab detail for the web relation tab and the related tab group code
			EXEC qutl_insert_qsiconfigdetailtabs @i_relateddatacode, @i_itemtype,  @i_class, @i_datacode, @i_sortorder,  @o_error_code OUTPUT, @o_error_desc OUTPUT 
		 END
	  END
    END    
    
END

GO