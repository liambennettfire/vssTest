DECLARE
  @v_formatkey INT,
  @v_newkey INT,
  @v_plstage INT,
  @v_plversion INT,
  @v_projectkey INT
  
BEGIN

  DECLARE system_generated_formats_cur CURSOR FOR 
    SELECT f.taqprojectkey, f.plstagecode, f.taqversionkey, f.taqprojectformatkey 
    FROM taqversionformat f, taqversion v
    WHERE v.taqprojectkey = f.taqprojectkey AND v.plstagecode = f.plstagecode AND v.taqversionkey = f.taqversionkey
      AND v.taqversiondesc = 'System Generated'
      AND NOT EXISTS (SELECT * FROM taqversionformatyear y 
        WHERE f.taqprojectkey = y.taqprojectkey AND f.plstagecode = y.plstagecode AND f.taqversionkey = y.taqversionkey)
           
  OPEN system_generated_formats_cur
      
  FETCH system_generated_formats_cur 
  INTO @v_projectkey, @v_plstage, @v_plversion, @v_formatkey

  WHILE @@fetch_status = 0
  BEGIN
  
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
    INSERT INTO taqversionformatyear
      (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, 
      yearcode, printingnumber, quantity, lastuserid, lastmaintdate)
    VALUES  
      (@v_newkey, @v_projectkey, @v_plstage, @v_plversion, @v_formatkey, 1, 1, 1, 'FIREBRAND', GETDATE())
      
    FETCH system_generated_formats_cur 
    INTO @v_projectkey, @v_plstage, @v_plversion, @v_formatkey      
  END
  
  CLOSE system_generated_formats_cur 
  DEALLOCATE system_generated_formats_cur
  
END
go
