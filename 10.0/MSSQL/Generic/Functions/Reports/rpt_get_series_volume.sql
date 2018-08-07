SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_series_volume') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_series_volume
GO

CREATE FUNCTION rpt_get_series_volume (@i_bookkey	INT)
RETURNS VARCHAR(5)

/*	The purpose of the get_Series Volume is to pull the volume number in the series and return it if it exists.  If it doesn't, then return a space
*/	
AS
BEGIN

	DECLARE @RETURN				VARCHAR(5)
	DECLARE @v_desc				VARCHAR(5)
	DECLARE @i_volumenumber			INT
	
	SELECT @i_volumenumber = volumenumber
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey and volumenumber <> 0


	IF @i_volumenumber > 0
	BEGIN
		SELECT @RETURN = CAST(@i_volumenumber as varchar(5))
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END

	RETURN @RETURN
END
go

grant execute on rpt_get_series_volume to public
go