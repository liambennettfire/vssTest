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
  SET @v_tableid = 588
  SET @v_tablemnemonic = 'TaskSelectCriteria'

  SET @v_datadesc = 'Current Printing'

  SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     and datadesc = @v_datadesc

  IF @v_count = 0 BEGIN	  
    SELECT @v_datacode = max(datacode) + 1
      FROM gentables
     WHERE tableid = @v_tableid
  
    SET @v_datadescshort = 'Current Printing'
    SET @v_qsicode = 11

    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,4,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,0,0,'N/A',null,null,@v_qsicode)
  END
END
go