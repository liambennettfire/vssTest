-- New misc item to be used on P&L Version Details, Project/Work Summary section
DECLARE
  @v_misckey INT

BEGIN

  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE LOWER(miscname) = 'p&l input currency')
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems

    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, calcitemtypecode, lastuserid, lastmaintdate)
    VALUES
      (@v_misckey, 'P&L Input Currency', 'P&L Input Currency', 9, 1, 3, 'QSIDBA', getdate())
  END
  
  UPDATE bookmiscitems
  SET calcitemtypecode = 3
  WHERE miscname IN ('Latest Gross Margin', 'Latest Gross Margin %', 'From Stage')
  
END
go