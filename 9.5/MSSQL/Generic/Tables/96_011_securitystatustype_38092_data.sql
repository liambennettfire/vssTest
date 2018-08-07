DECLARE
  @v_maxkey INT

BEGIN
  SELECT @v_maxkey = MAX(securitystatustypekey) 
  FROM securitystatustype 

  IF @v_maxkey IS NULL
    SET @v_maxkey = 1
  ELSE
    SET @v_maxkey = @v_maxkey + 1

  IF NOT EXISTS (SELECT securitystatustypekey FROM securitystatustype 
                 WHERE LOWER(tablename) = 'taqversion' AND LOWER(columnname) = 'plstagecode')
  BEGIN
    INSERT INTO securitystatustype
      (securitystatustypekey, tablename, columnname, wherecolumn1, wherecolumn2 , wherecolumn3, gentableid, securitystatusdesc, lastuserid, lastmaintdate)
    VALUES
      (@v_maxkey, 'taqversion', 'plstagecode', 'taqprojectkey', 'plstagecode', 'taqversionkey', 562, 'P&L Stage', 'QSIDBA', getdate())
  END
  
END
go