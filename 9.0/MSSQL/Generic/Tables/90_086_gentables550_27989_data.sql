DECLARE   @v_count              int
DECLARE   @v_datacode           int
DECLARE   @v_datasubcode        int
DECLARE   @v_tableid            int
DECLARE   @v_datadesc           varchar(120)
DECLARE   @v_datadescshort      varchar(20)
DECLARE   @v_tablemnemonic      varchar(40)
DECLARE   @v_alternatedesc1     varchar(255)
DECLARE   @v_alternatedesc2     varchar(255)
DECLARE   @v_newkey             int
DECLARE   @v_numericdesc1       int
DECLARE   @v_numericdesc2       int
DECLARE   @v_itemtypecode       int
DECLARE   @v_itemtypesubcode    int
DECLARE   @v_qsicode            int

BEGIN
  SET @v_tableid = 550
  SET @v_tablemnemonic = 'SearchItem'
  SET @v_datacode = 15
  
  SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Purchase Orders'
    SET @v_datadescshort = 'Purchase Orders'
    SET @v_qsicode = 15
    
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,14,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',@v_datadesc,null,@v_qsicode)
  END

  SET @v_datasubcode = 1
  SET @v_qsicode = 41
  
  SELECT @v_count = count(*)
    FROM subgentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
     AND datasubcode = @v_datasubcode
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Purchase Orders' 
    SET @v_datadescshort = 'Purchase Orders'
        
    INSERT INTO subgentables 
      (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datasubcode,@v_datadesc,'N',NULL,1,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@v_qsicode)
      
  END
  
  SET @v_datasubcode = 2
  SET @v_qsicode = 42
  
  SELECT @v_count = count(*)
    FROM subgentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
     AND datasubcode = @v_datasubcode
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Proforma PO Report' 
    SET @v_datadescshort = 'Proforma PO Report'
        
    INSERT INTO subgentables 
      (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datasubcode,@v_datadesc,'N',NULL,1,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@v_qsicode)
      
  END
  
  SET @v_datasubcode = 3
  SET @v_qsicode = 43
  
  SELECT @v_count = count(*)
    FROM subgentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
     AND datasubcode = @v_datasubcode
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Final PO Report' 
    SET @v_datadescshort = 'Final PO Report'
        
    INSERT INTO subgentables 
      (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,subgen1ind,subgen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datasubcode,@v_datadesc,'N',NULL,1,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@v_qsicode)
      
  END
END
go
