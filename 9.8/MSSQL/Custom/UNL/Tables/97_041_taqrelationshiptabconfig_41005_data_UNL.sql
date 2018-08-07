/******************************************************************************
**  Name: 
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  10/14/2016   UK          Case 41005 - reopen
*******************************************************************************/

DECLARE
	@v_datacode INT,
	@v_datadesc VARCHAR(40),
	@v_taqrelationshipconfigkey INT,
	@v_relationshiptabcode INT,
	@v_itemqsicode_Journal INT,
	@v_classqsicode_Journal INT,	
	@v_classqsicode_Volume INT,
	@v_itemcode_Journal INT,
	@v_classcode_Volume INT,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	
  SET @v_error_code = 0
  SET @v_error_desc = ''
  SET @v_itemqsicode_Journal = 6
  SET @v_classqsicode_Journal = 4
  SET @v_classqsicode_Volume = 8
  SET @v_taqrelationshipconfigkey = 0
  SET  @v_relationshiptabcode = 4
  SET @v_itemcode_Journal = 0
  SET @v_classcode_Volume = 0
	
SELECT @v_datacode = datacode, @v_datadesc = datadesc 
FROM gentables 
WHERE tableid = 583 and qsicode = @v_relationshiptabcode	

EXEC qutl_insert_taqrelationshiptabconfig @v_relationshiptabcode, @v_datadesc, @v_itemqsicode_Journal, @v_classqsicode_Journal, @v_taqrelationshipconfigkey output, @v_error_code output,@v_error_desc output

IF @v_error_code <> 0 BEGIN

  PRINT 'Error inserting into taqrelationshiptabconfig: item qsicode= ' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Journal AS VARCHAR)
  RETURN
END 

-- Volumes
exec qutl_get_item_class_datacodes_from_qsicodes @v_itemqsicode_Journal, @v_classqsicode_Volume,  @v_itemcode_Journal output, @v_classcode_Volume output,
     @v_error_code output,@v_error_desc output
IF @v_error_code <> 0 BEGIN
  PRINT 'Error finding item-class: item qsicode=' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Volume AS VARCHAR)
  RETURN
END 

UPDATE taqrelationshiptabconfig 
SET defaultfilteritemtype = @v_itemcode_Journal, defaultfilterusageclass = @v_classcode_Volume, scrollbarheight = 225, defaultsortorder = 'otherprojectdisplayname asc',
createitemtypecode = 6, createclasscode = 2, createnewrelatecode = 6, createexistrelatecode = 2,
hidefiltersind = 1, hideclassind = 1, hidetypeind = 1, hidethisrelind = 1, hideotherrelind = 1, hidenotesind = 1, hideownerind = 1, displaytemplatesonlyind =1,
hideparticipantsind = 1, hidedeletebuttonind = 1, hidekeyind = 1, hidestatusind = 1
WHERE relationshiptabcode = @v_relationshiptabcode

GO


DECLARE
	@v_datacode INT,
	@v_datadesc VARCHAR(40),
	@v_taqrelationshipconfigkey INT,
	@v_relationshiptabcode INT,
	@v_itemqsicode_Journal INT,
	@v_classqsicode_Journal INT,	
	@v_classqsicode_Issue INT,
	@v_itemcode_Journal INT,
	@v_classcode_Issue INT,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	
  SET @v_error_code = 0
  SET @v_error_desc = ''
  SET @v_itemqsicode_Journal = 6
  SET @v_classqsicode_Journal = 4
  SET @v_classqsicode_Issue = 5
  SET @v_taqrelationshipconfigkey = 0
  SET  @v_relationshiptabcode = 7
  SET @v_itemcode_Journal = 0
  SET @v_classcode_Issue = 0
	
SELECT @v_datacode = datacode, @v_datadesc = datadesc 
FROM gentables 
WHERE tableid = 583 and qsicode = @v_relationshiptabcode	

EXEC qutl_insert_taqrelationshiptabconfig @v_relationshiptabcode, @v_datadesc, @v_itemqsicode_Journal, @v_classqsicode_Journal, @v_taqrelationshipconfigkey output, @v_error_code output,@v_error_desc output

IF @v_error_code <> 0 BEGIN

  PRINT 'Error inserting into taqrelationshiptabconfig: item qsicode= ' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Journal AS VARCHAR)
  RETURN
END 

-- Issues
exec qutl_get_item_class_datacodes_from_qsicodes @v_itemqsicode_Journal, @v_classqsicode_Issue,  @v_itemcode_Journal output, @v_classcode_Issue output,
     @v_error_code output,@v_error_desc output
IF @v_error_code <> 0 BEGIN
  PRINT 'Error finding item-class: item qsicode=' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Issue AS VARCHAR)
  RETURN
END 

UPDATE taqrelationshiptabconfig 
SET defaultfilteritemtype = @v_itemcode_Journal, defaultfilterusageclass = @v_classcode_Issue, scrollbarheight = 225, defaultsortorder = 'otherprojectdisplayname asc',
hidefiltersind = 1, hideclassind = 1, hidetypeind = 1, hidethisrelind =1, hideotherrelind = 1, hidenotesind = 1, hideparticipantsind = 1, hidedeletebuttonind = 1, hidekeyind = 1, 
createastemplateind = 1, displaytemplatesonlyind = 1
WHERE relationshiptabcode = @v_relationshiptabcode

GO

-- Issues (on Volume)
DECLARE
	@v_datacode INT,
	@v_datadesc VARCHAR(40),
	@v_taqrelationshipconfigkey INT,
	@v_relationshiptabcode INT,
	@v_itemqsicode_Journal INT,
	@v_classqsicode_Volume INT,	
	@v_classqsicode_Issue INT,
	@v_itemcode_Journal INT,
	@v_classcode_Issue INT,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	
  SET @v_error_code = 0
  SET @v_error_desc = ''
  SET @v_itemqsicode_Journal = 6
  SET @v_classqsicode_Volume = 8
  SET @v_classqsicode_Issue = 5
  SET @v_taqrelationshipconfigkey = 0
  SET  @v_relationshiptabcode = 12
  SET @v_itemcode_Journal = 0
  SET @v_classcode_Issue = 0
	
SELECT @v_datacode = datacode, @v_datadesc = datadesc 
FROM gentables 
WHERE tableid = 583 and qsicode = @v_relationshiptabcode	

EXEC qutl_insert_taqrelationshiptabconfig @v_relationshiptabcode, @v_datadesc, @v_itemqsicode_Journal, @v_classqsicode_Volume, @v_taqrelationshipconfigkey output, @v_error_code output,@v_error_desc output

IF @v_error_code <> 0 BEGIN

  PRINT 'Error inserting into taqrelationshiptabconfig: item qsicode= ' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Volume AS VARCHAR)
  RETURN
END 

-- Issues
exec qutl_get_item_class_datacodes_from_qsicodes @v_itemqsicode_Journal, @v_classqsicode_Issue,  @v_itemcode_Journal output, @v_classcode_Issue output,
     @v_error_code output,@v_error_desc output
IF @v_error_code <> 0 BEGIN
  PRINT 'Error finding item-class: item qsicode=' + cast(@v_itemqsicode_Journal AS VARCHAR)+ ', classqsicode = ' +  cast(@v_classqsicode_Issue AS VARCHAR)
  RETURN
END 

UPDATE taqrelationshiptabconfig 
SET defaultfilteritemtype = @v_itemcode_Journal, defaultfilterusageclass = @v_classcode_Issue, scrollbarheight = 225, defaultsortorder = 'otherprojectdisplayname asc',
createitemtypecode = 6, createclasscode = 3, createnewrelatecode = 6, createexistrelatecode = 3,
hidefiltersind = 1, hideclassind = 1, hidetypeind = 1, hidethisrelind =1, hideotherrelind = 1, hidenotesind = 1,
 hideparticipantsind = 1, hidedeletebuttonind = 1, hidekeyind = 1, 
createastemplateind = 0, displaytemplatesonlyind = 1, hidestatusind = 1, hideownerind = 1
WHERE relationshiptabcode = @v_relationshiptabcode

GO