if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_date') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_date
GO

CREATE FUNCTION dbo.rpt_get_date
		(@i_bookkey	INT,
		@i_printingkey	INT,
		@i_datetype	INT,
	@c_EstActBest char (1))

RETURNS DATETIME

/*	

Select * FROM bookdates
	
*/	

AS

BEGIN

	DECLARE @RETURN		DATETIME
	DECLARE @activedate	DATETIME
	DECLARE @estdate	DATETIME
	DECLARE @bestdate	DATETIME

	SELECT @activedate = activedate,
			@estdate = estdate,
			@bestdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = @i_datetype


if @c_EstActBest = 'B' /* Return Best DATE */
begin
	SET @RETURN = @bestdate
END

if @c_EstActBest = 'E' /* Return EST DATE */
begin
	SET @RETURN = @estdate
END

if @c_EstActBest = 'A' /* Return EST DATE */
begin
	SET @RETURN = @activedate
END

RETURN @RETURN


END







