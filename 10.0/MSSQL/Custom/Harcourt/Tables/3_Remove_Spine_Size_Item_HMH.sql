
/************************************************************************************************
**  Deltes Spine size from subgentables bind component 
*************************************************************************************************/

BEGIN

DELETE FROM subgentables WHERE tableid = 616 and datacode = 2 and datasubcode = 3 and datadesc like 'Spine Size'
IF @@ERROR <> 0 BEGIN
	PRINT 'Deleting Spec Category gentables failed'
	RETURN
    END
 
DELETE FROM subgentables_ext WHERE tableid = 616 and datacode = 2 and datasubcode = 3 
IF @@ERROR <> 0 BEGIN
	PRINT 'Deleting Spec Category gentables_ext failed'
	RETURN
    END 
	   	
   	    
END  
  
 GO