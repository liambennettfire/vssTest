/******************************************************************************
**  Name: udf_IsValidHtml
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_IsValidHtml]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_IsValidHtml]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_IsValidHtml] (@szString VARCHAR(max))
RETURNS BIT
AS
BEGIN
	DECLARE @iLenWithoutLT INT
	DECLARE @iLenWithoutGT INT
	DECLARE @IsValidHtml BIT=0
	
	IF @szString IS NULL RETURN 0
	SET @iLenWithoutLT=LEN(REPLACE(@szString,'<',''))
	SET @iLenWithoutGT=LEN(REPLACE(@szString,'>',''))
	
	IF @iLenWithoutLT=@iLenWithoutGT SET @IsValidHtml=1
	RETURN @IsValidHtml
	
END
