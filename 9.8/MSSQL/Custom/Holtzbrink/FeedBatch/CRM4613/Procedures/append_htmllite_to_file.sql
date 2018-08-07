IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'append_htmllite_to_file')
BEGIN
  DROP  Procedure  dbo.append_htmllite_to_file
END
GO
CREATE 
PROCEDURE append_htmllite_to_file 
		@i_bookkey integer,
		@i_printingkey integer,
		@i_commenttypecode integer,
		@i_commenttypesubcode integer,
		@FileName char(200)
AS

declare 
@v_string varchar(8000),
@v_start integer,
@v_lenght integer
begin
set @v_lenght = 8000
set @v_start = 0
WHILE 1 = 1 
BEGIN
	execute dbo.get_htmllite_procedure @i_bookkey, @i_printingkey, @i_commenttypecode, @i_commenttypesubcode, @v_start, @v_lenght, @v_string out
	set @v_start = @v_start + @v_lenght
	if @v_string = '' break
	execute  sp_AppendToFile @FileName, @v_string
END
end
go
grant execute on append_htmllite_to_file  to public
go

