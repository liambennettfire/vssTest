DECLARE
  @v_count  INT,
  @v_max_subcode  INT,
  @v_datacode INT
   
BEGIN
  
  select @v_datacode = datacode from gentables where tableid = 550 and qsicode = 5
  SELECT @v_max_subcode = MAX(datasubcode)
  FROM subgentables
  WHERE tableid = 550 AND datacode = (select datacode from gentables where tableid = 550 and qsicode = 5)

  IF @v_max_subcode IS NULL
    SET @v_max_subcode = 0
    
  SELECT @v_count = COUNT(*)
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44
  
  IF @v_count = 0
  BEGIN
    SET @v_max_subcode = @v_max_subcode + 1
          
    INSERT INTO subgentables 
      (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (550,@v_datacode,@v_max_subcode,'Specification Template','N',NULL,NULL,'SearchItem',NULL,'Spec Template','QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,null,null,null,44)      
  END
  
END
go
