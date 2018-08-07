IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.POFEEDOUTHISTORY') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
  DROP TABLE dbo.pofeedouthistory

GO


CREATE TABLE dbo.pofeedouthistory
(
	recordname VARCHAR(2) NOT NULL,
	recordtype VARCHAR(1) NULL,
	isbn10 VARCHAR(10) NOT NULL,
	ponumber VARCHAR(12) NULL,
	supplier VARCHAR(30) NULL,
	ordertype VARCHAR(1) NULL,
	packpo VARCHAR(1) NULL,
	requestioner VARCHAR(10) NULL,
	printingnumber NUMERIC(3, 0) NOT NULL,
	estdetails VARCHAR(1) NULL,
	packsize NUMERIC(10, 0) NULL,
	binderyqty NUMERIC(10, 0) NULL,
	warehouseqty NUMERIC(10, 0) NULL,
	orderedqty NUMERIC(10, 0) NULL,
	editiontotalcost NUMERIC(15, 4) NULL,
	planttotalcost NUMERIC(15, 4) NULL,
	ordereddate VARCHAR(10) NULL,
	duedate VARCHAR(10) NULL,
	pubprice VARCHAR(8) NULL,
	bindings NUMERIC(15, 4) NULL,
	cartoningpalleting NUMERIC(15, 4) NULL,
	stampdies NUMERIC(15, 4) NULL,
	coverprinting NUMERIC(15, 4) NULL,
	covers NUMERIC(15, 4) NULL,
	docutech NUMERIC(15, 4) NULL,
	endpapers NUMERIC(15, 4) NULL,
	endpaperprinting NUMERIC(15, 4) NULL,
	importduty NUMERIC(15, 4) NULL,
	inboundfreight NUMERIC(15, 4) NULL,
	insertedition NUMERIC(15, 4) NULL,
	jacketcoverpaper NUMERIC(15, 4) NULL,
	jacketprinting NUMERIC(15, 4) NULL,
	misc NUMERIC(15, 4) NULL,
	multmedma NUMERIC(15, 4) NULL,
	paperstock NUMERIC(15, 4) NULL,
	plates NUMERIC(15, 4) NULL,
	printersuppliedpaper NUMERIC(15, 4) NULL,
	purchfg NUMERIC(15, 4) NULL,
	specialmaterialpacking NUMERIC(15, 4) NULL,
	textprinting NUMERIC(15, 4) NULL,
	alteration NUMERIC(15, 4) NULL,
	art NUMERIC(15, 4) NULL,
	authorrelated NUMERIC(15, 4) NULL,
	componentdesignfees NUMERIC(15, 4) NULL,
	composition NUMERIC(15, 4) NULL,
	copyediting NUMERIC(15, 4) NULL,
	coverjackets NUMERIC(15, 4) NULL,
	editorialrelated NUMERIC(15, 4) NULL,
	freight NUMERIC(15, 4) NULL,
	fullservicemanagement NUMERIC(15, 4) NULL,
	indexing NUMERIC(15, 4) NULL,
	insertplant NUMERIC(15, 4) NULL,
	multimediaeditorial NUMERIC(15, 4) NULL,
	multimedialproduction NUMERIC(15, 4) NULL,
	offset NUMERIC(15, 4) NULL,
	other NUMERIC(15, 4) NULL,
	photo NUMERIC(15, 4) NULL,
	pod NUMERIC(15, 4) NULL,
	proofreading NUMERIC(15, 4) NULL,
	proofsblues NUMERIC(15, 4) NULL,
	research NUMERIC(15, 4) NULL,
	seperationsscansfilms NUMERIC(15, 4) NULL,
	textplant NUMERIC(15, 4) NULL,
	textdesign NUMERIC(15, 4) NULL,
	tolerance VARCHAR(3) NULL,
	estunitcost NUMERIC(15, 4) NULL,
	estmfrtot NUMERIC(15, 4) NULL,
	delcomplete VARCHAR(1) NULL,
	completeqty VARCHAR(1) NULL,
	completeqtydate VARCHAR(10) NULL,
	completeval VARCHAR(1) NULL,
	completevaldate VARCHAR(10) NULL,
	pocomment VARCHAR(42) NULL,
	ppestcost25 NUMERIC(15, 4) NULL,
	ppestcost26 NUMERIC(15, 4) NULL,
	ppestcost27 NUMERIC(15, 4) NULL,
	ppestcost28 NUMERIC(15, 4) NULL,
	ppestcost29 NUMERIC(15, 4) NULL,
	ppestcost30 NUMERIC(15, 4) NULL,
	oriestcost22 NUMERIC(15, 4) NULL,
	oriestcost23 NUMERIC(15, 4) NULL,
	oriestcost24 NUMERIC(15, 4) NULL,
	oriestcost25 NUMERIC(15, 4) NULL,
	oriestcost26 NUMERIC(15, 4) NULL,
	oriestcost27 NUMERIC(15, 4) NULL,
	oriestcost28 NUMERIC(15, 4) NULL,
	oriestcost29 NUMERIC(15, 4) NULL,
	oriestcost30 NUMERIC(15, 4) NULL,
   processdate datetime NOT NULL,
	statuscode VARCHAR(2) NULL,
	estprepresstotal VARCHAR(10) NULL
)
GO



create index pofeedouthistory_p1 
    ON dbo.pofeedouthistory (isbn10, printingnumber, ponumber, processdate)
GO

GRANT ALL ON dbo.pofeedouthistory TO PUBLIC
GO




