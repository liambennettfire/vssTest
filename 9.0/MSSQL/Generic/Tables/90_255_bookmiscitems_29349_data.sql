DECLARE
  @v_misckey INT,
  @v_datacode INT

BEGIN
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Freight Terms') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    SELECT @v_datacode = datacode
      FROM gentables
     WHERE tableid = 525
       AND datadesc = 'Freight Terms'
       
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode,datacode)
    VALUES
      (@v_misckey, 'Freight Terms', 'Freight Terms', 5, 1, 'QSIDBA', getdate(),19,@v_datacode)
  END 
  
 
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Import Country') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    
    SELECT @v_datacode = datacode
      FROM gentables
     WHERE tableid = 525
       AND datadesc = 'Import Country'
       
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode,datacode)
    VALUES
      (@v_misckey, 'Import Country', 'Import Country', 5, 1, 'QSIDBA', getdate(),20,@v_datacode)
  END 
  
  
END
go