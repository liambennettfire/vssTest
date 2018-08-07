DECLARE
  @v_count  INT,
  @v_tableid INT,
  @v_datacode INT
  
BEGIN
  SET @v_tableid = 509
  SET @v_datacode = 24
  
  SELECT @v_count = COUNT(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND datacode = @v_datacode
  
  IF @v_count = 0 BEGIN
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,'TMM Web Printing Reports','N',NULL,@v_datacode,'RPTMENU',NULL,'Printing Reports','QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,NULL,NULL,NULL,NULL)      
 
  END  
END
go