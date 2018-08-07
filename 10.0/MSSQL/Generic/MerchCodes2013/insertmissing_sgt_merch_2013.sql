DECLARE
  @v_count	INT,
  @v_max_datasubcode INT,
  @v_datacode INT

BEGIN 
  SELECT @v_datacode = datacode
    FROM gentables
   WHERE tableid = 558 and eloquencefieldtag = 'HL'

  SELECT @v_count = COUNT(*)
    FROM subgentables
   WHERE tableid =558 AND datacode = @v_datacode

  IF @v_count > 0 BEGIN

	  SELECT @v_max_datasubcode = COALESCE(MAX(datasubcode),0)
	    FROM subgentables
	   WHERE tableid =558 AND datacode = @v_datacode

      
    SET @v_max_datasubcode = @v_max_datasubcode + 1
  END
  ELSE BEGIN
    SET @v_max_datasubcode =  1
  END

  INSERT INTO subgentables
      (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
       acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
       lastmaintdate,lastuserid)
    values
      (558,'EloquenceEnabledCategories',@v_datacode,@v_max_datasubcode,'Rosh Hashanah','HL155','N',
       1,1,1,0,'HL155',getdate(),'FB-sql-V2013')


	SET @v_max_datasubcode = @v_max_datasubcode + 1
   
	INSERT INTO subgentables
      (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
       acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
       lastmaintdate,lastuserid)
    values
      (558,'EloquenceEnabledCategories',@v_datacode,@v_max_datasubcode,'Yom Kippur','HL195','N',
       1,1,1,0,'HL195',getdate(),'FB-sql-V2013')
    
END
go