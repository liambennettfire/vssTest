IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_update_assetelement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_update_assetelement]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--- *********************************************************************
-- modifed April 2018 - CToolan- added SQL to limit updates to set metadata asset status to "Not Distributed" when element is inserted.  See NS case 49188
-- ====================================================================


CREATE PROCEDURE [dbo].[qcs_update_assetelement](
    @assetId uniqueidentifier,
    @productId uniqueidentifier,
    @assetTypeTag varchar(25),
    @assetStatusTag varchar(25),
    @description varchar(255),
    @updatedBy varchar(50),
    @updatedAt datetime,
    @jobkey int = 0)
AS
BEGIN
	SET XACT_ABORT ON
	
	DECLARE @assetIdStr varchar(50)
	DECLARE @elementKey int
	DECLARE @elementCount int
	DECLARE @statusCode int
	DECLARE @productIdStr varchar(50)
	DECLARE @bookKey int
	DECLARE @numberKey int
	DECLARE @typeCode int
	DECLARE @productIdCode int
	DECLARE @cspartnerstatuscode int
	
	SET @assetIdStr = CAST(@assetId AS varchar(50))
	SET @productIdStr = CAST(@productId AS varchar(50))
    
	SELECT TOP 1 @statusCode = datacode FROM gentables WHERE tableid = 593 /* ElementStatus */ AND eloquencefieldtag = @assetStatusTag
	SELECT TOP 1 @bookKey = bookkey FROM isbn WHERE cloudproductid = @productIdStr
	SELECT TOP 1 @typeCode = datacode FROM gentables WHERE tableid = 287 /* ElementType */ AND eloquencefieldtag = @assetTypeTag
	SELECT TOP 1 @productIdCode = datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/

-- added April 2018 for sync improvements. See NS case 49188
    SELECT @cspartnerstatuscode = datacode from gentables where tableid = 639 and qsicode=1 -- not distributed
        
	IF @statusCode IS NULL BEGIN
		RAISERROR('Asset Status Code could not be found for %s', 16, 1, @assetStatusTag)
		RETURN
	END

	IF @bookKey IS NULL OR @bookKey <= 0 BEGIN
		RAISERROR('No Asset could be created for Asset id %s.  No matching title could be found for Product id %s',
				  16, 1, @assetIdStr, @productIdStr)
		RETURN
	END
            
	IF @typeCode IS NULL BEGIN
		RAISERROR('Asset Type Code could not be found for %s', 16, 1, @assetTypeTag)
		RETURN
	END

	IF @productIdCode IS NULL BEGIN
		RAISERROR('Product Id Type Code could not be found', 16, 1)
		RETURN
	END

	SELECT TOP 1 @elementKey = elementkey FROM taqproductnumbers WHERE productnumber = @assetIdStr

	IF @elementKey IS NULL BEGIN
		SELECT TOP 1 @elementKey = taqelementkey
		FROM taqprojectelement
		WHERE
			bookkey = @bookKey AND
			taqelementkey = @typeCode
	END
	
	IF @elementKey IS NULL BEGIN
		EXEC get_next_key @updatedBy, @elementKey OUTPUT     
		EXEC get_next_key @updatedBy, @numberKey OUTPUT

		/* To prevent duplicates under high concurrency
		   only insert if the rows in question are not there */
		BEGIN TRAN
		INSERT INTO taqprojectelement(
			taqelementkey, 
			taqelementtypecode, 
			taqelementtypesubcode, 
			bookkey, 
			taqelementdesc, 
			elementstatus, 
			printingkey, 
			lastuserid, 
			lastmaintdate, 
			cspartnerstatuscode,
			latestqsijobkey)
		SELECT
			@elementKey, 
			@typeCode, 
			0, 
			@bookKey, 
			@description, 
			@statusCode, 
			1,
			@updatedBy, 
			GETDATE(), 
			@cspartnerstatuscode,  -- case 49188
			@jobkey
		WHERE 
			NOT EXISTS(
				SELECT *
				FROM taqproductnumbers
				WHERE productnumber=@assetIdStr) AND
			NOT EXISTS(
				SELECT *
				FROM taqprojectelement
				WHERE 
					bookkey=@bookkey AND
					taqelementkey=@typeCode)
					
		IF (@@ROWCOUNT = 0)
			RETURN

		INSERT INTO taqproductnumbers(
			productnumberkey, 
			elementkey, 
			productidcode, 
			productnumber, 
			sortorder, 
			lastuserid, 
			lastmaintdate)
		VALUES (
			@numberKey, 
			@elementKey, 
			@productIdCode, 
			@assetIdStr, 
			1, 
			@updatedBy, 
			GETDATE())
		COMMIT TRAN
	END
	ELSE BEGIN
		UPDATE taqprojectelement
		SET elementstatus = @statusCode, 
			taqelementdesc = @description,
			lastuserid = @updatedBy, 
			lastmaintdate = GETDATE(), 
			latestqsijobkey = CASE WHEN @jobkey > 0 THEN @jobkey ELSE latestqsijobkey END 
		WHERE taqelementkey = @elementKey
	END
	
	RETURN @bookKey
END
GO	

GRANT EXEC ON qcs_update_assetelement TO PUBLIC
GO
