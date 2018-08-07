IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_subgentables') AND type = 'TR')
	DROP TRIGGER dbo.core_subgentables
GO

CREATE TRIGGER core_subgentables ON subgentables
FOR INSERT, UPDATE AS
IF UPDATE (datadesc) 
BEGIN
	DECLARE @v_bookkey 		INT,
		@v_printingkey		INT,
		@v_tableid		INT,
		@v_datacode		INT,
		@v_datasubcode		INT,
		@v_datadesc		VARCHAR(255)

	
	SELECT @v_tableid =i.tableid,
   	    @v_datacode =i.datacode,  
   	    @v_datadesc=i.datadesc,  
   	    @v_datasubcode=i.datasubcode
	FROM inserted i

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	/*** NO NEED TO DO THIS HERE - just going to update existing rows ***/ 
	/*** EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1 ***/

	/*** Update appropriate columns ***/
	/*** Format - mediatypesubcode ***/
	IF @v_tableid = 312
   		UPDATE coretitleinfo
   		   SET formatname=@v_datadesc
   		 WHERE mediatypecode=@v_datacode AND
			   mediatypesubcode=@v_datasubcode
END


GO


