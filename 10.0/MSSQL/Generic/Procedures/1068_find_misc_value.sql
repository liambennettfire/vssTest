SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.find_misc_value') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.find_misc_value 
end
go

create PROCEDURE dbo.find_misc_value 
@v_misckey int,
@v_misctype int , 
@v_datacode int, 
@v_miscvalue varchar(100),
@v_longvalue int  output,
@v_floatvalue float output,
@v_textvalue varchar(500) output,
@v_errorcode int output

												
AS
begin
declare 
@v_datasubcode int,
@v_datadesc varchar(100)

set @v_errorcode = 0

If @v_misctype = 1 begin
	Set @v_floatvalue = null
	Set @v_textvalue = null
	begin try
		set @v_longvalue = cast(@v_miscvalue as int)
	end try
	begin catch
		set @v_errorcode = -1
	end catch
end
if @v_misctype = 2 begin
	Set @v_longvalue = Null
	Set @v_textvalue = Null 
	begin try
		set @v_floatvalue = cast(@v_miscvalue as float)
	end try
	begin catch
		set @v_errorcode = -1
	end catch
end
if @v_misctype = 3 begin
	Set @v_floatvalue = Null
	Set @v_longvalue = Null
	Set @v_textvalue = @v_miscvalue 
end
if @v_misctype = 4 begin
	Set @v_floatvalue = Null
	Set @v_textvalue = Null 
	begin try
		set @v_longvalue = cast(@v_miscvalue as int)
	end try
	begin catch
		set @v_errorcode = -1
	end catch
	If @v_miscvalue <> '0' or @v_miscvalue <> '1' begin
		set @v_errorcode = -1
	end
end

if @v_misctype = 5 begin
	Set @v_floatvalue = Null
	select @v_datadesc = datadesc, @v_datasubcode = datasubcode
	from subgentables 
	where tableid = 525 
	and datacode = @v_datacode
	and externalcode = @v_miscvalue

	if @v_datadesc <> '' begin
		set @v_longvalue = @v_datasubcode
		set @v_textvalue = @v_datadesc
	end else begin	
		set @v_errorcode = -1
	end
end

if @v_misctype = 6 or @v_misctype = 7 begin
	set @v_errorcode = -1
end
end

		