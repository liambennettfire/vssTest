
CREATE TRIGGER [dbo].[cdc_book_TerritoryRights] 
	ON [dbo].[book]
AFTER UPDATE, INSERT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE 
		@bookkey INT,
		@rightsCode varchar(255),
		@taqprojectkey int,
		@territoryrightskey int,
		@nextkey int 
		
	SELECT @bookkey = INSERTED.bookkey
	FROM INSERTED
		
	IF UPDATE (territoriesCode)
	BEGIN
		SELECT 
			@rightsCode = gen.externalcode
		FROM 
			INSERTED b
		INNER JOIN gentables gen
			ON b.territoriescode = gen.datacode
			AND gen.tableID = 131

		SET @taqprojectkey = NULL 
		SET @territoryrightskey = NULL 
									
		SELECT 
			@taqprojectkey = tp.taqprojectkey,
			@territoryrightskey = tr.territoryrightskey
		FROM 
			taqproject tp
		INNER JOIN territoryrights tr
			ON tp.taqprojectkey = tr.taqprojectkey 
		WHERE 
			externalcode = @rightsCode  
		AND EXISTS (SELECT 1 FROM gentables g WHERE g.datacode = tp.taqprojecttype and g.tableid = 521 and g.qsicode = 3) 
		AND tp.templateind = 1 
		AND tr.bookkey IS NULL -- templates wouldn't have a bookkey 

		IF EXISTS (SELECT 1 FROM territoryrights WHERE bookkey=@bookkey AND itemtype = 1 ) 
		BEGIN
					DELETE territoryrights WHERE bookkey = @bookkey and itemtype = 1
		END

		EXEC get_next_key 'qsiadmin',@nextkey OUTPUT

		INSERT INTO TerritoryRights (territoryrightskey, itemtype,bookkey,currentterritorycode, contractterritorycode, description, autoterritorydescind, exclusivecode, singlecountrycode,
		singlecountrygroupcode, updatewithsubrightsind,note, forsalehistory, notforsalehistory,lastuserid,lastmaintdate) 
		SELECT @nextkey,1,@bookkey,tr.currentterritorycode, tr.contractterritorycode, tr.description, autoterritorydescind,exclusivecode, singlecountrycode, 
		singlecountrygroupcode, tr.updatewithsubrightsind, note, forsalehistory, notforsalehistory, 'qsiadmin',getdate()
		FROM territoryrights tr
		WHERE tr.territoryrightskey = @territoryrightskey AND taqprojectkey = @taqprojectkey

		IF EXISTS (SELECT 1 FROM TerritoryRightCountries WHERE bookkey=@bookkey ) 
		BEGIN
			DELETE TerritoryRightCountries WHERE bookkey = @bookkey and itemtype = 1 -- delete the title rights details 
		END

		INSERT INTO TerritoryRightCountries (territoryrightskey, countrycode, itemtype, taqprojectkey, rightskey, bookkey, forsaleind,
		contractexclusiveind, nonexclusivesubrightsoldind, currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate )
		SELECT @nextkey,trc.countrycode, 1, null, null, @bookkey, trc.forsaleind,
		trc.contractexclusiveind, trc.nonexclusivesubrightsoldind, trc.currentexclusiveind, trc.exclusivesubrightsoldind, 'qsiadmin',getdate()
		FROM territoryrightcountries trc
		WHERE territoryrightskey= @territoryrightskey  
		AND taqprojectkey = @taqprojectkey 
		AND bookkey IS NULL -- grab country codes from rights template 
	END
END