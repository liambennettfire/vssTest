SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.import_request_column_procedure') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.import_request_column_procedure
end
go

create PROCEDURE dbo.import_request_column_procedure @v_col varchar(100), @v_col_next varchar(100), @message varchar(8000), @v_data varchar(8000) output
AS

-- Set up variables.
DECLARE 
@v_pos INT,
@v_pos_break int 

begin
set @v_pos = charindex(@v_col, @message)

if @v_pos = 0 begin
	return
end

set @v_pos_break = charindex(@v_col_next, @message, @v_pos)
if @v_pos_break = 0 begin
  return
end
set @v_pos = @v_pos + datalength(@v_col) + 1
if @v_col_next is null begin
	set @v_data = SUBSTRING (@message ,@v_pos - 1, 8000)
end else begin
	set @v_data = SUBSTRING (@message ,@v_pos - 1, @v_pos_break - @v_pos)	
end
set @v_data = replace (@v_data,char(13),'')
set @v_data = replace (@v_data,char(10),'')
set @v_data = ltrim(rtrim(@v_data))
end	


go