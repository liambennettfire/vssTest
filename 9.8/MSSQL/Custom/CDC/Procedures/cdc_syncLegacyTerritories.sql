/*
	CASE 41622
	CDC/UCP are moving forward with an Upgrade to 9.7 with this upgrade we need to create a process by which Title Territories are set by a job based on the Legacy Territories. 
	This process is similar to IKE setting Title Territories when it imports a Legacy Territory. The description selected in Legacy will be matched to the External code on the 
	Rights Template which will need to be manually set up by UCP/CDC.

	A procedure will be created to populate the title level rights statement with the detailed rights data from the Territory Rights Template. 
	This procedure will use Legacy Territory to find the correct Title Rights Template previously created by UCP/CDC. The procedure will run in the background, on a regular schedule. 
	The Schedule for this will be determined by UCP/CDC. Any addition or change to the Legacy Territory (book.territoriescode) will trigger the procedure to run for the affected bookkey. 
	Changes to the Territory Rights Template will be disseminated to all related titles using the Mass Update functionality currently available in Title Management.

	A gentables entry needs to be created for 543 QSI Job Type.  The externalCode needs to be 'syncterritory' for the job to run properly.

	EXEC cdc_synchLegacyTerritories
*/
CREATE PROCEDURE cdc_synchLegacyTerritories
AS
DECLARE @bookkey  int
DECLARE @nextkey int 
DECLARE @taqprojectkey int 
DECLARE @territoryrightskey int
DECLARE @rightsCode varchar(20)
DECLARE @i_titlefetchstatus int
DECLARE @lastRunDate datetime
DECLARE @qsibatchkey int
DECLARE @qsijobkey INT
DECLARE @errorcode int
DECLARE @errordesc varchar(2000)
DECLARE @jobCode int
DECLARE @i_jobdesc varchar(255)
DECLARE @i_jobdescshort varchar(255)
DECLARE @messagedesc varchar(255)

SET @jobCode = ( SELECT top 1 dataCode from gentables where tableID = 543 AND externalCode = 'syncterritory')
SET @lastRunDate = ISNULL(( SELECT MAX(q.startdatetime) from qsijob q where q.jobtypecode = @jobCode and q.jobtypesubcode = 0 ),'1900-01-01')
PRINT @lastRunDate

select @i_jobdesc='Sync Territories'
set @i_jobdescshort='Sync Territories'
set @messagedesc = 'New Sync Territories Job Started '+cast(getdate() as varchar(50))

--Start job message
EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT
									,@qsijobkey OUTPUT
									,@jobCode
									,0
									,@i_jobdesc
									,@i_jobdescshort
									,'fbt'
									,0
									,0
									,0
									,1
									,@messagedesc
									,'Job Started'
									,@errorcode OUTPUT
									,@errordesc OUTPUT

BEGIN
DECLARE c_insert_rights CURSOR FAST_FORWARD FOR
WITH CTE_rightsTemplates 
AS
(
	SELECT 
		tp.taqprojectkey,
		tr.territoryrightskey,
		tp.externalcode
	FROM 
		taqproject tp
	INNER JOIN territoryrights tr
		ON tp.taqprojectkey = tr.taqprojectkey 
	WHERE EXISTS (SELECT 1 FROM gentables g WHERE g.datacode = tp.taqprojecttype and g.tableid = 521 and g.qsicode = 3) 
	AND tp.templateind = 1 
	AND tr.bookkey IS NULL -- templates wouldn't have a bookkey 
)
SELECT 
	b.bookkey,
	gen.datadesc
FROM 
	dbo.book b
INNER JOIN gentables gen
	ON b.territoriescode = gen.datacode
	AND gen.tableID = 131
INNER JOIN CTE_rightsTemplates ct
	ON gen.dataDesc = ct.externalcode 
WHERE 
	NULLIF(b.territoriescode,0) IS NOT NULL
AND b.lastmaintdate >= @lastRunDate

	OPEN c_insert_rights
	--Initial Fetch
	FETCH NEXT FROM c_insert_rights
	INTO  @bookkey, @rightsCode
					
		WHILE @@FETCH_STATUS = 0
		BEGIN --1

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
		trc.contractexclusiveind, trc.nonexclusivesubrightsoldind, trc.currentexclusiveind, trc.exclusivesubrightsoldind, 'qsiadmin_080916',getdate()
		FROM territoryrightcountries trc
		WHERE territoryrightskey= @territoryrightskey  
		AND taqprojectkey = @taqprojectkey 
		AND bookkey IS NULL -- grab country codes from rights template 
								   
									
		FETCH NEXT FROM c_insert_rights
		INTO  @bookkey, @rightsCode
	END			
CLOSE c_insert_rights
DEALLOCATE c_insert_rights	

--Success message
EXEC [dbo].[write_qsijobmessage]	@qsibatchkey OUTPUT
									,@qsijobkey OUTPUT
									,@jobCode
									,0
									,@i_jobdesc
									,@i_jobdescshort
									,'fbt'
									,0
									,0
									,0
									,6
									,@messagedesc
									,'Complete'
									,@errorcode OUTPUT
									,@errordesc OUTPUT

END


