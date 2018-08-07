SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: sp_ZIP
**  Desc: IKE zip file
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
		WHERE id = object_id(N'[dbo].[sp_ZIP]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[sp_ZIP]
GO

CREATE PROCEDURE dbo.sp_ZIP (
	@SOURCE VARCHAR(8000)
	,@DEST VARCHAR(8000)
	,@ZIPEXE VARCHAR(8000)='"C:\Program Files\7-zip\7z"'
	,@Result INT = 0 OUTPUT
	,@ResultMsg VARCHAR(8000) = '' OUTPUT
	)
AS
BEGIN
	DECLARE @WINZIP VARCHAR(8000)
	DECLARE @ZipName VARCHAR(8000)
	DECLARE @DateConvert SMALLDATETIME
	DECLARE @ResultTable TABLE (result varchar(500))

	SET @DateConvert = GETDATE()
	--Declare the current date time so that 
	--conversions happen at the same date time 
	SET @ZipName = CONVERT(VARCHAR(10), @DateConvert, 112) +
		--Add the date to the file name  
		SUBSTRING(CONVERT(VARCHAR(10), @DateConvert, 108), 1, 2) +
		--add the hour to the file name 
		SUBSTRING(Convert(VARCHAR(10), @DateConvert, 108), 4, 2) +
		--add the minute to the file name + 
		'.7z'
	SET @Dest = @ZIPEXE + ' a ' + @DEST + '_' +@ZipName
	SET @WINZIP = @Dest + ' ' + @Source + ' '

	--PRINT @WINZIP
	INSERT @ResultTable
	EXEC @Result = master.dbo.XP_CMDSHELL @Winzip--, no_output
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
	ON dbo.[sp_ZIP]
	TO PUBLIC
GO