IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_verify_taqprojectelementpartner]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_verify_taqprojectelementpartner]
GO

-- =============================================
-- Author:		Jason F.
-- Create date: 12/6/2012
-- Description:	Check if bookkey,assetkey,partnercontactkey exists on taqprojectelementpartner
-- =============================================
CREATE PROCEDURE qcs_verify_taqprojectelementpartner 
	@i_bookkey int
AS
BEGIN

DECLARE @v_curDate datetime,
				@v_res int,
				@v_error int

SET @v_curDate = GetDate()

BEGIN TRAN

EXEC @v_res = sp_getapplock @Resource = 'qcs_verify_taqprojectelementpartner', @LockOwner = 'Transaction', @LockMode = 'Exclusive', @LockTimeout = 10000
IF @v_res >= 0
BEGIN
	-- Insert a row into taqprojectelementpartner if bookkey,assetkey,partnercontactkey doesn't exist in csdistribution	
	INSERT INTO taqprojectelementpartner (bookkey,assetkey,partnercontactkey,resendind,cspartnerstatuscode,lastuserid,lastmaintdate)
	SELECT DISTINCT bookkey, assetkey, partnercontactkey, 1 AS resendind, 1 AS cspartnerstatuscode, 'Cloud' AS lastuserid, @v_curDate AS lastmaintdate FROM csdistribution
	WHERE bookkey = @i_bookkey 
	EXCEPT
	SELECT DISTINCT bookkey, assetkey, partnercontactkey, 1 AS resendind, 1 AS cspartnerstatuscode, 'Cloud' AS lastuserid, @v_curDate AS lastmaintdate FROM taqprojectelementpartner
	WHERE bookkey = @i_bookkey 
	
	SELECT @v_error = @@ERROR
	
	EXEC @v_res = sp_releaseapplock @Resource = 'qcs_verify_taqprojectelementpartner'
	
	IF @v_error <> 0
	BEGIN
		ROLLBACK TRAN
		RETURN
	END
END

COMMIT TRAN
	
END
GO
