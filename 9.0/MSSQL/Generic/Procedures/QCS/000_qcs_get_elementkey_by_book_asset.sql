IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_elementkey_by_book_asset]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_elementkey_by_book_asset]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Dustin Miller
-- Create date: July 24, 2013
-- Description:	
-- =============================================
CREATE PROCEDURE [qcs_get_elementkey_by_book_asset] 
    @i_bookkey int,
    @i_assettype int,
    @o_error_code integer output,
		@o_error_desc varchar(2000) output
AS
BEGIN

DECLARE @v_elementkey int,
				@v_metadatacode int,
				@v_error int

SET @o_error_code = 0
SET @o_error_desc = ''

SELECT TOP 1 @v_elementkey = e.taqelementkey
FROM taqprojectelement AS e
WHERE e.bookkey = @i_bookkey
	AND e.taqelementtypecode = @i_assettype
	
IF @v_elementkey IS NULL
BEGIN
	SELECT @v_metadatacode = datacode
	FROM gentables
	WHERE tableid = 287
		AND qsicode = 3
		
	IF @i_assettype = @v_metadatacode
	BEGIN
		SET @v_elementkey = 0
	END
END

SELECT @v_elementkey as elementkey

END

GO

GRANT EXEC ON qcs_get_elementkey_by_book_asset TO PUBLIC
GO