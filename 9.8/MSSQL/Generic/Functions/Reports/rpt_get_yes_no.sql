SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_yes_no') and xtype in (N'FN', N'IF', N'TF'))
  drop function rpt_get_yes_no
GO


CREATE FUNCTION rpt_get_yes_no (@i_yesnoind	INT)
	RETURNS VARCHAR(80)
AS
/*  	Parameter Options
		@i_yesnoind (zero or one)

Returns yes or no, or '' if NULL
								*/
BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_desc			VARCHAR(80)

	if @i_yesnoind = 1
    begin
		SELECT @v_desc = 'yes'
    end
	else
	begin
		SELECT @v_desc = 'no'
	end
	
	IF LEN(@v_desc)> 0
	BEGIN
		SELECT @RETURN = @v_desc
	END
	ELSE
	BEGIN
		SELECT @RETURN = ''
	END

	RETURN @RETURN
END
go

grant execute on rpt_get_yes_no to public
go
