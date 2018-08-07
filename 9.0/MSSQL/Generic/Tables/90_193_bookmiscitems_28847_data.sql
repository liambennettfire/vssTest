DECLARE
  @v_misckey INT,
  @v_datacode INT

BEGIN
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE LOWER(miscname) = 'report specification detail type') BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    SELECT @v_datacode = datacode
      FROM gentables
     WHERE tableid = 525
       AND qsicode = 1

    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,datacode)
    VALUES
      (@v_misckey, 'Report Specification Detail Type', 'Report Specification Detail Type', 5, 1, 'QSIDBA', getdate(),@v_datacode)
  END 
  
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE LOWER(miscname) = 'fob') BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'FOB', 'FOB', 3, 1, 'QSIDBA', getdate(),11)
  END 
  
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE LOWER(miscname) = 'net days') BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    

    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, fieldformat, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Net Days', 'Net Days', 1,'###', 1, 'QSIDBA', getdate(),12)
  END 
  
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE LOWER(miscname) = 'vendor id') BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Vendor ID', 'Vendor ID', 3, 1, 'QSIDBA', getdate(),13)
  END 
END
go
