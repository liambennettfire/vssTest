
IF OBJECT_ID('dbo.UpdFld_Util_DelimitedFieldPos') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Util_DelimitedFieldPos
GO

CREATE PROCEDURE UpdFld_Util_DelimitedFieldPos  -- find starting offset and length of nth delimited field
@record_buffer varchar(max),
@index         int,         -- if > 0, find the nth/@index'th (otherwise find 1st) delimited field beginning from @start+@length+1
@delimiter     varchar(30), -- last field in string/buffer doesn't need to have trailing delimiter, string-end is enough
@start         int output,
@length        int output
AS
BEGIN

if @start + @length >= len(@record_buffer) begin
	set @start  = 1 + len(@record_buffer)
	set @length = 0
end
else begin
	declare @pos1 int
	declare @pos2 int
	
	declare @delimiter_length int
	set     @delimiter_length = len(@delimiter)

	set @pos2 = @start + @length  -- for initialization of @pos1 (happens within loop)

	if @index <= 0
		set @index = 1

	while @index > 0 begin
		if @pos2 = 0   set @pos1 = 1
		else           set @pos1 = @pos2 + @delimiter_length
		
		set @pos2 = charindex(@delimiter, @record_buffer, @pos1)

		if @pos2 > 0
			set @index = @index - 1
		else begin
			set @pos2 = len(@record_buffer) + 1
			set @index = 0  -- end of buffer -> break out of loop
			
			-- If delimiter_length > 1, then an empty field at end of rec buffer (with no trailing field-delimiter)
			-- could yield @pos1 to exceed end-of-buffer plus 1 --> don't allow it (i.e. pos1 cannot exceed pos2).
			if @pos1 > @pos2
				set @pos1 = @pos2
		end
	end

	set @start  = @pos1
	set @length = @pos2 - @pos1
end

END
GO
