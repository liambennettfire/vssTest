PRINT 'STORED PROCEDURE : dbo.subgent_longdesc'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.subgent_longdesc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.subgent_longdesc
end

GO

CREATE PROCEDURE  subgent_longdesc
@ware_tableid int, @ware_datacode int, @ware_datasubcode int,
@ware_datadesc varchar(40) OUTPUT

AS

DECLARE @ware_count int

	select @ware_count = count(*)
		from subgentables
		where tableid = @ware_tableid
			and datacode = @ware_datacode
			and datasubcode = @ware_datasubcode

	if @ware_count > 0 
	  begin
		select @ware_datadesc = substring(datadesc,1,40)
			from subgentables
			  where tableid = @ware_tableid
				and datacode = @ware_datacode
				and datasubcode = @ware_datasubcode

		if @ware_datadesc is null
		  begin
			select @ware_datadesc = ''
			RETURN
 		  end
	  end
	else
	  begin
		select @ware_datadesc = ''
		RETURN
	 end

GO