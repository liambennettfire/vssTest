SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

BEGIN
	DECLARE 
		@v_count1 int,
		@v_count2 INT

	CREATE TABLE dbo.territoryrightcountries_bkup_092717(
		territoryrightskey int NOT NULL,
		countrycode int NOT NULL,
		itemtype int NULL,
		taqprojectkey int NULL,
		rightskey int NULL,
		bookkey int NULL,
		forsaleind tinyint NULL,
		contractexclusiveind tinyint NULL,
		nonexclusivesubrightsoldind tinyint NULL,
		currentexclusiveind tinyint NULL,
		exclusivesubrightsoldind tinyint NULL,
		lastuserid varchar(30) NULL,
		lastmaintdate datetime NULL)

	 INSERT INTO territoryrightcountries_bkup_092717 (territoryrightskey,countrycode,itemtype,taqprojectkey,rightskey,bookkey,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,
		currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate)
		SELECT territoryrightskey,countrycode,itemtype,taqprojectkey,rightskey,bookkey,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,
		currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate
		FROM territoryrightcountries

	  SELECT @v_count1 = COUNT(*)
	  FROM territoryrightcountries
	
	  SELECT @v_count2 = COUNT(*)
	  FROM territoryrightcountries_bkup_092717
	
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


