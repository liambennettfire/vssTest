DECLARE @v_datacode 	INT
DECLARE @v_datasubcode	INT
DECLARE @v_bisacdatacode  varchar(25)
DECLARE @v_eloquencefieldtag	varchar(25)

BEGIN

	DECLARE cur_subgentables339 CURSOR FOR
		 SELECT DISTINCT datacode, datasubcode, bisacdatacode,eloquencefieldtag
		 FROM subgentables
		 WHERE tableid = 339 
				AND datalength(eloquencefieldtag) > 9 
				AND datalength(bisacdatacode) > 9 
		 ORDER by datacode, datasubcode

	OPEN cur_subgentables339
  
  	FETCH NEXT FROM cur_subgentables339 INTO @v_datacode, @v_datasubcode, @v_bisacdatacode, @v_eloquencefieldtag

 	WHILE (@@FETCH_STATUS <> -1)
 	 BEGIN

		UPDATE subgentables
               SET bisacdatacode = rtrim(ltrim(@v_bisacdatacode)),
                      eloquencefieldtag = rtrim(ltrim(@v_eloquencefieldtag))
           WHERE tableid = 339 
                AND datacode = @v_datacode
                AND datasubcode = @v_datasubcode
          
			FETCH NEXT FROM cur_subgentables339 INTO @v_datacode, @v_datasubcode, @v_bisacdatacode, @v_eloquencefieldtag

	END
	CLOSE cur_subgentables339
     DEALLOCATE cur_subgentables339

END
go

update subgentables
   set bisacdatacode = 'JNF003240', 
       eloquencefieldtag = 'JNF003240'
  where tableid = 339 
     and bisacdatacode = 'JNF0032400'


