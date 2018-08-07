
/******************************************************************************************
**  Executes the clientoptions procedures created in the clientoptions values excel spreadsheet
**  
**  Created 12/1/17 Olivia
*******************************************************************************************
**  Change History
*******************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------------------------
**  12/1/17      OA          Case 39693
*******************************************************************************************/

BEGIN

  DECLARE
   @v_optionid             integer,
   @v_optionname           varchar (40),
   @v_optionvaluecomment   varchar(400),
   @v_optionvalue          smallint,
   @i_optiondescription    varchar(2000),
   @v_activeind 		   integer,
   @v_systemfunctioncode   integer,
   @v_error_code           integer,
   @v_error_desc		   varchar(2000)

 exec qutl_insert_clientoptions_value 77,'Use Title File Locations on Web','0 (default) TMM Desktop File Locations Only / 1 Title File Locations on Web / 2 Use files from Cloud (Digital Assets Tab)',0,'optionvalue 2- Files uploaded to the cloud using the digital assets tab.  Cover images will appear on title summary based on asset type hierarchy: Cover Art High, Cover Art Low, Cover Art Online, Draft Cover.',1,12, @v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'optionid = ' + CAST(77 AS varchar)+ ',  error message =' + @v_error_desc


 END
 GO