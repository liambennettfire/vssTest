/* Remove Create Proforma button from PO Reports tab on Po Summary and Express PO Summary
Inactivate Proforma PO Class
*/

DECLARE 
    @v_datacode_Tab  INT

BEGIN
	
	SELECT @v_datacode_Tab = datacode 
	From gentables 
	Where tableid = 583 and qsicode = 35
	
	Update taqrelationshiptabconfig 
	Set createitemtypecode = NULL, createclasscode = NULL, createnewrelatecode = NULL, createexistrelatecode = NULL
	where relationshiptabcode = @v_datacode_Tab
	
    Update subgentables
	set deletestatus = 'Y'
	where tableid = 550 and datacode = 15 and datadesc like 'Proforma PO Report'
END
go