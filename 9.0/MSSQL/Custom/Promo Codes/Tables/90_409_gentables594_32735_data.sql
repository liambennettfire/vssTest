DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 594 AND LOWER(datadesc) = 'promo code id') BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 594
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 594 AND LOWER(datadesc) = 'promo code id'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,eloquencefieldtag,alternatedesc1)
      VALUES
        (594, @v_max_code, 'Promo Code ID', 'N', 'ProjectStatus', NULL, 'Promo Code ID',
        'QSIDBA', getdate(), 0, 0,'CLD_PC_PROMO_CODE_ID','validate_promocode_id')
    END
    IF @v_count = 1
    BEGIN
		UPDATE gentables 
		   SET alternatedesc1 = 'validate_promocode_id',
		       lastuserid = 'FB_UPDATE_32735',
		       lastmaintdate = GETDATE(),
		       eloquencefieldtag = 'CLD_PC_PROMO_CODE_ID'
		 WHERE tableid = 594
		   AND LOWER(datadesc) = 'promo code id'
    
    END
  END

END
go

