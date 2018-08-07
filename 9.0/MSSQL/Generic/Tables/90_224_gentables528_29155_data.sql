DECLARE
  @v_count  INT,
  @v_max_datacode  INT,
  @v_datacode INT
   
BEGIN
  
    SELECT @v_max_datacode = MAX(datacode)
  FROM  gentables
  WHERE tableid = 528

  IF @v_max_datacode IS NULL
    SET @v_max_datacode = 0
      
	IF NOT EXISTS (SELECT qsicode FROM gentables WHERE tableid=528 and qsicode=10)
	BEGIN 
		insert into gentables (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,lastuserid,lastmaintdate,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,qsicode)
		select 528,@v_max_datacode + 1,'PO Shipping Instructions','N',10,'ContactNoteTypes','PO Ship Instr.','qsidba', GETDATE(), 0,0,1,0,'N/A',10
	END
  
  
END
go
