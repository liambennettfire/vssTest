DECLARE
  @v_count  INT,
  @v_misckey  INT,
  @v_miscname VARCHAR(40)
     
BEGIN

  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'P&L Input Currency'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey, @v_miscname = miscname
    FROM bookmiscitems
    WHERE miscname = 'P&L Input Currency'
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, orglevelkey, orgentrykey, @v_miscname, 
      'SELECT g.datadesc FROM taqproject p, gentables g WHERE p.plenteredcurrency = g.datacode AND g.tableid=122 AND p.taqprojectkey=@projectkey', 'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  END
  
END
go
