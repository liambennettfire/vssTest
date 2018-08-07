/******************************************************************************
**  Name: udf_IsHtml
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
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_IsHtml]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_IsHtml]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_IsHtml] (@szString VARCHAR(max))
RETURNS BIT
AS
BEGIN
	IF @szString IS NULL RETURN 0
	RETURN 
		CASE 
			WHEN charindex('<DIV', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<HTML', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<HEAD', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<P', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<B', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<I', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('<U', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('</', upper(@szString), 1) > 0 THEN 1
			WHEN charindex('&#', upper(@szString), 1) > 0 THEN 1
			ELSE 0
		END
END
