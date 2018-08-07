/******************************************************************************************
**  Project relationship to web relationship tab mapping
**  qutl_insert_gentablesrelationshipdetail_value
*******************************************************************************************/



BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_gentablesrelationshipdetailkey  INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 

exec qutl_insert_gentablesrelationshipdetail_value 6, 'PO Reports (for Printings)', NULL, 'PO Reports (on Printings)',  NULL,'',  NULL, '',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Printing (for PO Reports)', NULL, 'PO Reports (on Printings)',  NULL,'',  NULL, '',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

end
go


