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
  SET @v_tableid = 514
  SET @v_tablemnemonic = 'SYSLISTTYPE'
  SET @v_datacode = 16
  
  SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Recent Specification Templates'
    SET @v_datadescshort = 'Recent Spec Template'
    
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      @v_numericdesc1,NULL,NULL,NULL,NULL,0,0,1,0,'N/A',null,null,@v_qsicode)
  END
END
go
