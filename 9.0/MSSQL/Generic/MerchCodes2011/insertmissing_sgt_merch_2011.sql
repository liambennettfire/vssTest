DECLARE
  @v_count	INT,
  @v_max_datasubcode INT

BEGIN 
	SELECT @v_max_datasubcode = COALESCE(MAX(datasubcode),0)
	  FROM subgentables
	  WHERE tableid =558 AND datacode = 2

    
    SET @v_max_datasubcode = @v_max_datasubcode + 1


   
	 INSERT INTO subgentables
           (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (558,'MerchandisingTheme',2,@v_max_datasubcode,'Home School','EV082','N',
            1,1,1,0,'EV082',getdate(),'firebrand-sql-V2011')


	SET @v_max_datasubcode = @v_max_datasubcode + 1


   
	 INSERT INTO subgentables
           (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (558,'MerchandisingTheme',2,@v_max_datasubcode,'Vacation Bible School','EV095','N',
            1,1,1,0,'EV095',getdate(),'firebrand-sql-V2011')
    
END
go