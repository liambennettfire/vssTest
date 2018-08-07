if exists (select * from dbo.sysobjects where id = object_id(N'dbo.subgent_longdesc_function') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.subgent_longdesc_function
GO

  CREATE 
    FUNCTION dbo.subgent_longdesc_function
		(@ware_tableid integer, 
		 @ware_datacode integer,
		 @ware_datasubcode integer)

RETURNS varchar(40)
AS
BEGIN
DECLARE
@ware_datadesc varchar(40),
@ware_count integer

BEGIN

	select @ware_count = count(*)
	from subgentables
	where tableid = @ware_tableid
	and datacode = @ware_datacode
	and datasubcode = @ware_datasubcode

if @ware_count > 0 begin
	select @ware_datadesc = substring(datadesc,1,40)
	from subgentables
	where tableid = @ware_tableid
	and datacode = @ware_datacode
	and datasubcode = @ware_datasubcode

	if @@ROWCOUNT > 0  begin
		RETURN @ware_datadesc
	end else begin
		RETURN ''
	end
end else begin
	RETURN ''
END
return ''
END
END
go
GRANT EXEC ON dbo.subgent_longdesc_function TO public
GO

