IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_execute_syncpostprocess_for_book]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_execute_syncpostprocess_for_book]
GO

-- ====================================================================
-- Author:		Andy Day
-- Create date: 11/27/2012
-- Description:	Run any sync post processing on an updated book.
-- ====================================================================
CREATE PROCEDURE qcs_execute_syncpostprocess_for_book @bookkey int, @partnertag int = 0
AS
BEGIN
	-- Execute post process scripts here
	DECLARE @error_code INT
	DECLARE @error_desc VARCHAR(2000)
	
	EXEC qcs_verify_taqprojectelementpartner @bookkey
	EXEC qtitle_set_cspartnerstatuses_on_title @bookkey, 'Cloud', @error_code OUTPUT, @error_desc OUTPUT, @partnertag
	
	IF @error_code = -1
	BEGIN
		RAISERROR(@error_desc, 16, 1)
		RETURN
	END
	
    RETURN
    
END
GO

GRANT EXEC ON qcs_execute_syncpostprocess_for_book TO PUBLIC
GO