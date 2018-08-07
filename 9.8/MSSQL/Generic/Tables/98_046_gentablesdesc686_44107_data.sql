--------------------------------------------------------
--Table Name: gentablesdesc
--Add gentables - rights impact(tableID 686)

--This Firebrand controlled table will be used to default the Contact As value for the Home Tasks section.
--------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM gentablesDesc where tableID = 686)
INSERT INTO gentablesdesc 
(
	tableID, 
	tabledesc,
	tabledescLong,
	tablemnemonic,
	userupdatableind,
	userupdate,
	lockind,
	gentablesdesclong,
	subjectcategoryind,
	subgenallowed,
	sub2genallowed,
	requiredlevels,
	updatedescallowed,
	activeind,
	fakeentryind,
	itemtypefilterind,
	hideonixfields,
	elofieldidlevel,
	elofieldid,
	productdetailind,
	usedivisionind,
	sourcetablecode,
	location
)
VALUES
(
	686, --tableId
	'HomeTask', --tabledesc
	'Home Task Contact', --tabledesclong
	'HomeTask', --tablemnemonic
	0, --userupdatableind
	'N', --userUpdate
	1, --lockInd
	'This will be a firebrand controlled table that will be used to default the Contact As value for the Home Tasks section.', --gentablesdesclong
	0, --subjectcategoryind
	0, --subgenallowed
	0, --sub2genallowed
	1, --requiredlevels
	0, --updatedescallowed
	0, --activeind
	1, --fakeentryind
	2, --itemtypefilterind
	1, --hideonixfields
	0, --elofieldidlevel
	NULL, --elofieldid
	0, --productdetailind
	0, --usedivisionind
	0, --sourcetablecode
	'gentables'
)
GO

--------------------------------------------------------
--Table Name: gentables
--Add values to Home Task Contact table (686)

--This is a firebrand controlled table so datacodes have been identified in the qsicode spreadsheet (qsicodes not needed for firebrand controlled tables.  
--Datacodes need to be put in exactly as stated not left for the system to generate - use qutl_insert_fb_locked_gentable_value to insert values
--Tableid:686
--------------------------------------------------------
--DECLARE @dataCode INT, @errorCode INT, @errorDesc VARCHAR(max)
--EXEC dbo.qutl_insert_fb_locked_gentable_value 686, 0,'Project Owner', 1, @dataCode OUT, @errorCode OUT, @errorDesc OUT
--PRINT @errorDesc
--GO
DECLARE 
	@v_error  INT,
	@o_error_code INT,
	@o_error_desc varchar(2000)

INSERT INTO gentables
  (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic,lastuserid,lastmaintdate, lockbyqsiind, lockbyeloquenceind)
VALUES
  (686, 0 , 'Project Owner', 'N', 1, 'HomeTask', 'QSIDBA', getdate(), 1, 0)

SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'insert to table had an error: tableid=' + cast(686 AS VARCHAR)+ ', datacode=' + cast(0 AS VARCHAR) 
  + ', desc= Project Owner'
END    

DECLARE @dataCode INT, @errorCode INT, @errorDesc VARCHAR(max)
EXEC dbo.qutl_insert_fb_locked_gentable_value 686, 1,'Contact 1', 3, @dataCode OUT, @errorCode OUT, @errorDesc OUT
PRINT @errorDesc
GO

DECLARE @dataCode INT, @errorCode INT, @errorDesc VARCHAR(max)
EXEC dbo.qutl_insert_fb_locked_gentable_value 686, 2,'Contact 2', 4, @dataCode OUT, @errorCode OUT, @errorDesc OUT
PRINT @errorDesc
GO

DECLARE @dataCode INT, @errorCode INT, @errorDesc VARCHAR(max)
EXEC dbo.qutl_insert_fb_locked_gentable_value 686, 3,'All', 5, @dataCode OUT, @errorCode OUT, @errorDesc OUT
PRINT @errorDesc
GO

DECLARE @dataCode INT, @errorCode INT, @errorDesc VARCHAR(max)
EXEC dbo.qutl_insert_fb_locked_gentable_value 686, 4,'Contact 1 or Contact 2', 2, @dataCode OUT, @errorCode OUT, @errorDesc OUT
PRINT @errorDesc
GO

