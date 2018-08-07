if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[rpt_get_role_multiple]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[rpt_get_role_multiple]
GO
CREATE FUNCTION [dbo].[rpt_get_role_multiple](
	@i_bookkey	INT,
	@i_rolecode	INT,
	@v_column	VARCHAR(1),
	@seperator  VARCHAR(1),
	@appendtoName varchar(50)
)
RETURNS VARCHAR(512)
AS
/*  	Parameter Options
		@i_bookkey

		@i_rolecode
			RoleType from gentables

		@v_column
			D = returns the display name
			F = returns the first name
			L = returns the middle name
			S = returns the short name (temporarily returns last name due to version issue)
			E = returns the external code 1
			C = Complete Name (nameabbrev + firstname + mi + lastname + suffix)
												
		@seperator
			seperator to be used btw role names if multiples records exist.
			/,|,;, etc...
		@appendtoName
			a phrase that will get appended after each name
			e.g. If you pass '(rep)', (rep) will be appended after each name : John Doe (rep)
			added this parameter for a specific client. pass '' if it does not apply.

*/


BEGIN

DECLARE @i_titlefetchstatus int
DECLARE @globalcontactkey int
DECLARE @Return varchar(512)

SELECT @Return = ''


DECLARE c_role_type CURSOR LOCAL SCROLL FOR
		
			SELECT bc.globalcontactkey
			FROM bookcontactrole br
			JOIN bookcontact bc
			ON br.bookcontactkey = bc.bookcontactkey
			WHERE bc.bookkey = @i_bookkey
			AND br.rolecode = @i_rolecode 
		
		FOR READ ONLY
				
		OPEN c_role_type 

		FETCH NEXT FROM c_role_type 
			INTO @globalcontactkey 


		select  @i_titlefetchstatus  = @@FETCH_STATUS

		 while (@i_titlefetchstatus >-1 )
			begin
				IF (@i_titlefetchstatus <>-2) 
				begin
					DECLARE @name varchar(80)
					SET @name = ''

					SELECT @Name = [dbo].[rpt_get_contact_name](@globalcontactkey, @v_column)
					IF LEN(@Name) > 0
						BEGIN
							IF LEN(@appendtoName) > 0
								BEGIN
									SET @return = @return + @name + ' ' + @appendtoName + ' ' + @seperator + ' '
								END 
							ELSE
								BEGIN
									SET @return = @return + @name + ' ' + @seperator + ' '
								END
						END
				end
				FETCH NEXT FROM c_role_type
					INTO @globalcontactkey 
						select  @i_titlefetchstatus  = @@FETCH_STATUS
			end
				

close c_role_type
deallocate c_role_type

IF LEN(@return) > 0 
	BEGIN
		SELECT @return = LTRIM(RTRIM(@Return))
		Select @Return = LTRIM(RTRIM(SUBSTRING(@return, 1, LEN(@Return) -1))) --Parse out last seperator
	END

RETURN @RETURN
END