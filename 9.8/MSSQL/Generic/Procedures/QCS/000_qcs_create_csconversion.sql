IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_create_csconversion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_create_csconversion]
GO

CREATE PROCEDURE [dbo].[qcs_create_csconversion](
	@transactionKey int,
	@sourceAssetKey int,
	@targetAssetKey int,
	@converter int,
	@tag varchar(25),
	@updatedBy varchar(40),
	@updatedAt datetime)
AS
BEGIN
/*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   07/02/2018   Colman		   TM-570
*******************************************************************************/
	DECLARE @statusCode int
	DECLARE @dateTypeCode int
	DECLARE @taskKey int
	DECLARE @roleCode int
	DECLARE @globalcontactkey int
	DECLARE @targetbookkey int

	SELECT @dateTypeCode=datetypecode FROM datetype WHERE qsicode=13
	
  SET @roleCode = 0
  SET @globalcontactkey = 0
  IF @converter > 0 BEGIN
	  SELECT @globalcontactkey = globalcontactkey FROM globalcontact WHERE partnerkey = @converter
	  
	  IF @globalcontactkey > 0 BEGIN
	    SELECT @roleCode = datacode FROM gentables WHERE tableid=285 AND qsicode=13  -- Conversion House
	  END
	END

  SELECT top 1 @targetbookkey = bookkey FROM taqprojectelement WHERE taqelementkey = @targetAssetKey and printingkey = 1

	SELECT @statusCode=datacode FROM gentables WHERE tableid=579 AND qsicode=1
	
	IF @statusCode IS NULL BEGIN
		RAISERROR('Cannot find the Conversion Status of Requested in the user tables.', 16, 1)
		RETURN
	END
	IF @dateTypeCode IS NULL BEGIN
		RAISERROR('Cannot find the Request Asset Conversion datetype.', 16, 1)
		RETURN
	END

	INSERT INTO csconversion(
		transactionkey,
		sourceassetkey,
		targetassetkey,
		converter,
		transactiontag,
		statuscode,
		lastuserid,
		lastmaintdate)
	VALUES (
		@transactionKey,
		@sourceAssetKey,
		@targetAssetKey,
		@globalcontactkey,
		@tag,
		@statusCode,
		@updatedBy,
		@updatedAt)

	IF @@ERROR <> 0
		RETURN	
		
	EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT
			
	INSERT INTO taqprojecttask (
		taqtaskkey, 
		datetypecode,
		taqelementkey, 
		globalcontactkey, 
		rolecode,
		bookkey, 
		activedate, 
		originaldate, 
		actualind, 
		lastmaintdate, 
		lastuserid,
		printingkey,
		transactionkey)
	VALUES (
		@taskKey,
		@dateTypeCode,
		@targetAssetKey,
		@globalcontactkey,
		@roleCode,
		@targetbookkey,
		@updatedAt,
		@updatedAt,
		0,
		@updatedAt,
		@updatedBy,
		1,
		@transactionKey)
		
END
GO

GRANT EXEC ON qcs_create_csconversion TO PUBLIC
GO
