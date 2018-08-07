PRINT 'STORED PROCEDURE : dbo.gentables_shortdesc'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.gentables_shortdesc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.gentables_shortdesc
end

GO

CREATE PROCEDURE  gentables_shortdesc
@ware_tableid int, @ware_datacode int, @ware_datadescshort  varchar(20) OUTPUT

AS

DECLARE @ware_count int

	select @ware_count = count(*)
		from gentables
		where tableid = @ware_tableid
			and datacode = @ware_datacode

	if @ware_count > 0 
	  begin
		select @ware_datadescshort = datadescshort
			from gentables
			  where tableid = @ware_tableid
				and datacode = @ware_datacode

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