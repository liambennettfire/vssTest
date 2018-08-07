DECLARE  @v_gentablesrelationshipdetailkey int,
         @v_paymentstatuscolumn int,
         @v_paymenttabcode int,
         @v_max_paymenttabcode int,
         @v_sortorder int

-- Make Payment Method column visible (after Payment Status) on all payment tabs
SET @v_paymenttabcode = 1
SET @v_max_paymenttabcode = 0
SELECT @v_max_paymenttabcode = MAX(subcode1) FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey=24 AND code1 = 1 AND code2 = 1
SET @v_paymentstatuscolumn = 9        

WHILE @v_paymenttabcode <= @v_max_paymenttabcode
BEGIN
  IF EXISTS (SELECT 1 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey = 24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND subcode2 = 16 AND sortorder = 0)
  BEGIN
    -- Get sortorder of Payment Status column
    SELECT @v_sortorder = sortorder 
    FROM gentablesrelationshipdetail
    WHERE gentablesrelationshipkey = 24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND subcode2 = @v_paymentstatuscolumn
    
    IF @v_sortorder > 0
    BEGIN
      UPDATE gentablesrelationshipdetail 
      SET sortorder = sortorder + 1
      WHERE gentablesrelationshipkey = 24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND sortorder > @v_sortorder
      
      UPDATE gentablesrelationshipdetail 
      SET sortorder = @v_sortorder + 1
      WHERE gentablesrelationshipkey = 24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND subcode2 = 16
    END
    ELSE
    BEGIN
      UPDATE gentablesrelationshipdetail 
      SET sortorder = 10
      WHERE gentablesrelationshipkey = 24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND subcode2 = 16
    END
  END
  
  SET @v_paymenttabcode = @v_paymenttabcode + 1
END

GO
