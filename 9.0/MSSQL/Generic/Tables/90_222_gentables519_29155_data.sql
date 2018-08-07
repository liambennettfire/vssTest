DECLARE   @v_count              int
DECLARE   @v_datacode           int
DECLARE   @v_tableid            int
DECLARE   @v_datadesc           varchar(120)
DECLARE   @v_datadescshort      varchar(20)
DECLARE   @v_tablemnemonic      varchar(40)
DECLARE   @v_qsicode            int
  
  -- Packager
   SET @v_tableid = 519
   SET @v_tablemnemonic = 'ContactRelationship'
   SET @v_qsicode = 2    

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'employee' --Employee
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Employee'
    SET @v_datadescshort = 'Employee'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,0,0,NULL,null,null, @v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'employee'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 0, lastmaintdate = getdate(), lastuserid = 'QSIDBA'
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
GO    