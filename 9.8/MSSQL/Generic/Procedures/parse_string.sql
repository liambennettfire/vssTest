PRINT 'STORED PROCEDURE : dbo.parse_string'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.parse_string') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.parse_string
end

GO

CREATE PROCEDURE  parse_string
@ware_string varchar, @ware_parsestring varchar(1000) OUTPUT

AS

DECLARE @ware_count int
DECLARE @line_length int
DECLARE @ware_currdetail varchar(1000)
DECLARE @ware_tempstring varchar(1000)
DECLARE @ware_string2 varchar(1000)


if @ware_string = '' 
  begin
	RETURN
  end   

select @ware_string2 = @ware_string

if datalength(@ware_string2) < @line_length 	
  begin
	select ware_parsestring = @ware_string2
	RETURN
  end

/* put a space on the end of the detail line*/
select @ware_currdetail = @ware_string2 + ' '

WHILE datalength(@ware_string2) < @line_length 
  begin
	select @ware_parsestring = @ware_parsestring + substring(@ware_string2,1,45) + '~r'
	select @ware_string2 = substring(@ware_string2,46,datalength(@ware_string2))
  end

select @ware_parsestring = @ware_parsestring + substring(@ware_string2,1,45)
RETURN


GO