/******************************************************************************************
**  configure columns and product numbers for PO Reports (for Printings) tab
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_taqrelationshipconfigkey INT,
  @v_error_desc   VARCHAR(2000) 


exec qutl_insert_taqrelationshiptabconfig_labels 37,'PO Reports (on Printings)',14,40, '', '', '', '',NULL,'', NULL,'',1,0,0,1,1,1, 1, 0,0,1,  @v_taqrelationshipconfigkey   OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	 IF @v_error_code <> 0  print ' error message =' + @v_error_desc	 	 	 	 	UPDATE taqrelationshiptabconfig SET productidcode1 = '3' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey	UPDATE taqrelationshiptabconfig SET productid1label = 'PO #' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey	UPDATE taqrelationshiptabconfig SET productidcode2 = '4' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey	UPDATE taqrelationshiptabconfig SET productid2label = 'PO Amendment #' WHERE taqrelationshiptabconfigkey = @v_taqrelationshipconfigkey

END
GO