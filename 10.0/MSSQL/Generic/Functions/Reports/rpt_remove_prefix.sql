SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF exists (select * from dbo.sysobjects where id = object_id(N'rpt_remove_prefix') )
	DROP FUNCTION rpt_remove_prefix
GO

create FUNCTION rpt_remove_prefix (	@in_string	varchar (255))
	RETURNS VARCHAR(255)

/*	Removes leading articles such as The, An, A from the passed string
	History:
	Created by DSL 7/7/09
	Modified by DSL 7/9/09 to initialize the out_string to In_string
*/
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @out_string 	VARCHAR (255)

	/* Initialize the out_string to the in_string */
	select @out_string = substring(@in_string, 1, 255)

	if substring(@in_string, 1, 4) = 'The '
	begin
		select @out_string = substring(@in_string, 5, 250)
	end

	if substring(@in_string, 1, 3) = 'An '
	begin
		select @out_string = substring(@in_string, 4, 251)
	end

	if substring(@in_string, 1, 2) = 'A '
	begin
		select @out_string = substring(@in_string, 3, 252)
	end

	select @RETURN = @out_string
  RETURN @RETURN
END
go

grant execute on rpt_remove_prefix to public
go