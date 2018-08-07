
IF OBJECT_ID('dbo.UpdFld_Util_GentablesCodeMap') IS NOT NULL DROP FUNCTION dbo.UpdFld_Util_GentablesCodeMap
GO

CREATE FUNCTION dbo.UpdFld_Util_GentablesCodeMap
(
@tableid     int,          -- gentables id
@codeform    int,          -- 1=code#, 2=externalcode, 3=datadesc, 4=bisacdatacode, 5=datadescshort
@parentcode  int,          -- if > 0, data is a SUBgentables code under @parentcode
@formvalue   varchar(255)  -- data to map to code number
)
RETURNS int
AS
BEGIN

declare @code int    -- return value: (sub)gentables datacode mapped from @formvalue


if @codeform = 1                         -- need to do this here because db engine "pre-evaluates" expression and 
	set @code = convert(int, @formvalue) -- otherwise will get an error in where clause below even when @codeform <> 1

if @parentcode = 0   -- the column is a gentables value rather than a SUBgentables value
begin
	select	@code = datacode
	from	gentables
	where	tableid = @tableid
			and
			deletestatus = 'N'
			and
			(
			  --(@codeform = 1 and datacode = convert(int, @formvalue))      -- buffer holds datacode number as text
				(@codeform = 1 and datacode = @code)                         -- buffer holds datacode number as text
				or
				(@codeform = 2 and upper(@formvalue) = upper(externalcode))  -- buffer holds external-code corresponding to datacode
				or
				(@codeform = 3 and upper(@formvalue) = upper(datadesc))      -- buffer holds datadesc/display-label corresponding to datacode
				or
				(@codeform = 4 and upper(@formvalue) = upper(bisacdatacode))
				or
				(@codeform = 5 and upper(@formvalue) = upper(datadescshort))
			)
end
else   -- the column is a SUBgentables value rather than a gentables value
begin
	select	@code = datasubcode
	from	subgentables
	where	tableid = @tableid
			and
			datacode = @parentcode
			and
			deletestatus = 'N'
			and
			(
			  --(@codeform = 1 and datasubcode = convert(int, @formvalue))   -- buffer holds datacode number as text
				(@codeform = 1 and datasubcode = @code)                      -- buffer holds datacode number as text
				or
				(@codeform = 2 and upper(@formvalue) = upper(externalcode))  -- buffer holds external-code corresponding to datacode
				or
				(@codeform = 3 and upper(@formvalue) = upper(datadesc))      -- buffer holds datadesc/display-label corresponding to datacode
				or
				(@codeform = 4 and upper(@formvalue) = upper(bisacdatacode))
				or
				(@codeform = 5 and upper(@formvalue) = upper(datadescshort))
			)
end

RETURN @code

END
GO
