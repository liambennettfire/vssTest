/******************************************************************************************
**  Executes the gentables procedures created in the standard systems message code values excel spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE
   @v_datacode		integer,
   @v_datasubcode integer,
   @v_error_code  integer,
   @v_error_desc  varchar(2000)  

   exec qutl_insert_fb_locked_gentable_value 678,2,'Keyword special characters',NULL, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	
   IF @v_error_code <> 0  print 'datadesc = ' + 'Keyword special characters' +', error message =' + @v_error_desc
   exec qutl_insert_fb_locked_subgentable_value 678, 2,1,'','KEYWORD', NULL,'In accordance with BISG Best Practices, TM will strip special characters from keywords that will cause issues with Search Engines',
    '<a href="https://askburnie.firebrandtech.com/posts/1221553-special-characters-stripped-from-keywords" target="_blank">Special Characters</a>','',@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT

END  

GO
