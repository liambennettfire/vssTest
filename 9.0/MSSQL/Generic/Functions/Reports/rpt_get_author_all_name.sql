
/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_all_name]    Script Date: 03/24/2009 11:49:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_all_name') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_author_all_name
GO
CREATE FUNCTION [dbo].[rpt_get_author_all_name] 
			(@i_bookkey	INT,
			@i_numberofauthors	INT,
			@i_type		INT,
			@v_name varchar (1),
			@v_separator varchar (1))

RETURNS	VARCHAR(120)

/*  The purpose of the rpt_get_author_all_name function is to return names for 
each of the first n authors based upon the bookkey passed and number requested. 
The names wil be separated as a list with the separator specified
This functions uses the globalcontact table.

	PARAMETER OPTIONS

		@i_numberofauthors - number from 1-50 - the number of authors desired in the list. This will allow the user
to limit the number of authors - i.e. they may only want the first 4 authors in the returned string to 
limit the size.

		@i_type = roltype codes to include
			0 = Include all Contributor Role types
			12 = Include just Author Role types (pulls from gentables.tableid=134 for roletypecode

		@v_name = author name field (if corporate indicator = 1, then any options will always pull the lastname)
			D = Display Name
			C = Complete Name (nameabbrev + firstname + mi + lastname + suffix)
			F = First Name
			M = Middle Name
			L = Last Name
			S = Suffix
		
		@v_separator = a single character to be added between multiple names i.e. ';' or ','.
		A single space will be added after the separator in the final result
		i.e. 'LastName1; LastName2; LastName3'

RETURN = varchar (8000)

EXAMPLE:
select dbo.rpt_get_author_all_name (b.bookkey, 5,0,'L', ';') as allauthorlastname
from book

REVISIONS:
1/8/2009 written by Doug Lessing
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @v_namedesc		VARCHAR(8000)
	DECLARE @i_order		int

/* parameter validations */
if @i_numberofauthors is null or @i_numberofauthors =0 or @i_numberofauthors > 50
	begin
	select @RETURN = 'invalid parameter number of authors: valid = 1-50'
	end

if @v_name not in ('D', 'C', 'F', 'M', 'L', 'S','X' ,'Y')
	begin
	select @RETURN = 'invalid parameter name type: valid = D, C, F, M, L, S, X, Y'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

if @v_separator is null
	begin
	select @v_separator = ''
	end


	select @i_order =1
	while @i_order <= @i_numberofauthors
	begin

		select @v_namedesc = dbo.rpt_get_author (@i_bookkey,@i_order,@i_type,@v_name)
		
		if len (@v_namedesc) > 0
			begin
				IF LEN(@v_desc) > 0
					BEGIN
						SELECT @v_desc = @v_desc + @v_separator + ' ' + @v_namedesc
					END
				ELSE
					BEGIN
						SELECT @v_desc =  @v_namedesc
					END
		END
		
		select @i_order = @i_order + 1

end /*end while */

IF LEN(@v_desc) > 0
	BEGIN
		SELECT @RETURN = LTRIM(RTRIM(@v_desc))
	END
ELSE
	BEGIN
		SELECT @RETURN = ''
	END





RETURN @RETURN


END
go
Grant All on dbo.rpt_get_author_all_name to Public
go