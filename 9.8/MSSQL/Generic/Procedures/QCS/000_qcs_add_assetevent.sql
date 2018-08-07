IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_add_assetevent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_add_assetevent]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[qcs_add_assetevent](@assetId uniqueidentifier, @statusTag varchar(25), @updatedBy varchar(50), @updatedAt datetime, @metadata bit = 0)
AS
/***********************************************************************************
**    Change History
************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------
**   04/06/2016   Kusum        36178     Keys Table at S&S Getting Close to Max Value     
*************************************************************************************/
BEGIN
	DECLARE @elementKey int
	DECLARE @dateTypeCode int
	DECLARE @taskKey int
	DECLARE @bookKey int
	DECLARE @assetIdStr varchar(50)
	DECLARE @elementKeyStr varchar(25)

	SET @assetIdStr = CAST(@assetId AS varchar(50))
	
	SELECT @elementKey = elementKey FROM taqproductnumbers WHERE productnumber = CAST(@assetId AS varchar(50))
	IF @elementKey IS NULL BEGIN
		RAISERROR('Cannot find element for Asset Id %s', 16, 1, @assetIdStr)
		RETURN
	END

	SELECT @bookKey = bookkey FROM taqprojectelement WHERE taqelementkey = @elementKey
	IF @bookKey IS NULL BEGIN
		SET @elementKeyStr = CAST(@elementKey AS varchar(25))
		RAISERROR('Cannot find book for Element Key %s based on Asset Id %s', 16, 1, @elementKeyStr, @assetIdStr)
		RETURN
	END
	
	SELECT 
		@dateTypeCode = datetypecode
	FROM
		datetype d,
		gentables t,
		gentables s
	WHERE
		d.cstransactioncode = t.datacode AND
		d.csstatuscode = s.datacode AND
		t.tableid = 575 /* TaskTrackingType */ AND
		t.qsicode = 1 AND
		t.deletestatus = 'N' AND
		s.tableid = 593 /* ElementStatus */ AND
		s.eloquencefieldtag = @statusTag AND
		s.deletestatus = 'N'

	IF @dateTypeCode IS NULL BEGIN
		RAISERROR('There is no valid datetype for Asset Status Tag %s.', 16, 1, @statusTag)
		RETURN
	END
		
  print '@elementKey = ' + cast(@elementKey as varchar)
  print '@dateTypeCode = ' + cast(@dateTypeCode as varchar)
  
	IF @metadata = 1 AND 
		EXISTS (SELECT TOP 1 taqtaskkey 
		        FROM taqprojecttask 
		        WHERE taqelementkey=@elementKey and datetypecode=@dateTypeCode ) 
  BEGIN
			print 'update'
		UPDATE taqprojecttask
		SET datetypecode = @dateTypeCode,
			activedate = @updatedAt,
			lastmaintdate = @updatedAt
		WHERE taqelementkey = @elementKey
		  AND datetypecode = @dateTypeCode
	END
	ELSE BEGIN
			print 'insert'
		EXEC get_next_key 'taqprojecttask', @taskKey OUTPUT
		INSERT INTO taqprojecttask (
			taqtaskkey, 
			datetypecode, 
			taqelementkey, 
			bookkey, 
			activedate, 
			originaldate, 
			actualind, 
			printingkey,
			lastmaintdate, 
			lastuserid)
		VALUES (
			@taskKey,
			@dateTypeCode,
			@elementKey,
			@bookKey,
			@updatedAt,
			@updatedAt,
			1,
			1,
			@updatedAt,
			@updatedBy)
	END
END
GO

GRANT EXEC ON qcs_add_assetevent TO PUBLIC
GO
