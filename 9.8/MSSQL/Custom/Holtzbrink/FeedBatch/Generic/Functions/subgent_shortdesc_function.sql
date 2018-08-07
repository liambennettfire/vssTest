if exists (select * from dbo.sysobjects where id = object_id(N'dbo.subgent_shortdesc_function') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.subgent_shortdesc_function
GO

CREATE FUNCTION dbo.subgent_shortdesc_function
	(@ware_tableid integer, @ware_datacode integer,
	@ware_datasubcode integer)

RETURNS varchar(40)
AS
BEGIN
DECLARE
@ware_datadescshort  varchar(20),
@ware_count integer

BEGIN

	select @ware_count = count(*)
	from subgentables
	where tableid = @ware_tableid
	and datacode = @ware_datacode
	and datasubcode = @ware_datasubcode

	if @ware_count > 0 begin
	select @ware_datadescshort = datadescshort
	from subgentables
	where tableid = @ware_tableid
	and datacode = @ware_datacode
	and datasubcode = @ware_datasubcode

	if @@ROWCOUNT > 0  begin
		RETURN @ware_datadescshort
	end else begin
		RETURN ''
	end

end else begin
	RETURN ''
end
return ''
END
END
go
GRANT EXEC ON dbo.subgent_shortdesc_function TO public
GO

