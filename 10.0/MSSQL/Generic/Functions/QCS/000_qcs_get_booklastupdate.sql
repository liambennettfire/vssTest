SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'qcs_get_booklastupdate')
DROP FUNCTION [dbo].[qcs_get_booklastupdate]
GO

CREATE FUNCTION [dbo].[qcs_get_booklastupdate] (@bookkey int)
RETURNS DATETIME
AS
BEGIN
	/* GET the Maximum lastmaintdate from titlehistory*/
	DECLARE @maxdate DATETIME

	SELECT TOP 1 @maxdate=lastmaintdate FROM titlehistory WHERE bookkey=@bookkey AND printingkey = 1 order by lastmaintdate desc

	RETURN @maxdate

END
GO