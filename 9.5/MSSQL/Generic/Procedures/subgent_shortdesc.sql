PRINT 'STORED PROCEDURE : dbo.subgent_shortdesc'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.subgent_shortdesc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.subgent_shortdesc
end

GO

CREATE PROCEDURE  subgent_shortdesc
@ware_tableid int, @ware_datacode int, @ware_datasubcode int,
@ware_datadescshort  varchar(20) OUTPUT

AS

DECLARE @ware_count int

	select @ware_count = count(*)
		from subgentables
		where tableid = @ware_tableid
			and datacode = @ware_datacode
			and datasubcode = @ware_datasubcode

	if @ware_count > 0 
	  begin
		select @ware_datadescshort = datadescshort
			from subgentables
			  where tableid = @ware_tableid
				and datacode = @ware_datacode
				and datasubcode = @ware_datasubcode

		if @ware_datadescshort is null
		  begin
			select @ware_datadescshort  = ''
			RETURN
 		  end
	  end
	else
	  begin
		select @ware_datadescshort  = ''
		RETURN
	 end

GO