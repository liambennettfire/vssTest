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
DECLARE   @v_itemtypecode       int
DECLARE   @v_itemtypesubcode    int
DECLARE   @v_qsicode            int

BEGIN
  SET @v_tableid = 661
  SET @v_tablemnemonic = 'SPECVAL'

  SELECT @v_datacode = coalesce(max(datacode),0) + 1
    FROM gentables
   WHERE tableid = @v_tableid

  IF @v_datacode = 0 
   SET @v_datacode = 1
  
  SET @v_datadesc = 'Standard Specification Item'
  SET @v_datadescshort = 'Standard Spec. Item'
  

  INSERT INTO gentables 
   (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
    numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
    eloquencefieldtag,alternatedesc1,alternatedesc2)
  VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,@v_datacode,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
    NULL,NULL,NULL,1,NULL,0,0,1,0,
    'N/A',NULL,NULL)

  

  SET @v_datadesc = 'Use alternate tables'
  SET @v_datadescshort = 'Use alternate tables'
  SET @v_datacode = @v_datacode + 1 
  

  INSERT INTO gentables 
    (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
     numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
     eloquencefieldtag,alternatedesc1,alternatedesc2)
   VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,0,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
    NULL,NULL,NULL,1,NULL,0,0,1,0,
    'N/A',null,null)


  SET @v_datadesc = 'Use Functions by qsicode'
  SET @v_datadescshort = 'Functions by qsicode'
  SET @v_datacode = @v_datacode + 1 
  

  INSERT INTO gentables 
    (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
     numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
     eloquencefieldtag,alternatedesc1,alternatedesc2)
   VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,0,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
    NULL,NULL,NULL,1,NULL,0,0,1,0,
    'N/A',null,null)
  
END
go

