DECLARE 
	@v_misckey INT,
	@v_datacode INT,
	@v_datasubcode INT
	
	
BEGIN
	SELECT @v_datacode = datacode   --Report Specification Detail Type
      FROM gentables
     WHERE tableid = 525
       AND qsicode = 1
       
    SELECT @v_datasubcode = datasubcode
      FROM subgentables
     WHERE tableid = 525
       AND datacode = @v_datacode
       AND qsicode = 4    --Specification Item Detail
       
    SELECT @v_misckey = misckey
      FROM bookmiscitems
     WHERE lower(miscname) = 'report specification detail type'
     
    INSERT INTO bookmiscdefaults (misckey, orglevel,orgentrykey,longvalue,lastuserid,lastmaintdate,datacode)
     VALUES(@v_misckey,1,1,@v_datasubcode,'QSIDBA',getdate(),@v_datacode)
END
Go