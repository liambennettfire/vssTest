DECLARE
  @v_count	INT,
  @v_max_datasubcode INT

BEGIN 
	SELECT @v_max_datasubcode = COALESCE(MAX(datasubcode),0)
	  FROM subgentables
	  WHERE tableid =558 AND datacode = 4

    
    SET @v_max_datasubcode = @v_max_datasubcode + 1


   
	 INSERT INTO subgentables
           (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (558,'MerchandisingTheme',4,@v_max_datasubcode,'LDS (Mormon) Interest','TP070','N',
            1,1,1,0,'TP070',getdate(),'firebrand-sql-V2010')
    
END
go