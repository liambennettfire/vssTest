SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.globalcontact_displayname') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.globalcontact_displayname
end
go

CREATE PROCEDURE [dbo].globalcontact_displayname (
@v_individualind tinyint,  
@v_lastname varchar(100), 
@v_firstname varchar(100), 
@v_middlename varchar(100), 
@v_suffix varchar(75), 
@v_degree varchar(100), 
@v_displayname varchar(100) output ,
@o_error_code       integer output,
@o_error_desc       varchar(2000) output)
AS

/**********************************************************************************
**  Change History
***********************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  02/02/18  Colman    Case 48925
**********************************************************************************/
BEGIN 
DECLARE

@v_firstname_initial varchar(1),
@v_middlename_initial varchar(1),
@v_space2 varchar(1),
@v_space varchar(1),
@v_comma varchar(2),
@v_displayname_format int,
@v_generate_full_displayname int

set @o_error_code = 0
set @o_error_desc = ''

--if group
if @v_individualind <> 1 begin
	set @v_displayname = @v_lastname
	return
end

set @v_space = ' '
set @v_space2 = ' '
set @v_comma = ', '

select @v_displayname_format = optionvalue 
from clientoptions
where optionid = 26

select @v_generate_full_displayname = optionvalue 
from clientoptions
where optionid = 20


set @v_lastname = ltrim(rtrim(IsNull(@v_lastname, '')))
set @v_firstname = ltrim(rtrim(IsNull(@v_firstname, '')))
set @v_middlename = ltrim(rtrim(IsNull(@v_middlename, '')))
set @v_middlename_initial = ltrim(rtrim(IsNull(@v_middlename_initial, '')))
set @v_firstname_initial = ltrim(rtrim(IsNull(@v_firstname_initial, '')))

--When both firstname and middlename are missing, return lastname
if @v_firstname = '' AND @v_middlename = '' begin
	set @v_displayname = @v_lastname
	return
end

-- Generate displayname from lastname, firstname and middlename
if @v_displayname_format  = 0 begin
	if @v_middlename_initial = '' begin  
		set @v_space = '' 
	end
	if @v_firstname = '' begin 
		set @v_space = '' 
	end 
	if @v_middlename_initial = '' and @v_firstname = '' begin
		set @v_space = ''
		set @v_comma = ''
	end

	set @v_displayname = @v_lastname + @v_comma + @v_firstname + @v_space + @v_middlename_initial 
end
if @v_displayname_format  = 1 begin
	if @v_firstname_initial = '' begin 
		set @v_comma = '' 
	end
	set @v_displayname = @v_lastname + @v_comma + @v_firstname_initial
end 
if @v_displayname_format  = 2 begin
	if @v_firstname = '' begin 
		set @v_space = '' 
	end
	set @v_displayname = @v_firstname + @v_space + @v_lastname
end
if @v_displayname_format  = 3 begin
	if @v_firstname <> '' and @v_middlename = '' begin 
		set @v_space = '' 
	end
	if @v_firstname = '' and @v_middlename <> '' begin 
		set @v_space = '' 
	end
	set @v_displayname = @v_firstname + @v_space + @v_middlename_initial + @v_space2 + @v_lastname
end
if @v_displayname_format  = 4 begin
	if @v_firstname = '' and @v_middlename = '' begin
		set @v_displayname = @v_lastname 
	end
	if @v_firstname <> '' and @v_middlename = '' begin
		set @v_displayname = @v_lastname + @v_comma + @v_firstname
	end
	if @v_firstname = '' and @v_middlename <> '' begin
		set @v_displayname = @v_lastname + @v_comma + @v_middlename
	end
	if @v_firstname <> '' and @v_middlename <> '' begin
		set @v_displayname = @v_lastname + @v_comma + @v_firstname + ' ' + @v_middlename
	end
end


--Check client option if full displayname should be generated (including suffix and degrees)
if @v_generate_full_displayname = 1 begin
	set @v_suffix = rtrim(ltrim(@v_suffix))
	set @v_degree = rtrim(ltrim(@v_degree))

	set @v_suffix = iSnull(@v_suffix, '')
	set @v_degree = iSnull(@v_degree, '')
		
	if @v_suffix <> '' begin
		set @v_displayname = @v_displayname + @v_comma + @v_suffix
	end
	if @v_degree <> '' begin
		set @v_displayname = @v_displayname + @v_comma + @v_degree
	end
end
END
go
GRANT EXECUTE ON dbo.globalcontact_displayname TO PUBLIC
GO




-- declare @v_individualind tinyint,  
-- @v_lastname varchar(100), 
-- @v_firstname varchar(100), 
-- @v_middlename varchar(100), 
-- @v_suffix varchar(75), 
-- @v_degree varchar(100) ,
-- @v_display varchar(100),
-- @v_globalcontactkey int


-- DECLARE contact_cur INSENSITIVE CURSOR
-- FOR
-- select globalcontactkey, individualind, lastname, firstname, middlename, suffix, degree
-- from globalcontact
-- where displayname is null or rtrim(ltrim(displayname))  = ''
-- for read only

-- OPEN contact_cur
-- FETCH NEXT FROM contact_cur INTO @v_globalcontactkey, @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree
  -- WHILE (@@FETCH_STATUS <> -1) BEGIN
	-- begin

		-- exec globalcontact_displayname @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree, @v_display output , 0, ''
    -- update globalcontact 
	-- set displayname = @v_display
	-- where globalcontactkey = @v_globalcontactkey

	-- FETCH NEXT FROM contact_cur INTO @v_globalcontactkey, @v_individualind, @v_lastname, @v_firstname, @v_middlename, @v_suffix, @v_degree

	-- end
-- end

-- close contact_cur
-- deallocate contact_cur
-- go

