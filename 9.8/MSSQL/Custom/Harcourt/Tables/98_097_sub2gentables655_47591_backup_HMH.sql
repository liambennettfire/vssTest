SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

BEGIN
	DECLARE 
		@v_count1 int,
		@v_count2 INT

	CREATE TABLE dbo.sub2gentables_bkup_10022017(
	tableid int NOT NULL,
	datacode int NOT NULL,
	datasubcode int NOT NULL,
	datasub2code int NOT NULL,
	datadesc varchar(120) NULL,
	deletestatus varchar(1) NULL,
	applid varchar(2) NULL,
	sortorder int NULL,
	tablemnemonic varchar(40) NULL,
	alldivisionsind tinyint NULL,
	externalcode varchar(30) NULL,
	datadescshort varchar(20) NULL,
	lastuserid varchar(30) NULL,
	lastmaintdate datetime NULL,
	numericdesc1 float NULL,
	numericdesc2 float NULL,
	bisacdatacode varchar(25) NULL,
	sub2gen1ind tinyint NULL,
	sub2gen2ind tinyint NULL,
	acceptedbyeloquenceind int NULL,
	exporteloquenceind int NULL,
	lockbyqsiind int NULL,
	lockbyeloquenceind int NULL,
	eloquencefieldtag varchar(25) NULL,
	alternatedesc1 varchar(255) NULL,
	alternatedesc2 varchar(255) NULL,
	qsicode int NULL)

	 INSERT INTO sub2gentables_bkup_10022017 (tableid,datacode,datasubcode,datasub2code,datadesc,deletestatus,applid,sortorder,tablemnemonic,alldivisionsind,	externalcode,	datadescshort,	lastuserid,	lastmaintdate,	numericdesc1 ,
		numericdesc2 ,	bisacdatacode,	sub2gen1ind ,	sub2gen2ind ,	acceptedbyeloquenceind ,	exporteloquenceind ,	lockbyqsiind ,	lockbyeloquenceind ,	eloquencefieldtag,	alternatedesc1,
		alternatedesc2,	qsicode )
		SELECT tableid,datacode,datasubcode,datasub2code,datadesc,deletestatus,applid,sortorder,tablemnemonic,alldivisionsind,	externalcode,	datadescshort,	lastuserid,	lastmaintdate,	numericdesc1 ,
		numericdesc2 ,	bisacdatacode,	sub2gen1ind ,	sub2gen2ind ,	acceptedbyeloquenceind ,	exporteloquenceind ,	lockbyqsiind ,	lockbyeloquenceind ,	eloquencefieldtag,	alternatedesc1,
		alternatedesc2,	qsicode
		FROM sub2gentables 
		

	  SELECT @v_count1 = COUNT(*)
	  FROM sub2gentables
	
	  SELECT @v_count2 = COUNT(*)
	  FROM sub2gentables_bkup_10022017
	
	  /** Make sure insert into the temp table succeeded **/
	  IF @v_count1 <> @v_count2
		 BEGIN
			SELECT 'ERROR !!! Data did not get copied properly to temp table !!!!'
		 END
	  ELSE
		 BEGIN
			SELECT 'Script completed successfully'
		 END

END
GO


