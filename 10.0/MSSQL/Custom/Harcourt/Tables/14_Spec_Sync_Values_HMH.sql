
/******************************************************************************************
**  Inserts Standard Non Conversion Spec Sync Items
Other format syncs to formatchildcode on bookisimon
print vendor syncs to vendorkey on textspecs
jacket vendor syncs to vendorkey on jacketspecs
*******************************************************************************************/

BEGIN

  DECLARE
	@v_speccategorycode			INTEGER,
	@v_specitemcode				INTEGER,
	@v_itemtype					INTEGER,
	@v_classcode				INTEGER,
	@v_parentspeccategorykey	INTEGER,
    @v_error_code				INTEGER,
    @v_error_desc				VARCHAR(2000) 


	SET @v_speccategorycode	= 0
	SET @v_specitemcode	= 0	
	SET @v_itemtype	= 0
	SET @v_classcode =	0
	SET @v_parentspeccategorykey = NULL
    SET @v_error_code = 0
	SET @v_error_desc = ' ' 


exec qutl_get_subgentables_codes_by_qsi_or_desc 616,1,'Summary',22,'Other Format', @v_speccategorycode OUTPUT,  @v_specitemcode OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  BEGIN print 'ERROR'  print 'spec category  = ' + 'Summary' + ', spec item = ' + 'Other Format' +', error message =' + @v_error_desc  END  SET @v_error_code = 0   SET  @v_error_desc = ' ' 	SELECT @v_itemtype = datacode from gentables where tableid = 550 and qsicode = 14	SELECT @v_classcode = datasubcode from subgentables where tableid = 550 and qsicode = 40	SET @v_parentspeccategorykey =  NULL	IF (@v_itemtype <> 0 AND @v_speccategorycode <> 0 AND @v_specitemcode <>0)    EXEC  qutl_insert_spec_sync_value @v_speccategorycode,@v_specitemcode,@v_itemtype,@v_classcode,NULL, NULL,1,1,'DT','int','booksimon','formatchildcode',NULL, @v_parentspeccategorykey,1,NULL, @v_error_code OUTPUT,@v_error_desc OUTPUT 	IF @v_error_code <> 0   BEGIN print 'ERROR' print 'spec category = ' + 'Summary'+ ', spec item = ' + 'Other Format' +', error message =' + @v_error_desc END
exec qutl_get_subgentables_codes_by_qsi_or_desc 616,1,'Summary',23,'Print Vendor', @v_speccategorycode OUTPUT,  @v_specitemcode OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  BEGIN print 'ERROR'  print 'spec category  = ' + 'Summary' + ', spec item = ' + 'Print Vendor' +', error message =' + @v_error_desc  END  SET @v_error_code = 0   SET  @v_error_desc = ' ' 	SELECT @v_itemtype = datacode from gentables where tableid = 550 and qsicode = 14	SELECT @v_classcode = datasubcode from subgentables where tableid = 550 and qsicode = 40	SET @v_parentspeccategorykey =  NULL	IF (@v_itemtype <> 0 AND @v_speccategorycode <> 0 AND @v_specitemcode <>0)    EXEC  qutl_insert_spec_sync_value @v_speccategorycode,@v_specitemcode,@v_itemtype,@v_classcode,NULL, NULL,1,1,'DT','int','textspecs','vendorkey',NULL, @v_parentspeccategorykey,1,NULL, @v_error_code OUTPUT,@v_error_desc OUTPUT 	IF @v_error_code <> 0   BEGIN print 'ERROR' print 'spec category = ' + 'Summary'+ ', spec item = ' + 'Print Vendor' +', error message =' + @v_error_desc END
exec qutl_get_subgentables_codes_by_qsi_or_desc 616,1,'Summary',24,'Jacket Vendor', @v_speccategorycode OUTPUT,  @v_specitemcode OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  BEGIN print 'ERROR'  print 'spec category  = ' + 'Summary' + ', spec item = ' + 'Jacket Vendor' +', error message =' + @v_error_desc  END  SET @v_error_code = 0   SET  @v_error_desc = ' ' 	SELECT @v_itemtype = datacode from gentables where tableid = 550 and qsicode = 14	SELECT @v_classcode = datasubcode from subgentables where tableid = 550 and qsicode = 40	SET @v_parentspeccategorykey =  NULL	IF (@v_itemtype <> 0 AND @v_speccategorycode <> 0 AND @v_specitemcode <>0)    EXEC  qutl_insert_spec_sync_value @v_speccategorycode,@v_specitemcode,@v_itemtype,@v_classcode,NULL, NULL,1,1,'DT','int','jacketspecs','vendorkey',NULL, @v_parentspeccategorykey,1,NULL, @v_error_code OUTPUT,@v_error_desc OUTPUT 	IF @v_error_code <> 0   BEGIN print 'ERROR' print 'spec category = ' + 'Summary'+ ', spec item = ' + 'Jacket Vendor' +', error message =' + @v_error_desc END


    
END  
  
 GO