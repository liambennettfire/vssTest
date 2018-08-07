DECLARE  @v_gentablesrelationshipdetailkey int,
         @v_paymenttabcode int,
         @v_max_paymenttabcode int

-- Add invisible Payment Method column on all payment tabs
SET @v_paymenttabcode = 1
SET @v_max_paymenttabcode = 0
SELECT @v_max_paymenttabcode = MAX(subcode1) FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey=24 AND code1 = 1 AND code2 = 1

WHILE @v_paymenttabcode <= @v_max_paymenttabcode
BEGIN
  IF NOT EXISTS (SELECT 1 FROM gentablesrelationshipdetail WHERE gentablesrelationshipkey=24 AND code1 = 1 AND code2 = 1 AND subcode1 = @v_paymenttabcode AND subcode2 = 16)
  BEGIN
    EXECUTE get_next_key 'QSIADMIN', @v_gentablesrelationshipdetailkey OUTPUT
    
    INSERT INTO gentablesrelationshipdetail 
    (gentablesrelationshipkey, code1, gentablesrelationshipdetailkey, code2, defaultind, lastuserid, lastmaintdate, subcode1, sub2code1, subcode2, sub2code2, sortorder)
    VALUES
    (24, 1, @v_gentablesrelationshipdetailkey, 1, 0, 'QSIDBA', getdate(), @v_paymenttabcode, NULL, 16, NULL, 0)
  END
  
  SET @v_paymenttabcode = @v_paymenttabcode + 1
END

GO
