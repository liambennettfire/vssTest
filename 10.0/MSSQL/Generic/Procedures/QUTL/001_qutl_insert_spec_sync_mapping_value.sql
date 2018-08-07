SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*  Remove current stored procedure if it exists */
IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_spec_sync_mapping_value' ) 
drop procedure qutl_insert_spec_sync_mapping_value
go


CREATE PROCEDURE [dbo].[qutl_insert_spec_sync_mapping_value]
 (@i_mappingkey			integer,
  @i_tablevaluedatatype varchar (255),
  @i_tablevalue			varchar (255),
  @i_spec_tableid		integer,
  @i_specitemdatadesc	varchar (40),
  @i_specvaluedatadesc	varchar (40),
  @i_specvaluedatatype	varchar (255),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/**************************************************************************************
**  Name: qutl_insert_spec_sync_mapping_value
**  Desc: This stored procedure searches to see if the spec sync mapping value exists  
**        based on mappingkey and spec item value.  Spec Item Value is determined by the 
**        using the spec table id if it is not null and subgentables for tableid 616
**        if there is no tableid.   If a match is found, it is updated; if it is not, 
**        it is inserted    
**    Auth: SLB
**    Date: 20 August 2015
***************************************************************************************
**    Change History
***************************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
**************************************************************************************/

  DECLARE 
    @error_var			 integer,
    @v_specvaluedatacode integer,
    @v_count			 integer,
    @v_spec_tableid		 varchar (40),
    @v_error			 integer
     
  SET @v_count = 0
  SET @v_specvaluedatacode = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
  
   IF @i_specvaluedatadesc = 'NULL' --There are some old table items that cannot map but must be there
		SET @v_specvaluedatacode = NULL
   ELSE IF @i_spec_tableid is  not NULL and @i_spec_tableid <> 0
		SET @v_specvaluedatacode = dbo.qutl_get_gentables_datacode (@i_spec_tableid, NULL, @i_specvaluedatadesc)
	ELSE 
		SELECT @v_specvaluedatacode = datasub2code from sub2gentables s2
			inner join
			subgentables s ON s.tableid = s2.tableid AND s.datadesc = @i_specitemdatadesc
			where s2.tableid = 616 and s2.datadesc = @i_specvaluedatadesc
					
	If (@v_specvaluedatacode is NULL AND @i_specvaluedatadesc <> 'NULL') OR (@v_specvaluedatacode = 0 AND @i_spec_tableid <> 584) BEGIN
	   SET @o_error_code = -1
	   SET @v_spec_tableid = COALESCE (@i_spec_tableid, ' ')
       SET @o_error_desc = 'Cannot find datacode for tableid=' + @v_spec_tableid + ', spec desc=' + @i_specvaluedatadesc +
       ', value desc= ' + @i_specvaluedatadesc
       RETURN
		END
    
   SELECT @v_count = COUNT(*) FROM qsiconfigspecsyncmapping
		  WHERE (mappingkey = @i_mappingkey AND specitemvalue = @v_specvaluedatacode)
		  
    IF @v_count = 0 BEGIN
    --Insert Spec Sync Mapping Value
      	    INSERT INTO qsiconfigspecsyncmapping
			(mappingkey, tablevaluedatatype, tablevalue, specitemvaluedatatype, specitemvalue, activeind, lastuserid, lastmaintdate)
		 VALUES
			(@i_mappingkey,@i_tablevaluedatatype, @i_tablevalue, @i_specvaluedatatype, @v_specvaluedatacode, 1, 'QSIDBA', getdate())
	    SELECT @v_error = @@ERROR
		IF @v_error <> 0 BEGIN
			 SET @o_error_code = -1
			 SET @o_error_desc = 'Error inserting qsiconfigspecsyncmapping row for mappingkey =' + CAST (@i_mappingkey AS VARCHAR) + ', spec desc=' + @i_specvaluedatadesc +
			 ', value desc= ' + @i_specvaluedatadesc
			 END 
		 END
  ELSE BEGIN
  --Spec Syncing Mapping value exists already based on mappingkey and spec item desc, update current value
      UPDATE qsiconfigspecsyncmapping
	    SET tablevaluedatatype = @i_tablevaluedatatype, tablevalue = @i_tablevalue, specitemvaluedatatype = @i_specvaluedatatype, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	    WHERE (mappingkey = @i_mappingkey AND  specitemvalue = @v_specvaluedatacode)  
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error inserting qsiconfigspecsyncmapping row for mappingkey =' + CAST (@i_mappingkey AS VARCHAR) + ', spec desc=' + @i_specvaluedatadesc +
			 ', value desc= ' + @i_specvaluedatadesc
			END 
	  END 
	
END


GO

GRANT EXEC ON qutl_insert_spec_sync_mapping_value TO PUBLIC
GO
