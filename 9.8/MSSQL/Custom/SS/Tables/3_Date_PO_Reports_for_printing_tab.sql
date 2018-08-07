/******************************************************************************************
**  Configure PO Date to appear on PO Reports (for printings) tab
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_relatedtableid  INT,
  @v_relateddatacode INT,
  @v_gentablesitemtypekey INT,
  @v_taqrelationshipconfigkey INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 

exec qutl_insert_taqrelationshiptabconfig_dates 37,'PO Reports (on Printings)', 14,40,'PO Date','PO Date',NULL,1, @v_taqrelationshipconfigkey output, @v_error_code output, @v_error_desc output	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END
GO