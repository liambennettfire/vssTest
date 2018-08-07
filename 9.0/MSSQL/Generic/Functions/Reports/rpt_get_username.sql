SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_username') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_username
GO

create FUNCTION [dbo].[rpt_get_username] 
			(@v_userid varchar (100), @v_name varchar (10))

RETURNS	VARCHAR(120)

/*  The purpose of the rpt_get_username function is to return the name of  
the user from the qsiusers table based on the passed lastuserid.  This will return the
format requested. If userid is not found on the users table, the userid will be passed
back as a default


	PARAMETER OPTIONS

		@v_name = 
			C (complete)= First Name + Last Name
			R (reverse) = Last Name, First Name
			F = First Name
			L = Last Name


RETURN = varchar (8000)

EXAMPLE:
select dbo.rpt_get_username (lastuserid,'D') as userlastname
from titlehistory

REVISIONS:
6/25/2009 written by Doug Lessing
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(8000)
	DECLARE @v_desc			VARCHAR(8000)
	DECLARE @firstname		VARCHAR(255)
	DECLARE @lastname		VARCHAR(255)


/* parameter validations */

if @v_name not in ('C', 'F', 'R', 'L')
	begin
	select @RETURN = 'invalid parameter name type: valid = C, R, F, L'
	end


/** exit with error message if parameters not accepted **/
if len (@return) > 0
	begin
	return @return
	end

select @firstname=''
select @lastname=''

select @firstname = isnull (firstname,''), @lastname = isnull (lastname,'') 
from qsiusers 
where userid=@v_userid

IF @v_name = 'C' 
	BEGIN
		if @firstname  = '' and @lastname = '' /* both are empty, send default */
		begin
			SELECT @v_desc = @v_userid
		end
		else 
		begin
			SELECT @v_desc = ltrim (rtrim (@firstname + ' ' + @lastname))
		end
	end


ELSE IF @v_name = 'R' 
	BEGIN
		if @firstname  = '' and @lastname = '' /* both are empty, send default */
		begin
			SELECT @v_desc = @v_userid
		end
		else 
		begin
			if @firstname <> ''
			begin
				SELECT @v_desc = ltrim (rtrim (@lastname + ', ' +@firstname))
			end
			else /*No first name, return last name */
			begin
				SELECT @v_desc = @lastname
			end
		end /* end Else */
	end /* end if @v_name*/


ELSE IF @v_name = 'F' 
	BEGIN
		if @firstname  = ''  /* first name empty, send default */
		begin
			SELECT @v_desc = @v_userid
		end
		else 
		begin
			SELECT @v_desc = @firstname
		end
	end

ELSE IF @v_name = 'L' 
	BEGIN
		if @lastname  = ''  /* last name empty, send default */
		begin
			SELECT @v_desc = @v_userid
		end
		else 
		begin
			SELECT @v_desc = @lastname
		end
	end

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
grant execute on rpt_get_username to public
go