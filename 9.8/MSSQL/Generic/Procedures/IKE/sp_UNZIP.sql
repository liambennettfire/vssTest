SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: sp_UNZIP
**  Desc: IKE unzip file
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
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[sp_UNZIP]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[sp_UNZIP]
GO

-- SAMPLE USAGE:
-- exec dbo.sp_UNZIP 'C:\temp\test.zip','C:\temp\1\'

CREATE PROCEDURE dbo.sp_UNZIP (
	@SOURCE VARCHAR(8000)
	,@DEST VARCHAR(8000)
	,@ZIPEXE VARCHAR(8000) = '"C:\Program Files\7-zip\7z"'
	,@Result INT = 0 OUTPUT
	,@ResultMsg VARCHAR(8000) = '' OUTPUT
	)
AS
BEGIN
	DECLARE @WINZIP VARCHAR(8000)
	DECLARE @ResultTable TABLE (result varchar(500))

	SET @WINZIP = @ZIPEXE + ' e ' + @Source + ' -o' + @DEST + ' -aoa'
	--7z x test.zip -aoa

	--PRINT @WINZIP
	INSERT @ResultTable
	EXEC @Result = master.dbo.XP_CMDSHELL @Winzip--,no_output
	IF @Result<>0
	BEGIN
		delete from @ResultTable where result is null or result = '7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18'
		select @ResultMsg= COALESCE(@ResultMsg + char(13)+ char(10), '') + result from @ResultTable
	END
END

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[sp_UNZIP]
	TO PUBLIC
GO